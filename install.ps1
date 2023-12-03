#Requires -Version 5.1

<#
.SYNOPSIS
    Install a selection of mods for Lethal Company.

.DESCRIPTION
    This script installs the list of selected mods for Lethal Company.

.EXAMPLE
    PS> ./install.ps1

    Install mods for Lethal Company.

.NOTES
    This script assumes that your installation of Lethal Company is managed by Steam on Windows.
    It also installs BepInEx plugin framework, as some mods are BepInEx plugins.

.LINK
    - BepInEx GitHub repository: https://github.com/BepInEx/BepInEx
    - BepInEx installation guide: https://docs.bepinex.dev/articles/user_guide/installation/index.html
    - Thunderstore API documentation: https://thunderstore.io/api/docs/
    - Lethal Company community page on Thunderstore: https://thunderstore.io/c/lethal-company/

#>

[CmdletBinding(DefaultParameterSetName = "Curated")]
param (
    [Parameter(
        ParameterSetName = "Curated",
        HelpMessage = "Name of a curated list of mods to install"
    )]
    [ValidateSet("default")]
    [string] $List = "default",

    [Parameter(
        ParameterSetName = "Curated",
        HelpMessage = "Name of the Git branch where the curated list of mods is located"
    )]
    [string] $GitBranch = "main",

    [Parameter(
        ParameterSetName = "Custom",
        HelpMessage = "Path to a JSON file including a list of mods to install"
    )]
    [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
    [string] $File
)

#region ---- System and PowerShell configuration and pre-flight check
# Set PowerShell Cmdlet
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"  # Fix slow execution for some cmdlets
if ($PSBoundParameters.Debug -and $PSEdition -eq "Desktop") {
    # Fix repetitive action confirmation in PowerShell Desktop when Debug parameter is set
    $DebugPreference = "Continue"
}

# Check if system is running on Windows
if ($env:OS -notmatch "Windows") { throw "Cannot run as it supports Windows only." }
#endregion ----

#region ---- Definition of mods for Lethal Company
$Mods = $(switch ($PSCmdlet.ParameterSetName) {
        "Curated" {
            Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Indaclouds/LethalCompanyModder/$GitBranch/mods/$List.json" | Select-Object -ExpandProperty Content
        }
        "Custom" { Get-Content -Path $ModsFile -Raw }
    }) | ConvertFrom-Json
#endregion ----

#region ---- Installation of mods for Lethal Company
$Banner = @"

  ##################################################################################
  ##                                                                              ##
 ###    ###        #######   #########   ###    ###        ###       ###          ##
 ###    ###        ###         ####      ###    ###       #####       ###         ##
 ###   ###        ####         ####      ##########      #######      ###         ###
 ###   ###        ########     ####      ##########     #### ####     ###         ###
 ###  ###         ###          ####      ###    ###    ###########    ###         ###
 ### ##########   ########     ####      ###    ###   #####   #####    #########  ###
 ##                                                                                ##
###    #####    ######   #####    ##### #######     #####   ####    #######   #### ###
### ######### ########## ######  ###### #########  ######   #####   ########  #### ###
## #####     ####    ### ######  ###### ###  ####  #######  ####### #### #######   ###
## ####      ###     ### ############## ######### #### #### ############  ######   ###
## #####     ####    ### ### ########## #######  ########## #### #######   ####     ##
##  ######### ########## ### ##### #### ###     ################  ######   ###      ##
##    ######    ######   ###  ###   ### ###     ####    ########    ####   ###      ##
##                                                                                  ##
######################################################################################

Our auto-pilot is going to install a selected list of high-end mods for you (and the Company).
In the meantime, just seat back and relax...

Mods to be installed:
{0}

"@ -f (($Mods | ForEach-Object -Process { " o {0}: {1}" -f $_.Name, $_.Description }) -join "`r`n")
Write-Host $Banner -ForegroundColor Green

Write-Host "Installation of Lethal Company mods started." -ForegroundColor Cyan

# Search for directory where Lethal Company is installed
Write-Host "Search for Lethal Company installation directory."
$DriveRootPaths = Get-PSDrive -PSProvider FileSystem | Where-Object -Property Name -NE -Value "Temp" | Select-Object -ExpandProperty Root
$PredictPaths = @(
    "Program Files (x86)\Steam\steamapps\common"  # Default Steam installation path for games
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
    try { $GameExecutable = Join-Path -Path $GameDirectory -ChildPath "Lethal Company.exe" -Resolve -ErrorAction Stop }
    catch { throw "Lethal Company executable not found." }
}
else { throw "Lethal Company installation directory not found." }
Write-Debug -Message "Lethal Company installation has been found in directory `"$GameDirectory`"."

# Define helper function to download and extract archives
function Invoke-DownloadAndExtractArchive {
    [CmdletBinding()]
    param (
        [string] $Url,
        [string] $Destination,
        [switch] $FlatCopy,
        [string[]] $Include,
        [string[]] $Exclude
    )

    process {
        $Temp = New-Item -Path $env:TEMP -Name (New-Guid) -ItemType Directory
        try {
            Write-Debug -Message "Download package from `"$Url`"."
            Invoke-WebRequest -Uri $Url -OutFile "$Temp\archive.zip"
            Write-Debug -Message "Extract package to temporary directory."
            Expand-Archive -Path "$Temp\archive.zip" -DestinationPath "$Temp\expanded"
            Write-Debug -Message "Copy files to `"$Destination`"."
            $Filter = @{ Include = $Include; Exclude = $Exclude }
            if ($FlatCopy.IsPresent) {
                Get-ChildItem -Path "$Temp\expanded\*" @Filter -Recurse | Copy-Item -Destination $Destination -Force
            }
            else {
                Copy-Item -Path "$Temp\expanded\*" -Destination $Destination @Filter -Recurse -Force
            }
        }
        finally { Remove-Item -Path $Temp -Recurse }
    }
}

# Remove existing BepInEx components from Lethal Company directory
Write-Host "Clean BepInEx files and directory up."
@(
    "BepInEx"
    "winhttp.dll"
    "doorstop_config.ini"
) | ForEach-Object -Process {
    $Path = Join-Path -Path $GameDirectory -ChildPath $_
    if (Test-Path -Path $Path) {
        Write-Debug -Message "Remove existing BepInEx component `"$_`"."
        Remove-Item -Path $Path -Recurse -Force
    }
}

