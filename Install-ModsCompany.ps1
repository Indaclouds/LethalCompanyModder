#Requires -Version 5.1

<#
.SYNOPSIS
    Install a selection of mods for Lethal Company.

.DESCRIPTION
    This script installs the following mods for Lethal Company:
        o MoreCompany: Increases the max player count.
        o LateCompany: Enable players to join after the game has started.

.EXAMPLE
    PS> ./Install-MoreCompany.ps1

    Install mods for Lethal Company.

.NOTES
    This script assumes that your installation of Lethal Company is managed by Steam on Windows.
    It also installs BepInEx plugin framework, as some mods are BepInEx plugins.

.LINK
    - BepInEx GitHub repository: https://github.com/BepInEx/BepInEx
    - BepInEx installation guide: https://docs.bepinex.dev/articles/user_guide/installation/index.html
    - Thunderstore API documentation: https://thunderstore.io/api/docs/
    - MoreCompany mod Thunderstore page: https://thunderstore.io/c/lethal-company/p/notnotnotswipez/MoreCompany/
    - LateCompany mod Thunderstore page: https://thunderstore.io/c/lethal-company/p/anormaltwig/LateCompany/

#>

[CmdletBinding()]
param ()

$ProgressPreference = "SilentlyContinue"

Write-Host "Installation of Lethal Company mods started." -ForegroundColor Cyan

# Check if system is running on Windows
if ($env:OS -notmatch "Windows") { throw "Cannot run as it supports Windows only." }

# Search for directory where the Lethal Company is installed
Write-Host "Searching for Lethal Company installation directory..."
$DriveRootPaths = Get-PSDrive -PSProvider FileSystem | Where-Object -Property Name -NE -Value "Temp" | Select-Object -ExpandProperty Root
$PredictPaths = @(
    "Program Files (x86)\Steam\steamapps\common" # Default Steam installation path for games
    "Program Files\Steam\steamapps\common"
    "SteamLibrary\steamapps\common"
    "Steam\SteamLibrary\steamapps\common"
) | ForEach-Object -Process { foreach ($p in $DriveRootPaths) { Join-Path -Path $p -ChildPath $_ } }
$ChildItemParams = @{
    Path   = $PredictPaths + $DriveRootPaths  # Respect order to check every path prediction first
    Filter = "Lethal Company"
}
$GameDirectory = Get-ChildItem @ChildItemParams -Directory -Recurse -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName -First 1
if ($GameDirectory) {
    try {
        $GameExecutable = Join-Path -Path $GameDirectory -ChildPath "Lethal Company.exe" -Resolve -ErrorAction Stop
    }
    catch { throw "Lethal Company executable not found." }
}
else { throw "Lethal Company installation directory not found." }
Write-Host "Lethal Company installation has been found in directory `"$GameDirectory`"."

# Define helper function to download and extract archives
function Invoke-DownloadAndExtractArchive {
    param (
        [string] $Url,
        [string] $Destination,
        [string[]] $Include,
        [string[]] $Exclude
    )
    process {
        $Temp = New-Item -Path $env:TEMP -Name (New-Guid) -ItemType Directory
        try {
            Write-Host "Downloading from `"$Url`"."
            Invoke-WebRequest -Uri $Url -OutFile "$Temp\archive.zip"
            Write-Host "Extracting to `"$Destination`"."
            Expand-Archive -Path "$Temp\archive.zip" -DestinationPath "$Temp\expanded"
            Write-Host "Copying files to `"$Destination`"."
            Copy-Item -Path "$Temp\expanded\*" -Destination $Destination -Recurse -Include $Include -Exclude $Exclude -Force
        }
        finally { Remove-Item -Path $Temp -Recurse }
    }
}

# Install BepInEx from GitHub
$DownloadUrl = (Invoke-RestMethod -Uri "https://api.github.com/repos/BepInEx/BepInEx/releases/latest")."assets"."browser_download_url" | Select-String -Pattern ".*\/BepInEx_x64_.*.zip"
if ($DownloadUrl) { Write-Host "Download BepInEx from `"$DownloadUrl`"." } else { throw "BepInEx download URL not found." }
Invoke-DownloadAndExtractArchive -Url $DownloadUrl -Destination $GameDirectory -Exclude "changelog.txt"

# Run Lethal Company executable to generate BepInEx configuration files
Write-Host "Launch Lethal Company to generate BepInEx configuration files."
Start-Process -FilePath $GameExecutable
Start-Sleep -Seconds 10
Stop-Process -Name "Lethal Company" -Force
Start-Sleep -Seconds 5

# Check if BepInEx configuration files have been successfully generated
@(
    "$GameDirectory\BepInEx\config\BepInEx.cfg"
    "$GameDirectory\BepInEx\LogOutput.log"
) | ForEach-Object -Process {
    if (-not (Test-Path -Path $_)) { throw "BepInEx configuration failed because `"$_`" not found." }
}

# Install Mods from Thunderstore
@( # List of mods
    @{ ModName = "notnotnotswipez/MoreCompany"; Include = @("BepInEx") }
    @{ ModName = "anormaltwig/LateCompany"; Include = @("BepInEx") }
) | ForEach-Object -Process {
    $DownloadUrl = (Invoke-RestMethod -Uri "https://thunderstore.io/api/experimental/package/$($_.ModName)/")."latest"."download_url"
    if ($DownloadUrl) { Write-Host "Download `"$($_.ModName)`" mod from `"$DownloadUrl`"." } else { throw "`"$($_.ModName)`" mod download URL was not found." }
    Invoke-DownloadAndExtractArchive -Url $DownloadUrl -Destination $GameDirectory -Include $_.Include
}

Write-Host "Installation of Lethal Company mods completed." -ForegroundColor Cyan
