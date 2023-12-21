#!/bin/sh
# shellcheck disable=SC2046

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
print_header "Init: nodejs configuration"

# required: asdf node npm
chk asdf node npm

print_info "Updating npm"

if ! npm update -g npm 1>/dev/null; then
  print_warn "npm update failed."
fi

# check: Nodefile exists
if [ ! -f "$tool_dir/Nodefile" ]; then
  print_err "'$tool_dir/Nodefile' does not exists."
  exit 1
fi

print_info "Unlocking strict SSL"

# avoid SSL errors
npm config set strict-ssl false -g

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