# Install BepInEx from GitHub
Write-Host "Install BepInEx plugin framework."
$DownloadUrl = (Invoke-RestMethod -Uri "https://api.github.com/repos/BepInEx/BepInEx/releases/latest")."assets"."browser_download_url" | Select-String -Pattern ".*\/BepInEx_x64_.*.zip"
if (-not $DownloadUrl) { throw "BepInEx download URL not found." }
Invoke-DownloadAndExtractArchive -Url $DownloadUrl -Destination $GameDirectory -Exclude "changelog.txt"

# Run Lethal Company executable to generate BepInEx configuration files
Write-Host "Launch Lethal Company to install BepInEx."
Write-Debug -Message "Start Lethal Company process and wait."
Start-Process -FilePath $GameExecutable -WindowStyle Hidden
Start-Sleep -Seconds 10
Write-Debug -Message "Stop Lethal Company process and wait."
Stop-Process -Name "Lethal Company" -Force
Start-Sleep -Seconds 2

# Check if BepInEx configuration files have been successfully generated
Write-Host "Check BepInEx installation."
@(
    "config\BepInEx.cfg"
    "LogOutput.log"
) | ForEach-Object -Process {
    $Path = Join-Path -Path $GameDirectory -ChildPath "BepInEx\$_"
    if (Test-Path -Path $Path) { Write-Debug -Message "BepInEx configuration file `"$_`" found." }
    else { throw "BepInEx configuration failed because `"$_`" not found." }
}

# Define BepInEx plugins directory
$BepInExPluginsDirectory = Join-Path -Path $GameDirectory -ChildPath "BepInEx\plugins"

# Install Mods from Thunderstore
$Mods | Where-Object -Property From -EQ -Value "Thunderstore" | ForEach-Object -Process {
    Write-Host ("Install {0} mod by {1}." -f $_.Name, $_.Namespace)
    $FullName = "{0}/{1}" -f $_.Namespace, $_.Name
    $DownloadUrl = (Invoke-RestMethod -Uri "https://thunderstore.io/api/experimental/package/$FullName/")."latest"."download_url"
    if (-not $DownloadUrl) { throw "`"$FullName`" mod download URL was not found." }
    switch ($_.Type) {
        "BepInExPlugin" {
            Invoke-DownloadAndExtractArchive -Url $DownloadUrl -Destination $BepInExPluginsDirectory -FlatCopy -Include "*.dll"
        }
        Default { Write-Error -Message "Unknown mod type for `"$FullName`"." }
    }
}

Write-Host "Installation of Lethal Company mods completed." -ForegroundColor Cyan

Write-Host "`r`nGet back to work with your crewmates! No more excuses for not meeting the Company's profit quotas...`r`n" -ForegroundColor Green
#endregion ----
