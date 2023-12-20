#!/bin/sh
set -eu

# load: helper
if ! . "$HOME/.bash.init"; then
  print_err "Load required settings failed."
  exit 1
fi

# opening
echo
print_header "Init: xcode-select"

print_info "Installing xcode-select"

# install: xcode-select
if ! xcode-select -p 1>/dev/null; then
  sudo -v
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &
  if ! xcode-select --install 1>/dev/null; then
    print_err "xcode-select install failed."
    exit 1
  fi
fi

# closing
print_success "xcode-select configuration finished"
echo
