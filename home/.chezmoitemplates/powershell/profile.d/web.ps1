#!/usr/bin/env pwsh

# Safe mode
Set-StrictMode -Version Latest

# Search the AWS What's New Feed
function global:Search-UserAWSNewsFeed {
  param (
    [string[]]$Word
  )
  $words = $Word -join '%2B'
  open (
    (
      '{0}?{1}' -f 'https://aws.amazon.com/en/new/', (
        @(
          'whats-new-content-all.sort-by=item.additionalFields.postDateTime'
          'whats-new-content-all.q={0}'
          'whats-new-content-all.sort-order=desc'
          'whats-new-content-all.q_operator=AND#What.27s_New_Feed'
        ) -join '&'
      )
    ) -f $words
  )
}

# Access the official reference by specifying a subcommand of the AWS CLI
function global:Show-UserAWSCLIReference {
  param(
    [ValidateSet([AWSCLISubCommand])]
    [Alias('cmd')]
    [string]$SubCommand
  )
  open (
    'https://docs.aws.amazon.com/cli/latest/reference/{0}/index.html' -f $SubCommand
  )
}

# Access the official reference by specifying a cmdlet name of AWS Tools for PowerShell
function global:Show-UserAWSPowerShellReference {
  param(
    [ValidateSet([AWSPowerShellCommand])]
    [Alias('cmd')]
    [string]$Command
  )
  open (
    'https://docs.aws.amazon.com/powershell/latest/reference/items/{0}.html' -f $Command
  )
}
