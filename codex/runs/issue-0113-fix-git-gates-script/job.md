# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0113
- Short Title: Fix codex/tools/git_gates.ps1 quoting + review-gate output
- Run Folder Name: issue-0113-fix-git-gates-script
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-02-23

---

## Goal
Fix `codex/tools/git_gates.ps1` so it parses correctly in PowerShell and consistently prints staged Review Gate diff output in both Preflight (when staged changes exist) and Postflight.

---

## Invariants (Must Hold After This Job)
- Script remains read-only for git operations used in gates.
- Preflight still prints required repository state commands.
- Postflight still prints closeout proof commands.
- No repository data, gameplay code, or save schema is modified.

---

## Non-Goals
- Do not change game logic or audit logic.
- Do not modify any files outside whitelist and run artifacts.
- Do not alter commit/push behavior beyond gate output handling.

---

## Context
`codex/tools/git_gates.ps1` was malformed (`''Preflight''` quoting) and failed to parse, forcing manual preflight command execution. A local fix now exists and should be closed out under a dedicated issue.

---

## Proposed Approach
- Keep and formalize the script quoting fix.
- Keep and formalize helper functions for optional git execution and staged review diff output.
- Ensure preflight and postflight behavior remains deterministic and transparent.

---

## Files: Allowed to Modify (Whitelist)
- `codex/tools/git_gates.ps1`

## Files: Forbidden to Modify (Blacklist)
- `data/**`
- `scenes/MainGame.tscn`

---

## New Files Allowed?
- [x] Yes
- [ ] No

If Yes, list exact new file paths:
- `codex/runs/issue-0113-fix-git-gates-script/job.md`
- `codex/runs/issue-0113-fix-git-gates-script/results.md`

---

## Public API Changes
- None

---

## Data Model & Persistence
- New or changed saved fields: None
- Migration / backward-compat expectations: None
- Save/load verification requirements: None

---

## Determinism & Stability (If Applicable)
- Gate output sections should remain deterministic for the same git state.
- No time/random-based behavior introduced.

---

## Acceptance Criteria (Must Be Testable)
- [ ] `powershell -ExecutionPolicy Bypass -File codex/tools/git_gates.ps1 -Mode Preflight` runs without parse errors.
- [ ] Preflight shows review-gate staged diff info (or explicit "no staged changes").
- [ ] Postflight prints staged file list/stat/full staged diff before proof commands.

---

## Manual Test Plan
1. Run preflight wrapper and confirm no parser error.
2. Stage at least one file and run preflight wrapper; verify staged review-gate output is shown.
3. Run postflight wrapper; verify staged diff outputs then proof outputs.

---

## Risks / Notes
- If any gate output differs from expected policy, adjust script labels/messages only within whitelist.

---

## Governance & Review Gates (Mandatory)
- Codex must not make code changes until preflight/review steps are complete.
- Codex must present diffs for review before finalizing results.

---

## Git Preflight Gate (Mandatory)
Executed via required git commands before this closeout.

## Git Postflight & Closeout Gate (Mandatory)
- Stage ONLY:
  - `codex/runs/ACTIVE_RUN.txt`
  - `codex/runs/issue-0113-fix-git-gates-script/**`
  - `codex/tools/git_gates.ps1`
- Show staged diffs.
- Commit and push.

---

## Logging Checklist
- [x] No debug spam added
- [x] No meaningful logs removed
- [x] `print()` removed or debug-only
- [x] Log volume appropriate
