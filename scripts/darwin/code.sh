#!/bin/sh
# shellcheck disable=SC2034
# -------------------------------------------------------------------
#  NOTE:
#  This script parses settings.json with jq.
#  If settings.json contains comments,
#  they are removed before parsing,
#  but this may not work depending on how the comments are written.
# -------------------------------------------------------------------

set -eu

# load: helper
if ! . "$HOME/.bash.d/.bash.init"; then
  print_err "Load required settings failed."
  exit 1
fi

# bundle file path
bundle_file="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/manifests/Codefile"

# brew directory
brew_prefix="$(brew --prefix)"

# opening
echo
print_header "Init: vscode configuration"

# required: jq
chk jq perl

setting_file="$HOME/Library/Application Support/Code/User/settings.json"
setting_file_content=$(sed -e 's|//.*$||g' -e 's|\\n|\\\\n|g' <"$setting_file" | perl -0pe 's/,(\s*[}\]])/$1/g')
code_bin="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"

print_info "Creating symlink for $(color green)$code_bin$(color reset)"

# run: create symbolic link for command `code`
if ! has code; then
  if ! ln -sfn "$code_bin" "$brew_prefix/bin/code"; then
    print_err "\`code\` link to '$code_bin' failed."
    exit 1
  fi
fi

# check: Codefile exists
if [ ! -f "$bundle_file" ]; then
  print_err "'$bundle_file' does not exists."
  exit 1
fi

# note: `code --install-extension` required '{"http.proxyStrictSSL": false}' at settings.json in many cases
# check: http.proxyStrictSSL takes one of the following values: true, false and null
ssl_check_file="$TMPDIR"'vscode_ssl_check'

# If the check file remains and its contents are empty, delete it.
if [ -e "$ssl_check_file" ] && [ -z "$ssl_check_file" ]; then
  rm "$ssl_check_file"
fi

# Create check file, if absent
if [ ! -e "$ssl_check_file" ]; then
  touch "$ssl_check_file"
  echo "$setting_file_content" | jq '."http.proxyStrictSSL"' >"$ssl_check_file"
fi

ssl_check=$(cat "$ssl_check_file")

# Get indent size (default 2 if unset, null, or non-numeric)
tab_size=$(echo "$setting_file_content" | jq -r '."editor.tabSize" // 2' 2>/dev/null)
case "$tab_size" in
  '' | *[!0-9]*) tab_size=2 ;;
  *) ;;
esac

# Backup original vscode settings
cp -f "$setting_file" "$setting_file.bk"

# run: disable checking for ssl
if [ -z "$ssl_check" ] || [ "$ssl_check" = 'null' ]; then
  echo "$setting_file_content" | jq '. |= .+ {"http.proxyStrictSSL": false}' --indent "$tab_size" >tmpfile
  mv tmpfile "$setting_file"
fi

if [ "$ssl_check" = 'true' ]; then
  echo "$setting_file_content" | jq '."http.proxyStrictSSL" |= false' --indent "$tab_size" >tmpfile
  mv tmpfile "$setting_file"
fi

print_info "Installing extensions based on $(color green)$bundle_file$(color reset)"

# install: user-selected extensions
while read -r line; do
  print_info "-> $line"
  if ! code --install-extension "$line" --force 1>/dev/null; then
    print_err "'$line' install failed."
    exit 1
  fi
done <"$bundle_file"

# Restore settings
mv -f "$setting_file.bk" "$setting_file"

# Clean up temorary file
rm "$ssl_check_file"

# closing
print_success "vscode configuration finished"
echo
