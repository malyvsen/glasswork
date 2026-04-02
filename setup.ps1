#!/usr/bin/env pwsh

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$setupDir = Join-Path $repoRoot "setup"

& "$setupDir\install.ps1"
& "$setupDir\git.ps1"
& "$setupDir\terminal.ps1"
& "$setupDir\wsl.ps1"
& "$setupDir\dev-freedom.ps1"
& "$setupDir\copy-home.ps1"