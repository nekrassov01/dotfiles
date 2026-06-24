#!/bin/sh
# SessionStart hook: inject git context

set -eu

# Skip if not in a git repository
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

printf 'Current branch: %s\n\n' "$(git branch --show-current 2>/dev/null || echo 'detached')"

printf 'Recent commits:\n'
git log --oneline -10 2>/dev/null || true

printf '\nStatus:\n'
git status -s -b 2>/dev/null || true
