# ZOURCE.DEV Setup Environment Scripts

The following apps will be installed:
 - Git
 - VSCode
 - SublimeText 3
 - Chromium Dev  Build
 - Docker
 - Postman
 - Figma

## Windows 10

Sets up WSL 2 with Ubuntu 18.04 and installs required apps

```powershell
(New-Object System.Net.WebClient).DownloadFile('https://zource.dev/setup/windows.ps1', "$env:temp\setup.ps1"); Set-ExecutionPolicy Bypass -Scope Process -Force; powershell "$env:temp\setup.ps1"
```

## Mac OS

Installs required apps

```bash
curl -o- https://zource.dev/setup/macos.sh | bash
```

## Ubuntu

Installs required apps

```bash
curl -o- https://zource.dev/setup/ubuntu.sh | bash
```
