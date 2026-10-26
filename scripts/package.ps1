# package.ps1 - assemble the distributable Windows x64 folder.
# Usage:  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\package.ps1
$ErrorActionPreference = 'Stop'

$root     = Split-Path -Parent $PSScriptRoot
$buildDir = Join-Path $root 'build\Release'
$dist     = Join-Path $root 'dist\BlazingStar-Recomp-Windows-x64'

if (-not (Test-Path (Join-Path $buildDir 'blazingstar.exe'))) {
    throw "blazingstar.exe not found in $buildDir - build Release first"
}

New-Item -ItemType Directory -Force -Path $dist | Out-Null
Copy-Item (Join-Path $buildDir 'blazingstar.exe') $dist -Force
if (Test-Path (Join-Path $buildDir 'SDL2.dll')) {
    Copy-Item (Join-Path $buildDir 'SDL2.dll') $dist -Force
}
Copy-Item (Join-Path $root 'packaging\README.txt') $dist -Force
Copy-Item (Join-Path $root 'LICENSE') (Join-Path $dist 'LICENSE.txt') -Force

Write-Host "Packaged to $dist"
Get-ChildItem $dist | Select-Object Name, Length | Format-Table -AutoSize
