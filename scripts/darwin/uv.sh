#!/bin/sh

set -eu

# load: helper
if ! . "$HOME/.bash.d/.bash.init"; then
  print_err "Load required settings failed."
  exit 1
fi

# bundle file path
bundle_file="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/manifests/Uvfile"

# opening
echo
print_header "Init: uv configuration"

# required: mise
chk mise

print_info "Resolving uv installed by mise"

# resolve the uv binary managed by mise
if ! cmd="$(mise which uv)"; then
  print_err "failed to resolve uv via mise."
  exit 1
fi

# check: Uvfile exists
if [ ! -f "$bundle_file" ]; then
  print_err "'$bundle_file' does not exists."
  exit 1
fi

print_info "Installing uv tools based on $(color green)$bundle_file$(color reset)"

# install: based on Uvfile
while IFS= read -r line; do
  case "$line" in
  '' | \#*)
    # skip blank lines and '#' comments
    continue
    ;;
  *)
    print_info "-> $line"
    if ! "$cmd" tool install --force "$line" 1>/dev/null; then
      print_err "$line install failed."
      exit 1
    fi
    ;;
  esac
done <"$bundle_file"

# closing
print_success "uv configuration finished"
echo
