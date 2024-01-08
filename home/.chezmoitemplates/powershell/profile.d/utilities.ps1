#!/usr/bin/env pwsh

# Safe mode
Set-StrictMode -Version Latest

# cd ~
function global:Push-UserHomeDirectory {
  Push-Location -LiteralPath $HOME
}

# cd ~/Documents
function global:Push-UserDocumentDirectory {
  Push-Location -LiteralPath $__Default.Folder.Documents
}

# cd ~/Downloads
function global:Push-UserDownloadDirectory {
  Push-Location -LiteralPath $__Default.Folder.Downloads
}

# cd ~/Desktop
function global:Push-UserDesktopDirectory {
  Push-Location -LiteralPath $__Default.Folder.Desktop
}

# cd ~/.repository
function global:Push-UserRepositoryDirectory {
  Push-Location -LiteralPath $__Default.Folder.Repository
}

# cd ~/Documents/work
function global:Push-UserWorkingDirectory {
  Push-Location -LiteralPath $__Default.Folder.Work
}

# Return auto-sized current directory info
function global:Get-UserAutoSizedDirectory {
  param (
    [Alias('p')]
    [string]$Path = $PWD
  )
  Get-ChildItem -LiteralPath $Path -Force | Format-Table -AutoSize
}

# Get global Ip address
function global:Get-UserGlobalIpAddress {
  param (
    [Alias('c')]
    [switch]$Cidr
  )
  $ret = (Invoke-RestMethod -Uri 'checkip.amazonaws.com' -Method Get).Trim()
  if ($Cidr) {
    $ret = '{0}/32' -f $ret
  }
  return $ret
}

# Execute script block in temporary directory
function global:Use-UserTemporaryDirectory {
  param (
    [ScriptBlock]$ScriptBlock
  )

  # Create temporary directory
  $tmpSubDir = (New-Item -Path $env:TMPDIR -Name $([System.Guid]::NewGuid().Guid) -ItemType Directory).FullName

  # Change temporary directory
  Push-Location -LiteralPath $tmpSubDir
  Write-Host $('Working in ''{0}''' -f $tmpSubDir) -ForegroundColor Cyan

  # Execute command
  $result = Invoke-Command -ScriptBlock $ScriptBlock

  # Cleaning
  Pop-Location
  Remove-Item -LiteralPath $tmpSubDir -Recurse -Force

  return $result
}

# Trust PSGallery if not trusted
function global:Enable-PSGallery {
  if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') {
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
  }
}

# Return application path
function global:Get-AppPath {
  param (
    [Alias('n')]
    [string]$Name
  )
  if (!$Name) {
    throw 'Name required'
  }
  $app = Get-Command -Name $Name -CommandType Application -ErrorAction Ignore
  if ($app) {
    return $app.Source
  }
  return
}

# Run a different command for each OS
function global:Invoke-OSCommand {
  param (
    [Alias('w')]
    [scriptblock]$Windows,
    [Alias('m')]
    [scriptblock]$MacOS,
    [Alias('l')]
    [scriptblock]$Linux
  )
  if ($IsWindows -and $null -ne $Windows) {
    Invoke-Command -ScriptBlock $Windows
  }
  if ($IsMacOS -and $null -ne $MacOS) {
    Invoke-Command -ScriptBlock $MacOS
  }
  if ($IsLinux -and $null -ne $Linux) {
    Invoke-Command -ScriptBlock $Linux
  }
}
