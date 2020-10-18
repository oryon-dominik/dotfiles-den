# windows-dotfile-environment

> This is about: How-to configure your own dotfile repository

## Prerequisites

If you followed the first tutorial [1-post-installation-windows10](1-post-installation-windows10.md) you're
already set to start with the dotfiles environment. So skip the next paragraph.

Make sure you have installed a [powershell](https://github.com/PowerShell/PowerShell#get-powershell) (This tutorial assumes, youre using `powershell7`), [chocolatey](https://chocolatey.org/) & [git](https://git-scm.com/) with [hub](https://hub.github.com/)

Open an admin-powershell.

## Setup your dotfiles repository

Set an environment variable (`$env:DOTFILES`) to the location you want to install your config to. 

```powershell
mkdir "$env:USERPROFILE/.dotfiles"
[Environment]::SetEnvironmentVariable("DOTFILES", "$env:USERPROFILE/.dotfiles", "User")
refreshenv
```

Clone (or create a new) dotfile repo into `$env:DOTFILES`.

```powershell
git clone https://github.com/oryon-dominik/dotfiles $env:DOTFILES
```

Make system links from the cloned powershell profile to the generic powershell-profile-folders.
This will delete the old folders (don't forget to backup your old powershell configs).

```powershell
Remove-Item -path "$env:userprofile\Documents\WindowsPowerShell" -recurse
cmd /c mklink /j "$env:userprofile\Documents\WindowsPowerShell" "$env:DOTFILES\scripts\powershell"

# for powershell 7:
Remove-Item -path "$env:userprofile\Documents\PowerShell" -recurse
cmd /c mklink /j "$env:userprofile\Documents\PowerShell" "$env:DOTFILES\scripts\powershell"
```

Install the additional powershell-modules.

```powershell
refreshenv
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression $env:DOTFILES/install/windows/additional_powershell_modules.ps1
```

If you like add the most basic proprietary software for your everyday work (Microsoft-Windows-Terminal, Visual Studio Code, Google Chrome, Google Drive Filestream).

```powershell
choco install $ENV:DOTFILES/install/windows/choco_win10_minimal.config
```

Restart your shell.

From here on you should be good to go and use your config, feel free to [customize your windows dotfiles](3-customize-windows-dotfiles.md)
and follow the rest of my tutorial.