#!/bin/sh

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
print_header "Init: rye configuration"

# required: mise
chk mise

print_info "Getting mise tools prefix"

if ! version="$(mise list rye --no-header | tr -s ' ' | cut -d ' ' -f2)"; then
  print_err "failed to get rye path prefix"
  exit 1
fi

cmd=$HOME/.local/share/mise/installs/rye/$version/bin/rye

print_info "Updating rye"

# run: update
if ! $cmd self update 1>/dev/null; then
  print_warn "rye update failed."
fi

# check: Ryefile exists
if [ ! -f "$tool_dir/Ryefile" ]; then
  print_err "'$tool_dir/Ryefile' does not exists."
  exit 1
fi

print_info "Installing modules based on $(color green)$tool_dir/Ryefile$(color reset)"

# install: based on Ryefile
while IFS= read -r line; do
  if ! $cmd install --force "$(echo "$line" | sed 's/ /==/')" 1>/dev/null; then
    print_err "$line install failed."
    exit 1
  fi
done <"$tool_dir/Ryefile"

# closing
print_success "rye configuration finished"
echo
