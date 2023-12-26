#!/bin/sh

set -eu

# load: helper
if ! . "$HOME/.bash.init"; then
  print_err "Load required settings failed."
  exit 1
fi

# brew directory
brew_prefix="$(brew --prefix)"

# opening
echo
print_header "Init: bash configuration"

# define: bash path installed by brew
bash_path_installed_by_brew="$brew_prefix/bin/bash"

# check: bash installed by brew exists
if [ ! -f "$bash_path_installed_by_brew" ]; then
  print_err "'$bash_path_installed_by_brew' does not exists."
  exit 1
fi

# edit: add bash path installed by brew to "/etc/shells"
if ! (grep -e "$bash_path_installed_by_brew" <"/etc/shells" >/dev/null 2>&1); then
  echo "$bash_path_installed_by_brew" | sudo tee -a "/etc/shells"
fi

print_info "Switching login shell"

# run: change login shell
if ! chsh -s "$bash_path_installed_by_brew" 1>/dev/null; then
  print_err "Login shell switching failed."
  exit 1
fi

# closing
print_success "bash configuration finished"
echo
