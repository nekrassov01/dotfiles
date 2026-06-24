#!/bin/sh
# PreToolUse hook: block writes to sensitive files

set -eu

input=$(cat)

file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')

[ -z "$file_path" ] && exit 0

case "$file_path" in
  */.aws/credentials | */.aws/config)
    reason="Protected: AWS config file" ;;
  */.envrc | */.env | *.env | *.env.*)
    reason="Protected: environment variable file" ;;
  *id_rsa* | *id_ed25519* | *id_ecdsa*)
    reason="Protected: SSH key file" ;;
  *.pem | *.key | *.p12 | *.pfx | *.jks)
    reason="Protected: certificate/key file" ;;
  *credentials* | *secrets* | *secret.*)
    reason="Protected: credentials/secrets file" ;;
  *)
    exit 0 ;;
esac

printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}' "$reason"
