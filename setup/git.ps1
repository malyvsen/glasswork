#!/usr/bin/env pwsh

$ErrorActionPreference = "Stop"

Write-Host "Configuring Git (global)..." -ForegroundColor Cyan

git config --global credential.helper manager
git config --global user.name "malyvsen"
git config --global user.email "malyvsen@users.noreply.github.com"
git config --global core.autocrlf true
git config --global init.defaultBranch main

Write-Host "Done. Current config:" -ForegroundColor Green
