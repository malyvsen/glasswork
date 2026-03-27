#!/usr/bin/env pwsh

oh-my-posh init pwsh --config spaceship | Invoke-Expression

fnm env --use-on-cd | Out-String | Invoke-Expression