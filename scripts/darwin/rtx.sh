#!/bin/sh

set -eu

# load: helper
if ! . "$HOME/.bash.init"; then
  print_err "Load required settings failed."
  exit 1
fi

# opening
echo
print_header "Init: asdf configuration"

# required: rtx brew
chk rtx brew

print_info "Updating rtx"

# run: update
if ! brew upgrade rtx 1>/dev/null; then
  print_warn "rtx update failed."
fi

print_info "Upgrading rtx"

# run: upgrade
if ! rtx upgrade 1>/dev/null; then
  print_warn "rtx upgrade failed."
fi

# check: .tool-versions exists
if [ ! -f "$HOME/.tool-versions" ]; then
  print_err "'$HOME/.tool-versions' does not exists."
  exit 1
fi

print_info "Installing rtx tools"

# install: plugins
rtx install

print_info "Cleaning rtx"

if ! rtx cache clear 1>/dev/null; then
  print_warn "rtx cleanup failed."
fi

# closing
print_success "asdf configuration finished"
echo
