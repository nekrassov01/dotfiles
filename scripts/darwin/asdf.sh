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
print_header "Init: asdf configuration"

# required: asdf git
chk asdf git

# check: Asdffile exists
if [ ! -f "$tool_dir/Asdffile" ]; then
  print_err "'$tool_dir/Asdffile' does not exists."
  exit 1
fi

print_info "Installing asdf plugins"

# install: plugins
while read -r line; do
  plugin=$(echo "$line" | cut -d " " -f 1)

  print_info "Adding $plugin"

  current=$(echo "$line" | cut -d " " -f 2)
  latest=$(asdf latest "$plugin")

  # current or latest version
  if [ "$*" = latest ]; then
    version=$latest
  else
    version=$current
  fi

  ! asdf plugin add "$plugin" >/dev/null 2>&1 && :

  print_info "-> Installing $plugin $version"

  if ! asdf install "$plugin" "$version" 1>/dev/null; then
    print_err "$plugin install failed."
    exit 1
  fi

  print_info "-> Globalizing $plugin $version"

  if ! asdf global "$plugin" "$version" 1>/dev/null; then
    print_err "$plugin globalizing failed."
    exit 1
  fi

  print_info "-> Reshimming $plugin $version"

  if ! asdf reshim "$plugin" 1>/dev/null; then
    print_err "$plugin reshimming failed."
    exit 1
  fi
done <"$tool_dir/Asdffile"
unset plugin version line

# write back new versions
if [ "$*" = latest ]; then
  cat "$HOME/.tool-versions" >"$tool_dir/Asdffile"
fi

# closing
print_success "asdf configuration finished"
echo
