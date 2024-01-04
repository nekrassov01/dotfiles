#!/bin/sh
# shellcheck disable=SC2046

set -eu

# load: helper
if ! . "$HOME/.bash.init"; then
  print_err "Load required settings failed."
  exit 1
fi

# tools bundling directory
tool_dir="$HOME/.tools"

# opening
echo
print_header "Init: nodejs configuration"

# required: mise node npm
chk mise node npm

print_info "Updating npm"

# run: update
if ! npm update -g 1>/dev/null; then
  print_warn "npm update failed."
fi

# check: Nodefile exists
if [ ! -f "$tool_dir/Nodefile" ]; then
  print_err "'$tool_dir/Nodefile' does not exists."
  exit 1
fi

print_info "Installing modules based on $(color green)$tool_dir/Nodefile$(color reset)"

if ! npm install -g $(cat "$tool_dir"/Nodefile) 1>/dev/null; then
  print_err "Install modules based on Nodefile failed."
  exit 1
fi

print_info "Cleaning npm"

if ! (npm cache clean --force >/dev/null 2>&1 && npm cache verify 1>/dev/null); then
  print_warn "npm cleanup failed."
fi

rm -rf "$HOME/.npm"

# closing
print_success "nodejs configuration finished"
echo
