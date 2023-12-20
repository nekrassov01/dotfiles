#!/usr/bin/env pwsh

# Safe mode
Set-StrictMode -Version Latest

# This configuration based on 'posh-git'
if (!(Get-Module -ListAvailable -Name 'posh-git')) {
  return
}

# Import git prompt for pwsh
Import-Module -Name 'posh-git'

# If you care about performance, disable displaying file status by posh-git
#$GitPromptSettings.EnableFileStatus = $false

# Prompt setting
function global:prompt {
  $originalLASTEXITCODE = $LASTEXITCODE

  $prompt = "{0}@{1}:{2}{3}{4}{5}{6}" -f (
    (Write-Prompt ([Environment]::UserName) -ForegroundColor Green),
    (Write-Prompt ([Environment]::MachineName) -ForegroundColor Green),
    (Write-Prompt (Get-PromptPath) -ForegroundColor Cyan),
    (Write-VcsStatus),
    ([Environment]::NewLine),
    (Write-Prompt 'PS' -ForegroundColor DarkYellow),
    (Write-Prompt '> ' -ForegroundColor White)
  )
  $prompt = if ($prompt) { "$prompt" } else { "> " }

  $global:LASTEXITCODE = $originalLASTEXITCODE
  return $prompt
}
