# LethalCompanyInstallMods

## How to install

Open a PowerShell console and execute this one-liner:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Indaclouds/LethalCompanyInstallMods/main/Install-ModsCompany.ps1'))
```
