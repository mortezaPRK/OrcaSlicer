$ErrorActionPreference = 'Stop'
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private
Enable-PSRemoting -SkipNetworkProfileCheck -Force
Set-Item WSMan:\localhost\Service\Auth\Basic $true -Force
Set-Item WSMan:\localhost\Service\AllowUnencrypted $true -Force
Set-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System LocalAccountTokenFilterPolicy 1
Set-Service WinRM -StartupType Automatic
Set-LocalUser vagrant -PasswordNeverExpires $true
New-Item C:\vagrant-base-ready -ItemType File -Force
shutdown.exe /s /t 20
