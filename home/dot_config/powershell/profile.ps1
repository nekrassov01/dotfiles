#!/usr/bin/env pwsh

$scripts = @(
  "init"
  "readline"
  "prompt"
  "modules"
  "web"
  "utilities"
  "variables"
  "aliases"
)

#Load sub modules
foreach ($script in $scripts) {
  . $([System.IO.Path]::Combine($PSScriptRoot, 'scripts', $("{0}.ps1" -f $script)))
}
