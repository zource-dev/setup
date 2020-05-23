# ZOURCE.DEV Setup Environment Scripts

## Windows 10

```powershell
(New-Object System.Net.WebClient).DownloadFile('https://zource.dev/setup/windows.ps1', "$env:temp\setup.ps1"); Set-ExecutionPolicy Bypass -Scope Process -Force; powershell -noexit "$env:temp\setup.ps1"
```

## Mac OS

```bash
curl -o- https://zource.dev/setup/macos.sh | bash
```

## Ubuntu

```bash
curl -o- https://zource.dev/setup/ubuntu.sh | bash
```
