#!/bin/sh
# PreToolUse hook: block destructive commands and secret file reads

set -eu

input=$(cat)

tool_name=$(printf '%s' "$input" | jq -r '.tool_name // empty')
[ "$tool_name" = "Bash" ] || exit 0

command=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
[ -n "$command" ] || exit 0

deny() {
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}' "$1"
  exit 0
}

# Deny destructive commands
case "$command" in
  *"rm -rf"*)
    deny "Blocked: recursive delete" ;;
  *"git push"*" main"* | *"git push"*" master"* | *"git push"*":main"* | *"git push"*":master"*)
    deny "Blocked: git push to main/master" ;;
  *"git push --force"* | *"git push -f"*)
    deny "Blocked: git force push" ;;
  *"git reset --hard"*)
    deny "Blocked: git hard reset" ;;
  *"git clean -f"*)
    deny "Blocked: git cleanup" ;;
  *"DROP TABLE"* | *"DROP DATABASE"* | *"TRUNCATE "*)
    deny "Blocked: destructive SQL" ;;
  *"cdk deploy"* | *"cdk destroy"*)
    deny "Blocked: cdk" ;;
  *"terraform destroy"* | *"terraform apply"*)
    deny "Blocked: terraform" ;;
  *"kubectl delete"* | *"kubectl apply"*)
    deny "Blocked: kubectl" ;;
  *) ;;
esac

# Deny reading sensitive files
for pattern in \
  'cat *.env' 'cat */.env' 'cat *credentials*' 'cat *secrets*' \
  'cat */.aws/credentials' 'cat *id_rsa*' 'cat *id_ed25519*' \
  'cat *.pem' 'cat *.key'; do
  case "$command" in
    *$pattern*)
      deny "Blocked: reading sensitive file" ;;
    *) ;;
  esac
done
