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

# check: .tool-versions exists
if [ ! -f "$HOME/.tool-versions" ]; then
  print_err "'$HOME/.tool-versions' does not exists."
  exit 1
fi

print_info "Installing mise tools"

# install: plugins
mise install

print_info "Cleaning mise"

if ! mise cache clear 1>/dev/null; then
  print_warn "mise cleanup failed."
fi

# closing
print_success "asdf configuration finished"
echo
