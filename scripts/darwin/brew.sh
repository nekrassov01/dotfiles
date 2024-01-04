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
print_header "Init: homebrew configuration"

print_info "Installing homebrew"

# install: homebrew
if ! has brew; then
  case "$(uname -m)" in
  x86_64)
    if ! mkdir "$HOME/.homebrew" && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C "$HOME/.homebrew"; then
      print_err "brew install failed for x86_64."
      exit 1
    fi
    ;;
  arm64)
    if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
      print_err "brew install failed for arm64."
      exit 1
    fi
    ;;
  *)
    print_Err "cannot install homebrew"
    exit 1
    ;;
  esac
fi

print_info "Updating homebrew"

# run: update
if ! brew update 1>/dev/null; then
  print_warn "brew update failed."
fi

print_info "Upgrading homebrew"

# run: upgrade
if ! brew upgrade 1>/dev/null; then
  print_warn "brew upgrade failed."
fi

# check: Brewfile exists
if [ ! -f "$tool_dir/Brewfile" ]; then
  print_err "'$tool_dir/Brewfile' does not exists."
  exit 1
fi

print_info "Installing modules based on $(color green)$tool_dir/Brewfile$(color reset)"

# install: based on Brewfile
if ! brew bundle --file "$tool_dir/Brewfile" --no-lock --force; then
  print_err "Install modules based on Brewfile failed."
  exit 1
fi

# run: cleanup
! brew cleanup 1>/dev/null && print_warn "brew cleanup failed."

# check: Brewfile dependencies
if ! brew bundle check --file "$tool_dir/Brewfile" 1>/dev/null; then
  print_err "Brewfile's dependencies are not satisfied."
  exit 1
fi

# brew directory
brew_prefix="$(brew --prefix)"

# run: replace symbolic links of sha*sum with GNU tools
if brew list coreutils >/dev/null 2>&1; then
  for i in 224 256 384 512; do
    if ! ln -sfnv "${brew_prefix}/bin/gsha${i}sum" "${brew_prefix}/bin/sha${i}sum" 1>/dev/null; then
      print_err "Create symlink of gsha${i}sum failed."
      exit 1
    fi
  done
fi

# closing
print_success "homebrew configuration finished"
echo
