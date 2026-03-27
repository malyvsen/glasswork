#!/usr/bin/env pwsh

$ErrorActionPreference = "Stop"

Write-Host "Installing programs..." -ForegroundColor Cyan

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

scoop install git # required for extras bucket
scoop bucket add extras
scoop install uv
scoop install fnm

Write-Host "Done." -ForegroundColor Green