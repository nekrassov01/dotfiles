#!/bin/sh

set -eu

# load: helper
if ! . "$HOME/.bash.init"; then
  print_err "Load required settings failed."
  exit 1
fi

# tools bundling directory
tool_dir="$(dirname "$(chezmoi source-path)")/tools"

# opening
echo
print_header "Init: PowerShell configuration"

# required: pwsh
chk pwsh

print_info "Updating PowerShell"

# run: update
if ! brew upgrade powershell --cask 1>/dev/null; then
  print_warn "PowerShell update failed."
fi

# check: Pwshfile exists
if [ ! -f "$tool_dir/Pwshfile" ]; then
  print_err "'$tool_dir/Pwshfile' does not exists."
  exit 1
fi

# check: trust psgallery if not trusted
print_info "Enable access to PSGallery"
pwsh -c "try { Enable-PSGallery *>\$null } catch { throw 'Problem occurred when trusting PSGallery' }"

# install: pwsh user-selected modules
print_info "Installing pwsh modules based on $(color green)$tool_dir/Pwshfile$(color reset)"
pwsh -c "try { Install-UserModule -ModuleList $tool_dir/Pwshfile *>\$null } catch { throw 'pwsh install failed' }"

# update: pwsh user-selected modules
print_info "Updating and cleaning pwsh modules"
pwsh -c "try { Optimize-UserModule -ModuleList $tool_dir/Pwshfile *>\$null } catch { throw 'pwsh install failed' }"

# closing
print_success "PowerShell configuration finished"
echo
