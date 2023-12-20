#!/usr/bin/env pwsh

# Safe mode
Set-StrictMode -Version Latest

# Capture the variable state at terminal startup
New-Variable -Name '__defaultVars' -Value $(
  (
    (Get-Variable).Name.ForEach{
      if ($_ -in '?', '^', '$') {
        '`' + $_
      }
      else {
        $_
      }
    } + '__defaultVars'
  ) | Sort-Object
) -Option Constant

# List variables set after the terminal is ready
function global:Get-UserAssignedVariable {
  Get-Variable -Name * -Exclude $__defaultVars -Scope Script
}

# Delete variables set after the terminal is ready
function global:Remove-UserAssignedVariable {
  Remove-Variable -Name * -Exclude $__defaultVars -Scope Script
}

# Expands the default variable '__default' set in the profile and returns it in json format
function global:Get-UserDefaultVariable {
  param (
    [Alias('j')]
    [switch]$Json
  )
  if (Test-Path Variable:__default) {
    if ($Json) {
      $__default = $__default | ConvertTo-Json
    }
    return $__default
  }
}
