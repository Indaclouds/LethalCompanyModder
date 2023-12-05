# LethalCompanyModder

This PowerShell script installs a list of selected mods for LethalCompany.

It also includes the installation of BepInEx, a game patcher / plugin framework for Unity.

You don't need to install anything on your Windows system to run this script.

---

- [LethalCompanyModder](#lethalcompanymodder)
  - [How to use](#how-to-use)
    - [Basic installation](#basic-installation)
    - [Custom installation](#custom-installation)
      - [Install curated list of mods](#install-curated-list-of-mods)
      - [Install list of mods from file](#install-list-of-mods-from-file)
    - [Upgrade](#upgrade)
  - [Curated list of mods](#curated-list-of-mods)
    - [`default` mods](#default-mods)
  - [Check your files](#check-your-files)

---

## How to use

### Basic installation

To run ths script, follow these steps:

1. Open a PowerShell console.
2. Copy this _one-liner_ command in the console:

    ```powershell
    Set-ExecutionPolicy Bypass -Scope Process -Force; $Script = "$env:TEMP\LethalCompanyModder.ps1"; iwr "https://raw.githubusercontent.com/Indaclouds/LethalCompanyModder/main/LethalCompanyModder.ps1" -OutFile $Script; & $Script
    ```

3. Execute it.

It's as simple as that! 😄

### Custom installation

If needed, you can pass some parameters to the script:

```powershell
& .\LethalCompanyModder.ps1 <parameters>
```

#### Install curated list of mods

```powershell
& .\LethalCompanyModder.ps1 -List "yet-another-list-of-mods"
```

#### Install list of mods from file

```powershell
& .\LethalCompanyModder.ps1 -File "./path/to/yet-another-list-of-mods.json"
```

### Upgrade

If you need to update, re-run the script once again.

Mods and dependencies will be re-installed with the latest version.

## Curated list of mods

### `default` mods

_This is the list of mods to be installed when no curated or custom list is specified by the user._

- [MoreCompany](https://thunderstore.io/c/lethal-company/p/notnotnotswipez/MoreCompany/) by [notnotnotswipez](https://github.com/notnotnotswipez)
- [LateCompany](https://thunderstore.io/c/lethal-company/p/anormaltwig/LateCompany/) by [anormaltwig](https://github.com/ANormalTwig)
- [ShipLoot](https://thunderstore.io/c/lethal-company/p/tinyhoot/ShipLoot/) by [tinyhoot](https://github.com/tinyhoot)
- [Solos_Bodycams](https://thunderstore.io/c/lethal-company/p/CapyCat/Solos_Bodycams/) by CapyCat
- [TerminalApi](https://thunderstore.io/c/lethal-company/p/NotAtomicBomb/TerminalApi/) by [NotAtomicBomb](https://github.com/NotAtomicBomb)
- [Terminal_Clock](https://thunderstore.io/c/lethal-company/p/NotAtomicBomb/Terminal_Clock/) by [NotAtomicBomb](https://github.com/NotAtomicBomb)
- [LBtoKG](https://thunderstore.io/c/lethal-company/p/Zduniusz/LBtoKG/) by Zduniusz

## Check your files

If you would like to check your files after the installation, you can find them in the game directory.

The mods are located under the `BepInEx\plugins` directory.

![Check](https://github.com/Indaclouds/LethalCompanyInstallMods/assets/66850779/207efa58-edda-4922-bb98-15d1679b2a9d)
