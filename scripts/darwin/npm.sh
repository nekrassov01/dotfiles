#!/bin/sh
# shellcheck disable=SC2046

set -eu

# load: helper
if ! . "$HOME/.bash.d/.bash.init"; then
  print_err "Load required settings failed."
  exit 1
fi

# bundle file path
bundle_file="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/manifests/Nodefile"

# opening
echo
print_header "Init: nodejs configuration"

# required: mise
chk mise

print_info "Getting mise tools prefix"

# resolve the npm binary managed by mise
if ! cmd="$(mise which npm)"; then
  print_err "failed to resolve npm via mise."
  exit 1
fi

print_info "Updating npm"

# run: update
if ! $cmd update --global 1>/dev/null; then
  print_warn "npm update failed."
fi

# check: Nodefile exists
if [ ! -f "$bundle_file" ]; then
  print_err "'$bundle_file' does not exists."
  exit 1
fi

print_info "Installing modules based on $(color green)$bundle_file$(color reset)"

# install: based on Nodefile
while IFS= read -r line; do
  case "$line" in
  '' | \#*)
    # skip blank lines and '#' comments
    continue
    ;;
  *)
    print_info "-> $line"
    if ! "$cmd" install --global "$line" 1>/dev/null; then
      print_err "$line install failed."
      exit 1
    fi
    ;;
  esac
done <"$bundle_file"

print_info "Cleaning npm"

if ! ($cmd cache clean --force >/dev/null 2>&1 && $cmd cache verify 1>/dev/null); then
  print_warn "npm cleanup failed."
fi

rm -rf "$HOME/.npm"

# closing
print_success "nodejs configuration finished"
echo
