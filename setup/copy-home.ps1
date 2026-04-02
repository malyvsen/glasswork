#!/usr/bin/env pwsh

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$sourceHome = Join-Path $repoRoot "home"
$targetHome = $env:USERPROFILE

Write-Host "Copying home files to $targetHome..." -ForegroundColor Cyan

if (-not (Test-Path $sourceHome)) {
    Write-Host "Source home directory not found: $sourceHome" -ForegroundColor Red
    exit 1
}

Copy-Item -Path $sourceHome\* -Destination $targetHome -Recurse -Force

Write-Host "Done." -ForegroundColor Green
