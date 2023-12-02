# LethalCompanyModder

Made with [VouDoo](https://github.com/VouDoo) :wrench:

This PowerShell script installs various mods for LethalCompany. It also includes the installation of BepInEx, a game patcher / plugin framework for Unity.

List of mods installed by the script:

- [MoreCompany](https://thunderstore.io/c/lethal-company/p/notnotnotswipez/MoreCompany/) by [notnotnotswipez](https://github.com/notnotnotswipez)
- [LateCompany](https://thunderstore.io/c/lethal-company/p/anormaltwig/LateCompany/) by [anormaltwig](https://github.com/ANormalTwig)
- [ShipLoot](https://thunderstore.io/c/lethal-company/p/tinyhoot/ShipLoot/) by [tinyhoot](https://github.com/tinyhoot)
- [Solos_Bodycams](https://thunderstore.io/c/lethal-company/p/CapyCat/Solos_Bodycams/) by CapyCat
- [TerminalApi](https://thunderstore.io/c/lethal-company/p/NotAtomicBomb/TerminalApi/) by [NotAtomicBomb](https://github.com/NotAtomicBomb)
- [Terminal_Clock](https://thunderstore.io/c/lethal-company/p/NotAtomicBomb/Terminal_Clock/) by [NotAtomicBomb](https://github.com/NotAtomicBomb)
- [LBtoKG](https://thunderstore.io/c/lethal-company/p/Zduniusz/LBtoKG/) by Zduniusz

## How to install

Open a PowerShell console and execute this one-liner:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Indaclouds/LethalCompanyInstallMods/main/install.ps1'))
```

## (Optional) Check your files

If you would like to check your installation files, you can find them in your game directory. The mods are located under the `BepInEx\plugins` directory.

![Check](https://github.com/Indaclouds/LethalCompanyInstallMods/assets/66850779/207efa58-edda-4922-bb98-15d1679b2a9d)
