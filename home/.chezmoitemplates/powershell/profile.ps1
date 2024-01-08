#!/usr/bin/env pwsh

$scripts = @(
  "init"
  "readline"
  "modules"
  "web"
  "utilities"
  "variables"
  "aliases"
  "prompt"
)

#Load sub modules
foreach ($script in $scripts) {
  . $([System.IO.Path]::Combine($PSScriptRoot, 'profile.d', $("{0}.ps1" -f $script)))
}
