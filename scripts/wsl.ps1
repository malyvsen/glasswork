#!/usr/bin/env pwsh

$ErrorActionPreference = "Stop"

Write-Host "Setting up WSL 2..." -ForegroundColor Cyan

wsl --install alpine

Write-Host "Done." -ForegroundColor Green