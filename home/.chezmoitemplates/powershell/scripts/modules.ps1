#!/usr/bin/env pwsh

# Safe mode
Set-StrictMode -Version Latest

# Get user module list
function global:Get-UserModule {
  return (Get-Module -ListAvailable).Where{
    $_.ModuleBase -like [System.IO.Path]::Combine($__Default.Folder.Module, '*')
  }.ForEach{
    '{0}:{1}' -f $_.Name, $_.Version
  } | Sort-Object
}

# Output Pwshfile
function global:Out-UserModule {
  param (
    [Alias('l')]
    [string]$ModuleList = $__Default.Folder.ModuleList,
    [Alias('f')]
    [switch]$Force
  )
  if (!($force)) {
    if (Test-Path $moduleList) {
      Write-Error $('{0} already exists.' -f $moduleList)
      return
    }
  }
  Get-UserModule | Out-File -LiteralPath $moduleList -Force
  return $moduleList
}

# Test if module exists
function global:Test-UserModule {
  param (
    [Alias('l')]
    [string]$ModuleList = $__Default.Folder.ModuleList
  )
  if (!(Test-Path $moduleList)) {
    Write-Error $('{0} does not exists.' -f $moduleList)
    return
  }
  (Get-UserModule).ForEach{
    $m = $_ -split ':'
    Find-Module -Name $m[0] -RequiredVersion $m[1] -ErrorAction Stop
  }
}

# Install modules based on Pwshfile
function global:Install-UserModule {
  param (
    [Alias('l')]
    [string]$ModuleList = $__Default.Folder.ModuleList,
    [Alias('f')]
    [switch]$Force
  )
  if (!(Test-Path $moduleList)) {
    Write-Error $('{0} does not exists.' -f $moduleList)
    return
  }
  Test-UserModule 1>$null
  (Get-Content -LiteralPath $moduleList).ForEach{
    $m = $_ -split ':'
    Install-Module -Name $m[0] -Scope CurrentUser -RequiredVersion $m[1] -SkipPublisherCheck -AllowClobber -AllowPrerelease -Force:$force -Confirm:$false
  }
}

# Remove user module list
function global:Remove-UserModule {
  param (
    [Alias('l')]
    [string]$ModuleList = $__Default.Folder.ModuleList,
    [Alias('f')]
    [switch]$Force
  )
  if (!(Test-Path $moduleList)) {
    Write-Error $('{0} does not exists.' -f $moduleList)
    return
  }
  (Get-Content -LiteralPath $moduleList).ForEach{
    $m = $_ -split ':'
    Uninstall-Module -Name $m[0] -RequiredVersion $m[1] -AllowPrerelease -Force:$force -Confirm:$false
  }
}

# Update and clean up modules
function global:Optimize-UserModule {
  param (
    [Alias('l')]
    [string]$ModuleList = $__Default.Folder.ModuleList
  )
  Get-InstalledModule | Update-Module
  (Get-InstalledModule).ForEach{
    Get-InstalledModule -Name $_.Name -AllVersions |
    Sort-Object -Property Version -Descending |
    Select-Object -Skip 1 |
    Uninstall-Module -Force -Confirm:$false
  }
}
