#!/bin/sh
# shellcheck disable=SC2088

set -eu

# load: helper
if ! . "$HOME/.bash.d/.bash.init"; then
  print_err "Load required settings failed."
  exit 1
fi

# opening
echo
print_header "Init: git configuration"

# git default global config path
git_config_prefix="$HOME/.config/git"

# check: default global git configuration files exist and are symbolic links
for file in config ignore attributes; do
  if [ ! -f "$git_config_prefix/$file" ]; then
    print_warn "Cannot find '$file'"
  fi
done

print_info "Setting up git"

for i in name email; do
  if
    ! git config --global user."$i" >/dev/null 2>&1
  then
    printf "$(color byellow)INPUT: $(color reset)user.%s: " "$i"
    read -r def
    if [ -z "$def" ]; then
      print_warn "No $i has been set. Set it later"
    else
      git config --global user."$i" "$def"
    fi
  fi
done
unset def i

if has ghq; then
  git config --global ghq.root "~/.repository"
fi

# closing
print_success "git configuration finished"
echo
