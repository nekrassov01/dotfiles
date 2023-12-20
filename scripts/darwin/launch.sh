#!/bin/sh

set -eu

# load: helper
if ! . "$HOME/.bash.init"; then
  print_err "Load required settings failed."
  exit 1
fi

# opening
echo
print_header "launchd: launchd tasks"

print_info "Setting up syncbundle"

launchctl load "$HOME/Library/LaunchAgents/nekrassov01.syncbundle.plist" >/dev/null 2>&1

# closing
print_success "syncbundle configuration finished"
echo
