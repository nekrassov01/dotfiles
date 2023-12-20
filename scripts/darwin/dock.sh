#!/bin/sh
# -------------------------------------------
#  NOTE:
#  dockutil on brew is outdated currentlly,
#  download it from the repository.
# -------------------------------------------

set -eu

# load: helper
if ! . "$HOME/.bash.init"; then
  print_err "Load required settings failed."
  exit 1
fi

# tools bundling directory
tool_dir="$(dirname "$(chezmoi source-path)")/tools"

cmd=dockutil

# opening
echo
print_header "macOS: Dock configuration"

## required: curl and jq
chk curl jq

if ! has $cmd; then
  print_note "Getting package because required tool $cmd not found"

  # sudo in upfront
  sudo -v

  print_info "Getting latest version tag"

  repo_author='kcrawford'
  repo_name=$cmd
  version=$(get_github_latest_version $repo_author $repo_name)
  dwonload_uri="https://github.com/$repo_author/$repo_name/releases/download/$version"
  download_file="$cmd-$version.pkg"

  print_info "Downloading $cmd from $(color green)$dwonload_uri$(color reset)"

  if ! curl -OL "$dwonload_uri/$download_file" 2>/dev/null; then
    print_err "$cmd download via github failed."
    exit 1
  fi

  print_info "Installing $download_file"

  if ! sudo installer -pkg "$download_file" -target / 1>/dev/null; then
    print_err "$cmd install failed."
    exit 1
  fi

  print_info "Removing $download_file"

  if ! rm "$download_file"; then
    print_err "$cmd remove failed."
    exit 1
  fi

  print_info "Optimizing $cmd path"

  dockutil_dst_prefix="/usr/local/dockutil"
  dockutil_bin_prefix="/usr/local/bin"
  sudo mkdir -p "$dockutil_dst_prefix" && sudo chown "$(whoami)":admin "$dockutil_dst_prefix"

  if ! cp -f "$dockutil_bin_prefix/$cmd" "$dockutil_dst_prefix/$cmd"; then
    print_err "dockutil optimize path failed."
    exit 1
  fi

  print_info "Optimizing $cmd link"

  if ! ln -sfn "$dockutil_dst_prefix/$cmd" "$dockutil_bin_prefix/$cmd"; then
    print_err "dockutil optimize link failed."
    exit 1
  fi
else
  print_note "Skip getting package because required tool $cmd found"
fi

# required: $cmd
chk "$cmd"

print_info "Setting up Dock members based on $(color green)$tool_dir/Dockfile$(color reset)"

# Clean up macOS Dock
$cmd --no-restart --remove all

# Setting up macOS Dock
while read -r line; do
  print_info "-> $line"
  if ! $cmd --no-restart --add "$line" 1>/dev/null; then
    print_err "Adding Dock to $line failed."
    exit 1
  fi
done <"$tool_dir/Dockfile"

print_info "Killall Dock process"

killall Dock

# closing
print_success "macOS Dock configuration finished"
echo
