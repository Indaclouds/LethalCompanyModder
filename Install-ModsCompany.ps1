#Requires -Version 5.1

<#
.SYNOPSIS
    Install BepInEx and some mods for Lethal Company.

.DESCRIPTION
    This script installs some plugins to increases the maximum player count for Lethal Company and add the capability to join game during a session.

.EXAMPLE
    PS> ./Install-MoreCompany.ps1

    Download, extract and install MoreCompany, LateCompany and all required componants.

.NOTES
    This script assumes that your Lethal Company installation is managed by Steam on Windows.
    Also, it installs BepInEx plugin framework, which is required to use the MoreCompany plugin.

.LINK
    - BepInEx GitHub repository: https://github.com/BepInEx/BepInEx
    - BepInEx installation guide: https://docs.bepinex.dev/articles/user_guide/installation/index.html
    - Thunderstore API documentation: https://thunderstore.io/api/docs/
    - MoreCompany Thunderstore page: https://thunderstore.io/c/lethal-company/p/notnotnotswipez/MoreCompany/
    - LateCompany Thunderstore page: https://thunderstore.io/c/lethal-company/p/anormaltwig/LateCompany/

#>

[CmdletBinding()]
param ()

$ProgressPreference = "SilentlyContinue"

Write-Host "Starting the Lethal Company mod installation process."

# Check if system is running on Windows
if ($env:OS -notmatch "Windows") { throw "Cannot run as it supports Windows only." }

# Search for directory where Lethal Company is installed
Write-Host "Searching for Lethal Company installation directory..."
$ChildItemParams = @{
    Path   = Get-PSDrive -PSProvider FileSystem | Select-Object -ExpandProperty Root
    Filter = "Lethal Company"
}
$GameDirectory = Get-ChildItem @ChildItemParams -Directory -Recurse -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName -First 1
if ($GameDirectory) {
    try {
        $LethalCompanyExecutable = Join-Path -Path $GameDirectory -ChildPath "Lethal Company.exe" -Resolve -ErrorAction Stop
    }
    catch { throw "Lethal Company executable not found." }
}
else { throw "Lethal Company directory not found." }
Write-Host "Lethal Company installation has been found in directory `"$GameDirectory`"."

# Define helper function to download and extract
function Invoke-DownloadAndExtract {
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
Invoke-DownloadAndExtract -Url $DownloadUrl -Destination $GameDirectory -Exclude "changelog.txt"

# Start and stop the game process to generate BepInEx configuration files
Write-Host "Launch Lethal Company to generate BepInEx configuration files."
Start-Process -FilePath $LethalCompanyExecutable
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
    $ModInfo = Invoke-RestMethod -Uri "https://thunderstore.io/api/experimental/package/$($_.ModName)/"
    if ($ModInfo."latest"."download_url") {
        $DownloadUrl = $ModInfo."latest"."download_url"
        Write-Host "Download `"$($_.ModName)`" from `"$DownloadUrl`"."
        Invoke-DownloadAndExtract -Url $DownloadUrl -Destination $GameDirectory -Include $_.Include
    }
    else {
        throw "Cannot download `"$($_.ModName)`" because source URL was not found."
    }
}

Write-Host "Lethal Company mod installation completed."

