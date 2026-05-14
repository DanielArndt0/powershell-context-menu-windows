$ErrorActionPreference = "SilentlyContinue"

$registryPaths = @(
    "HKCU:\Software\Classes\Directory\shell\OpenPowerShellHere",
    "HKCU:\Software\Classes\Directory\Background\shell\OpenPowerShellHere"
)

foreach ($path in $registryPaths) {
    if (Test-Path $path) {
        Remove-Item -Path $path -Recurse -Force
    }
}

Write-Host ""
Write-Host "PowerShell context menu entries removed successfully." -ForegroundColor Green
Write-Host ""
