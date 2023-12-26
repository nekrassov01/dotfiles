#!/usr/bin/env pwsh

# Safe mode
Set-StrictMode -Version Latest

$map = @{
  # Built-in
  'pop' = 'Pop-Location'

  # Web access
  'awsfeed' = 'Search-UserAWSNewsFeed'
  'awscli' = 'Show-UserAWSCLIReference'
  'awspwsh' = 'Show-UserAWSPowerShellReference'

  # Utilities
  '~' = 'Push-UserHomeDirectory'
  'home' = 'Push-UserHomeDirectory'
  'document' = 'Push-UserDocumentDirectory'
  'dl' = 'Push-UserDownloadDirectory'
  'desk' = 'Push-UserDesktopDirectory'
  'work' = 'Push-UserWorkingDirectory'
  'project' = 'Push-UserProjectDirectory'
  'doc' = 'Push-UserDocDirectory'
  'repo' = 'Push-UserRepositoryDirectory'
  'll' = 'Get-UserAutoSizedDirectory'
  'psgip' = 'Get-UserGlobalIpAddress'
  'usetemp' = 'Use-UserTemporaryDirectory'
  'enpsg' = 'Enable-PSGallery'
  'apppath' = 'Get-AppPath'
  'oscmd' = 'Invoke-OSCommand'

  # Module management
  'psmget' = 'Get-UserModule'
  'psmout' = 'Out-UserModule'
  'psmtest' = 'Test-UserModule'
  'psmload' = 'Install-UserModule'
  'psmrm' = 'Remove-UserModule'
  'psmopt' = 'Optimize-UserModule'

  # Variable management
  'gva' = 'Get-UserAssignedVariable'
  'rva' = 'Remove-UserAssignedVariable'
  'def' = 'Get-UserDefaultVariable'
}

foreach ($m in $map.GetEnumerator()) {
  Set-Alias -Name $m.Key -Value $m.Value
}
Remove-Variable -Name m, map -Force
