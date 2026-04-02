#!/usr/bin/env pwsh

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

function Test-IsElevated {
    $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($currentIdentity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Ensure-ElevatedSelf {
    if (Test-IsElevated) {
        return
    }

    Write-Host "Security step requires elevation. Requesting administrator approval..." -ForegroundColor Yellow
    $scriptPath = $PSCommandPath
    if ([string]::IsNullOrWhiteSpace($scriptPath)) {
        throw "Cannot determine script path for elevation relaunch."
    }
    $elevatedProc = Start-Process -FilePath "powershell.exe" -Verb RunAs -ArgumentList @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", "`"$scriptPath`""
    ) -Wait -PassThru

    if ($elevatedProc.ExitCode -ne 0) {
        throw "Elevated security configuration failed or was cancelled."
    }

    Write-Host "Done." -ForegroundColor Green
    exit 0
}

function Set-RegistryValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [object]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Type
    )

    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }

    $currentValue = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue).$Name
    if ($currentValue -eq $Value) {
        Write-Host "Registry unchanged: $Path\$Name = $Value" -ForegroundColor DarkGray
        return
    }

    New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force | Out-Null
    Write-Host "Registry updated: $Path\$Name = $Value" -ForegroundColor Green
}

Write-Host "Configuring Windows security policy for unrestricted local dev execution..." -ForegroundColor Cyan
Ensure-ElevatedSelf

# SmartScreen: Check apps and files: Off
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "SmartScreenEnabled" -Value "Off" -Type "String"
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableSmartScreen" -Value 0 -Type "DWord"

# Reputation-based protection for Store apps/web content: Off
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" -Name "EnableWebContentEvaluation" -Value 0 -Type "DWord"
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" -Name "PreventOverride" -Value 0 -Type "DWord"
Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" -Name "EnableWebContentEvaluation" -Value 0 -Type "DWord"
Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" -Name "PreventOverride" -Value 0 -Type "DWord"

# Potentially unwanted app blocking: Off
if (Get-Command Set-MpPreference -ErrorAction SilentlyContinue) {
    Set-MpPreference -PUAProtection Disabled
    Write-Host "Defender PUA protection updated: Disabled" -ForegroundColor Green
} else {
    Write-Host "Defender cmdlets unavailable; skipped PUAProtection change." -ForegroundColor Yellow
}

Write-Host "Done." -ForegroundColor Green
