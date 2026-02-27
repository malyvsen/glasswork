#!/usr/bin/env pwsh

$ErrorActionPreference = "Stop"

Write-Host "Installing programs..." -ForegroundColor Cyan

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
scoop install git
scoop bucket add extras
scoop install uv

Write-Host "Done." -ForegroundColor Green