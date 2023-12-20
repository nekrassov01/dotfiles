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
print_header "Init: python configuration"

# required: asdf python pip
chk asdf python pip

print_info "Updating pip"

if ! pip install --upgrade pip 1>/dev/null; then
  print_warn "pip upgrade failed."
fi

# check: Pyfile exists
if [ ! -f "$tool_dir/Pyfile" ]; then
  print_err "'$tool_dir/Pyfile' does not exists."
  exit 1
fi

print_info "Installing modules based on $(color green)$tool_dir/Pyfile$(color reset)"

# install: based on Pyfile
if ! pip install --no-cache-dir --no-input --quiet -r "$tool_dir/Pyfile"; then
  print_err "Install modules based on Pyfile failed."
  exit 1
fi

print_info "Cleaning pip"

if ! pip cache purge 1>/dev/null; then
  print_warn "pip cleanup failed."
fi

# closing
print_success "python configuration finished"
echo
