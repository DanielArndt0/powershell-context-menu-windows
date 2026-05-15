$ErrorActionPreference = "Stop"

function Get-PowerShellPath {
    $currentPowerShell = Get-Command powershell.exe -ErrorAction SilentlyContinue

    if ($currentPowerShell -and $currentPowerShell.Source -and (Test-Path $currentPowerShell.Source)) {
        return $currentPowerShell.Source
    }

    $fallbackPath = Join-Path $env:SystemRoot "System32\WindowsPowerShell\v1.0\powershell.exe"

    if (Test-Path $fallbackPath) {
        return $fallbackPath
    }

    return $null
}

function Set-RegistryDefaultValue {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    New-Item -Path $Path -Force | Out-Null
    Set-Item -Path $Path -Value $Value
}

function Add-PowerShellContextMenuEntry {
    param (
        [Parameter(Mandatory = $true)]
        [string]$RegistryPath,

        [Parameter(Mandatory = $true)]
        [string]$TargetPlaceholder,

        [Parameter(Mandatory = $true)]
        [string]$PowerShellPath
    )

    $commandPath = Join-Path $RegistryPath "command"

    New-Item -Path $RegistryPath -Force | Out-Null
    New-Item -Path $commandPath -Force | Out-Null

    Set-RegistryDefaultValue -Path $RegistryPath -Value "Open PowerShell here"

    New-ItemProperty `
        -Path $RegistryPath `
        -Name "MUIVerb" `
        -Value "Open PowerShell here" `
        -PropertyType String `
        -Force | Out-Null

    New-ItemProperty `
        -Path $RegistryPath `
        -Name "Icon" `
        -Value "`"$PowerShellPath`"" `
        -PropertyType String `
        -Force | Out-Null

    $command = "`"$PowerShellPath`" -NoExit -ExecutionPolicy RemoteSigned -Command `"Set-Location -LiteralPath '$TargetPlaceholder'`""

    Set-RegistryDefaultValue -Path $commandPath -Value $command
}

$powerShellPath = Get-PowerShellPath

if (-not $powerShellPath) {
    Write-Host "PowerShell was not found." -ForegroundColor Red
    Write-Host "Could not locate powershell.exe on this system." -ForegroundColor Yellow
    exit 1
}

Add-PowerShellContextMenuEntry `
    -RegistryPath "HKCU:\Software\Classes\Directory\shell\OpenPowerShellHere" `
    -TargetPlaceholder "%1" `
    -PowerShellPath $powerShellPath

Add-PowerShellContextMenuEntry `
    -RegistryPath "HKCU:\Software\Classes\Directory\Background\shell\OpenPowerShellHere" `
    -TargetPlaceholder "%V" `
    -PowerShellPath $powerShellPath

Write-Host ""
Write-Host "PowerShell context menu entries installed successfully." -ForegroundColor Green
Write-Host "Detected PowerShell path: $powerShellPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "If you are using Windows 11, the option may appear under 'Show more options'." -ForegroundColor Yellow