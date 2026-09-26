param([ValidateSet('setup', 'build')][string]$Action = 'setup')
$ErrorActionPreference = 'Stop'
if ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture -ne 'Arm64') {
    throw 'This guest must run Windows ARM64.'
}
$work = 'C:\orca-work'
$source = 'C:\orca-source'
if (Test-Path $source) { Remove-Item -Recurse -Force $source }
New-Item -ItemType Directory -Force $source | Out-Null
New-Item -ItemType Directory -Force $work | Out-Null
tar.exe -xf "$env:USERPROFILE\orca-source.tar" -C $source
if ($LASTEXITCODE -ne 0) { throw 'Source extraction failed.' }
robocopy.exe $source $work /MIR /NFL /NDL /NJH /NJS /XD "$work\deps\DL_CACHE"
if ($LASTEXITCODE -ge 8) { throw 'Source synchronization failed.' }
Set-Location $work
$env:PATH = [Environment]::GetEnvironmentVariable('PATH', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('PATH', 'User')
New-Item -ItemType Directory -Force C:\orca-logs | Out-Null
$log = "C:\orca-logs\$Action.log"
if ($Action -eq 'setup') {
    if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) {
        Install-PackageProvider -Name NuGet -Force | Out-Null
        Install-Module Microsoft.WinGet.Client -Repository PSGallery -Force
        Repair-WinGetPackageManager -AllUsers
    }
    $buildArgs = '--install-vs buildtools --install-deps --arch arm64 -l --unattended'
} else {
    $buildArgs = '-ds -l -x --arch arm64 --run-tests -j 2 --build-dir C:\orca-build --deps-dir C:\orca-deps'
}
# Keep long-running native output in a guest log. WinRM's streaming file reader
# can race a growing output file during verbose installers and builds.
Write-Host "Windows $Action is running; log: $log"
& cmd.exe /d /c ".\build_win.bat $buildArgs > $log 2>&1"
$result = $LASTEXITCODE
Get-Content $log -Tail 60
if ($result -ne 0) { throw "Windows $Action failed ($result). See $log." }
