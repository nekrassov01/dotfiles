#!/bin/sh

set -eu

# load: helper
if ! . "$HOME/.bash.d/.bash.init"; then
  print_err "Load required settings failed."
  exit 1
fi

# bundle file path
bundle_file="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/manifests/Pwshfile"

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

# check: module list exists
if [ ! -f "$bundle_file" ]; then
  print_err "'$bundle_file' does not exists."
  exit 1
fi

# check: trust psgallery if not trusted
print_info "Enable access to PSGallery"
pwsh -c "try { Enable-PSGallery *>\$null } catch { throw 'Problem occurred when trusting PSGallery' }"

# install: pwsh user-selected modules
print_info "Installing pwsh modules based on $(color green)$bundle_file$(color reset)"
pwsh -c "try { Install-UserModule -ModuleList $bundle_file *>\$null } catch { throw 'pwsh install failed' }"

# update: pwsh user-selected modules
print_info "Updating and cleaning pwsh modules"
pwsh -c "try { Optimize-UserModule -ModuleList $bundle_file *>\$null } catch { throw 'pwsh install failed' }"

# closing
print_success "PowerShell configuration finished"
echo
