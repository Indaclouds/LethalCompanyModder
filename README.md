# LethalCompanyInstallMods

Made with [VouDoo](https://github.com/VouDoo) :wrench:

This powershell script allows you to install various useful mods for LethalCompany. It will first install BepInEx, a game patcher / plugin framework for Unity, followed by the addition mods hosted on [thunderstore.io](https://thunderstore.io/). 

Mods currently installed are listed below:
- MoreCompany
- LateCompany

## How to install

Open a PowerShell console and execute this one-liner:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Indaclouds/LethalCompanyInstallMods/main/Install-ModsCompany.ps1'))
```

## (Optional) Check your files

If you would like to check your installation files, you can find them in your game directory. The mods are located in the 'Plugins' folder of BepInEx.

![Check](https://github.com/Indaclouds/LethalCompanyInstallMods/assets/66850779/207efa58-edda-4922-bb98-15d1679b2a9d)
