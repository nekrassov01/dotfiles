#!/bin/sh

# inspired by https://github.com/twpayne/dotfiles/blob/master/install.sh

set -eu

ensure_chezmoi() {
  bin_dir="$HOME/.local/bin"
  chezmoi="$bin_dir/chezmoi"
  mkdir -p "$bin_dir"
  if [ "$(command -v chezmoi)" ]; then
    return
  fi
  if [ "$(command -v curl)" ]; then
    sh -c "$(curl -fsSL https://git.io/chezmoi)" -- -b "$bin_dir"
    return
  fi
  if [ "$(command -v wget)" ]; then
    sh -c "$(wget -qO- https://git.io/chezmoi)" -- -b "$bin_dir"
    return
  fi
  echo "cannot install chezmoi because curl and wget are missing" >&2
  exit 1
}

ensure_chezmoi
chezmoi=$(command -v chezmoi)
script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"
exec "$chezmoi" init --apply "--source=$script_dir"
