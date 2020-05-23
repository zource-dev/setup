function Set-SetupItem ($Path, $Name, $Type, $Value) {
  if (!(Test-Path -Path $Path)) {
    New-Item -Path $Path -Force | Out-Null
  }
  New-ItemProperty -Path $Path -Name $Name -PropertyType $Type -Value $Value -Force | Out-Null
}

function Get-File($Url, $File, [switch]$Execute, $Params) {
  (New-Object System.Net.WebClient).DownloadFile($Url, "$($env:temp)\$File")
  if ($Execute) {
    Invoke-Expression "$($env:temp)\$File $Params"
  }
  "$($env:temp)\$File"
}

function Get-Bool ($Or = $false, $And = $true){
  process { [System.Convert]::ToBoolean($_) -or $Or -and $And }
}

$setupKey = 'HKCU:\Software\ZourceDev'
$taskName = 'ZourceSetup'
$filePath = $PSCommandPath

$exists = Test-Path -Path $setupKey
if (!$exists) {
  Write-Host 'Initialization...'

  Set-SetupItem -Path $setupKey -Name 'Setup' -Type 'DWord' -Value 1
  Set-SetupItem -Path $setupKey -Name 'InstallationPolicy' -Type 'String' -Value ((Get-PSRepository -Name 'PSGallery').InstallationPolicy)

  $command = "Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression '$filePath'"
  schtasks /create /tn $taskName /sc onlogon /delay 0000:10 /rl highest /f /tr "powershell -noexit $command" | Out-Null
}

$step = (Get-ItemProperty -Path $setupKey -Name 'Setup').Setup
Write-Host "Starting from step $step"

$restartNeeded = $false

if ($step -eq 1) {
  Write-Host 'Installing components...'
  Install-PackageProvider -Name NuGet -Force | Out-Null
  Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted | Out-Null
  Install-Module PSWindowsUpdate | Out-Null
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) | Out-Null

  $step = 2
  Set-SetupItem -Path $setupKey -Name 'Setup' -Type 'DWord' -Value $step
}

if ($step -eq 2) {
  Write-Host 'Installing Windows updates...'
  Get-WindowsUpdate -Install -AcceptAll -IgnoreReboot | Out-Null
  Write-Host 'Updates are installed!'

  $restartNeeded = (Get-WURebootStatus -Silent) | Get-Bool -or $restartNeeded
  if ($restartNeeded) {
    Write-Host 'Restarting...'
    Restart-Computer
    exit
  } else {
    $build=[System.Environment]::OSVersion.Version.Build
    Write-Host "Current build is $build"
    if ($build -lt 19041) {
      Write-Host "WSL 2 is not supported for build number $build, please update your Windows to the latest version"
      exit 1
    }

    $step = 3
    Set-SetupItem -Path $setupKey -Name 'Setup' -Type 'DWord' -Value $step
  }
}

if ($step -eq 3) {
  $restartNeeded = (Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName VirtualMachinePlatform).RestartNeeded | Get-Bool -or $restartNeeded
  $restartNeeded = (Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName Microsoft-Windows-Subsystem-Linux).RestartNeeded | Get-Bool -or $restartNeeded

  $step = 4
  Set-SetupItem -Path $setupKey -Name 'Setup' -Type 'DWord' -Value $step  

  if ($restartNeeded) {
    Write-Host 'Restarting...'
    Restart-Computer
    exit
  }
}

if ($step -eq 4) {
  Write-Host 'Installing WSL Core...'
  Get-File -Url 'https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi' -File 'wsl_update.msi' -Params '/passive' -Execute
  wsl --set-default-version 2
  
  $appPath = Get-File -Url 'https://aka.ms/wsl-ubuntu-1804' -File 'Ubuntu.appx'
  Add-AppxPackage $appPath
  Invoke-Expression "$env:UserProfile\AppData\Local\Microsoft\WindowsApps\ubuntu1804.exe run exit"
  $distro='ubuntu-18.04'
  wsl --set-default $distro

  wsl bash -c "curl -o- https://zource.dev/setup/wsl.sh | bash"

  Write-Host 'Restarting Ubuntu...'
  wsl --terminate $distro
  do {
    Write-Host 'Checking restart progress...'
    Start-Sleep 1
  } while((wsl -l -q --running) -contains $distro);
  
  cmd.exe /C setx WSLENV BASH_ENV/u
  cmd.exe /C setx BASH_ENV /etc/bash.bashrc

  Write-Host 'Installing Chrome Canary...'
  choco install -y chromium --pre

  Write-Host 'Installing docker...'
  choco install -y docker-desktop --pre

  Write-Host 'Installing Heroku...'
  wsl bash -c "sudo snap install heroku --classic > /dev/null"

  Write-Host 'Installing VSCode...'
  choco install -y vscode

  Write-Host 'Installing Sublime Text 3...'
  choco install -y sublimetext3

  Write-Host 'Installing Postman...'
  choco install -y postman

  Write-Host 'Installing Figma...'
  choco install -y figma

  Write-Host 'Installing MySQL Workbench...'
  choco install -y mysql.workbench

  wsl bash -c "curl -o- https://zource.dev/setup/common.sh | bash"

  $step = 5
  Set-SetupItem -Path $setupKey -Name 'Setup' -Type 'DWord' -Value $step  
}

if ($step -eq 5) {
  Uninstall-Module PSWindowsUpdate
  Set-PSRepository -Name 'PSGallery' -InstallationPolicy (Get-ItemProperty -Path $setupKey -Name 'InstallationPolicy')
  schtasks /delete /tn $taskName /f
  Remove-Item -Path $setupKey -Force
}
