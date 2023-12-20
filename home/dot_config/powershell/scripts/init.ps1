#!/usr/bin/env pwsh

# Safe mode
Set-StrictMode -Version Latest


#
# Variables to assign when loading profiles
#


# Create container of user-assigned settings
New-Variable -Name '__Default' -Value $([ordered]@{})

# User directory for daily use
$__Default.Folder = [ordered]@{}
$__Default.Folder.Documents = [System.IO.Path]::Combine($HOME, 'Documents')
$__Default.Folder.Downloads = [System.IO.Path]::Combine($HOME, 'Downloads')
$__Default.Folder.Desktop = [System.IO.Path]::Combine($HOME, 'Desktop')
$__Default.Folder.Box = [System.IO.Path]::Combine($HOME, 'Documents', 'kawashima')
$__Default.Folder.Project = [System.IO.Path]::Combine($HOME, 'Documents', 'kawashima', 'project')
$__Default.Folder.Repository = [System.IO.Path]::Combine($HOME, '.repository')
$__Default.Folder.ToolsBundle = [System.IO.Path]::Combine($HOME, '.local', 'share','chezmoi', 'tools')
$__Default.Folder.ModuleList = [System.IO.Path]::Combine($__Default.Folder.ToolsBundle, 'Pwshfile')

if ($IsWindows) {
  $__Default.Folder.Module = "$HOME\Documents\PowerShell\Modules"
}
else {
  $__Default.Folder.Module = "$HOME/.local/share/powershell/Modules"
}

#
# Classes for 'ValidateSet' of functions
#


# All sub commands of AWSCLI
class AWSCLISubCommand : System.Management.Automation.IValidateSetValuesGenerator {
  [string[]]GetValidValues() {
    return (((((((aws help | Out-String) -replace '.\x08', '') -split 'AVAILABLE SERVICES')[1] -split 'SEE ALSO')[0] -replace '\s*\r?\n', '') -replace '\s+o\s', [environment]::NewLine) -split [environment]::NewLine).Trim()
  }
}

# All commands of AWS Tools for PowerShell
class AWSPowerShellCommand : System.Management.Automation.IValidateSetValuesGenerator {
  [string[]]GetValidValues() {
    return (Get-AWSCmdletName).CmdletName
  }
}
