#!/usr/bin/env pwsh

param(
    [string]$NerdFont = "Mononoki Nerd Font"
)

$ErrorActionPreference = "Stop"

Write-Host "Setting up terminal..." -ForegroundColor Cyan

scoop bucket add nerd-fonts
scoop install oh-my-posh
scoop install nerd-fonts/Mononoki-NF

$settingsPaths = @(
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json",
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
)

$settingsPath = $null
foreach ($path in $settingsPaths) {
    if (Test-Path $path) {
        $settingsPath = $path
        break
    }
}

if (-not $settingsPath) {
    Write-Host "Windows Terminal settings.json not found. Run Windows Terminal once to create it, then re-run this script." -ForegroundColor Yellow
    Write-Host "Searched: $($settingsPaths -join ', ')" -ForegroundColor Gray
} else {
    $raw = Get-Content $settingsPath -Raw
    $needsWrite = $false
    if ([string]::IsNullOrWhiteSpace($raw)) {
        $settings = [PSCustomObject]@{ profiles = [PSCustomObject]@{ defaults = [PSCustomObject]@{ font = [PSCustomObject]@{ face = $NerdFont } } } }
        $needsWrite = $true
    } else {
        $settings = $raw | ConvertFrom-Json

        if (-not $settings.PSObject.Properties["profiles"]) {
            $settings | Add-Member -MemberType NoteProperty -Name "profiles" -Value ([PSCustomObject]@{})
        }
        if (-not $settings.profiles.PSObject.Properties["defaults"]) {
            $settings.profiles | Add-Member -MemberType NoteProperty -Name "defaults" -Value ([PSCustomObject]@{})
        }
        if (-not $settings.profiles.defaults.PSObject.Properties["font"]) {
            $settings.profiles.defaults | Add-Member -MemberType NoteProperty -Name "font" -Value ([PSCustomObject]@{})
        }
        $currentFace = $settings.profiles.defaults.font.face
        $settings.profiles.defaults.font | Add-Member -MemberType NoteProperty -Name "face" -Value $NerdFont -Force

        $needsWrite = $currentFace -ne $NerdFont
    }

    if ($needsWrite) {
        $json = $settings | ConvertTo-Json -Depth 10
        [System.IO.File]::WriteAllText($settingsPath, $json)
        Write-Host "Updated $settingsPath with font.face = `"$NerdFont`"" -ForegroundColor Green
    } else {
        Write-Host "Font already set to `"$NerdFont`"" -ForegroundColor Green
    }
}

Write-Host "Done." -ForegroundColor Green
