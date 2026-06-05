#!/bin/sh

set -eu

# load: helper
if ! . "$HOME/.bash.d/.bash.init"; then
  print_err "Load required settings failed."
  exit 1
fi

# opening
echo
print_header "Init: mise configuration"

# required: mise brew
chk mise brew

print_info "Updating mise"

# run: update
if ! brew upgrade mise 1>/dev/null; then
  print_warn "mise update failed."
fi

print_info "Upgrading mise"

# run: upgrade
if ! mise upgrade 1>/dev/null; then
  print_warn "mise upgrade failed."
fi

# check: mise config exists
if [ ! -f "$HOME/.config/mise/config.toml" ]; then
  print_err "'$HOME/.config/mise/config.toml' does not exists."
  exit 1
fi

print_info "Installing mise tools"

# install: tools defined in config.toml
mise install

print_info "Cleaning mise"

if ! mise cache clear 1>/dev/null; then
  print_warn "mise cleanup failed."
fi

# closing
print_success "mise configuration finished"
echo
