---
name: review-pr
description: Review a GitHub pull request given by URL for critical defects only, write the result to docs/review/pr-<number>.md, and keep docs/review out of git via .git/info/exclude. Use when the user asks to review a PR, passes a pull request URL for review, or invokes /review-pr <url>. Verifies gh authentication first, reads the diff statically (no dependency install, no test run, no branch checkout), and reports nothing below critical severity.
---

# Review PR

Review the pull request at `$ARGUMENTS` (a GitHub pull request URL) and record only critical findings. The reader wants a short go/no-go signal, not a list of style remarks, so everything below critical stays out of the report.

## Workflow

1. Confirm GitHub CLI access.
   - Run `gh auth status`. Stop and tell the user to run `gh auth login` if no account is active.
   - Check that the active account matches the repository owner when several accounts are logged in. Suggest `gh auth switch --user <name>` if not.
2. Resolve the target.
   - Parse owner, repository, and PR number from the URL.
   - Confirm the current directory is a clone of that repository (`git remote -v`). If not, stop and ask where to run.
   - Run `gh pr view <url> --json number,title,body,author,baseRefName,headRefName,state,files,additions,deletions`.
3. Read the change statically.
   - `git fetch origin <base> <head>` and diff with `git diff origin/<base>...origin/<head>`.
   - Read files on the branch with `git show origin/<head>:<path>`. Do not check out the branch, create a worktree, install dependencies, or run tests. The working tree must stay untouched. If the user explicitly asks for a test run, do it in a separate worktree and remove it afterwards.
   - Read the PR body carefully. It usually states root cause, scope, and known risks. Treat its claims as hypotheses to verify, not as facts.
   - Follow every changed contract to its consumers: callers in this repository, and sibling repositories under the same parent directory when the change touches data that another service reads or writes (saved JSON shape, API payloads, environment-specific keys). A frontend change that alters what gets persisted is only safe if the backend reads it the same way.
   - Compare with the previous implementation when the PR replaces legacy behavior, so that a silently dropped field or changed default is caught.
4. Decide what is critical. A finding is critical when it causes any of the following on a normal path, or on a path the PR explicitly claims to fix:
   - data loss, data corruption, or persisted values that another component misreads
   - a crash, hang, or unrecoverable UI state
   - a security or authorization defect
   - behavior that contradicts the PR's stated goal
   Everything else (naming, duplication, test style, minor edge cases already acknowledged in the PR body) is not reported. Risks the author already lists in the PR are not findings; mention them in notes only when the analysis changes their severity.
5. Write `docs/review/pr-<number>.md` in the language the user uses in chat.
   - Copy the structure from `assets/template.md` (relative to this skill's directory) and fill every placeholder. Drop the `指摘` section when there is no finding.
   - Cite evidence as `path:line` so the reader can jump to it. State plainly what was not verified.
   - Write the file with the Write tool rather than a shell heredoc. Review text often contains words such as "key" or "secret" that the organization's command deny list matches, and a heredoc is blocked as a whole.
6. Keep `docs/review/` out of git.
   - Run `git check-ignore -q docs/review/pr-<number>.md`. If it is not ignored, append `docs/review/` to `.git/info/exclude`. Do not edit `.gitignore`; the directory is a local artifact and must not show up in anyone's diff.
   - Confirm with `git status --short` that nothing tracked changed.
7. Report in chat: the conclusion, the output path, and anything left unverified. Do not repeat the whole document.

## Guardrails

- Do not comment on, approve, or otherwise modify the pull request on GitHub.
- Do not modify tracked files, switch branches, or leave temporary worktrees behind.
- Do not install dependencies or run the test suite unless the user asks for it in this conversation.
- Replace customer or project names with placeholders if the review text is ever to be shared outside the repository; the local file may keep them.
