#!/usr/bin/env pwsh

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$scriptDir = Join-Path $repoRoot "scripts"

& "$scriptDir\install.ps1"
& "$scriptDir\git-setup.ps1"
& "$scriptDir\terminal-setup.ps1"
& "$scriptDir\copy-home.ps1"