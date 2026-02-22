# Bugfix Job

## Metadata (Required)
- Issue/Task ID: issue-0104
- Short Title: Add not_evaluable reason details to Level 2 invariant results
- Run Folder Name: issue-0104-bug-l2-invariants-not-evaluable-reasons
- Job Type: bugfix
- Author (human): Douglass Kyd
- Date: 2026-02-22

---

## Bug Description
When a customs inspection reaches **Level 2 depth**, the report shows `level2_audit present` and a non-zero invariant count, but invariants frequently return `status == not_evaluable` even in scenarios where the player intentionally creates a **doc vs cargo quantity mismatch**. This yields:
- `findings == 0`
- and an unhelpful summary like “none found,”
making it impossible to diagnose *which required inputs are missing* from the evaluation context.

This is an observability gap in invariant results: `not_evaluable` provides no clear reason.

---

## Expected Behavior
When an invariant returns `status == not_evaluable`, it should include a deterministic, minimal explanation (e.g., in `details.reason` and/or `details.missing_inputs`) indicating why it could not be evaluated (missing ctx keys, empty arrays, missing fields on doc lines, etc.).

This must not change invariant pass/fail logic when inputs are present; it only enriches `not_evaluable` results.

---

## Repro Steps
Provide the minimal steps required to reproduce the issue reliably.

1. Start a game state that can produce a customs inspection that reaches **Level 2 depth**.
2. Create a deterministic **doc vs cargo quantity mismatch** (declared qty differs from actual cargo qty).
3. Trigger an entry clearance inspection and observe Level 2 output:
   - `level2_audit present; invariants=N, findings=0`
   - samples show `not_evaluable`

---

## Observed Output / Error Text
Example (post-0103 diagnostics):
`Level-2 invariants: none found (level2_audit present; invariants=4, findings=0, sample=L2INV-001[not_evaluable/none], ...).`

---

## Suspected Area (Optional)
- `res://scripts/customs/CustomsInvariants.gd`
  - invariant evaluation guards that return `not_evaluable` due to missing/empty inputs
  - current invariant result dictionaries lack “why not evaluable” details

---

## Scope Constraints
- Changes are limited strictly to fixing the described bug.
- No refactors, cleanup, stylistic changes, or redesigns.
- No new features may be introduced.
- Do NOT change inspection triggers, enforcement, cargo/docs state, or time advancement.
- Do NOT change invariant semantics when inputs are available; only add deterministic detail to `not_evaluable` outputs.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `res://scripts/customs/CustomsInvariants.gd`

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/MainGame.tscn`

---

## New Files Allowed?
- [ ] Yes (must list exact paths below)
- [x] No

If Yes, list exact new file paths:

-
-

---

## Acceptance Criteria (Must Be Testable)
All items must pass for the fix to be considered complete.

- [ ] Any invariant result with `status == "not_evaluable"` includes deterministic diagnostic detail in `details`:
  - `details.reason` (short string)
  - and optionally `details.missing_inputs` (stable array of strings)
- [ ] Diagnostics are stable/deterministic for identical inputs (no timestamps, no randomness, stable ordering for any arrays).
- [ ] When inputs are present and an invariant evaluates to pass/fail, behavior is unchanged (only `not_evaluable` results are enriched).

---

## Regression Checks
List behaviors that must still work after the fix.

- Level 2 invariant ids, statuses, and severities remain unchanged for pass/fail cases.
- Existing report formatting continues to work (no crashes if `details` is absent/present).
- No increase in per-frame spam: only invariant result payload changes, not log volume.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the fix.

1. Reproduce the doc vs cargo quantity mismatch scenario that reaches Level 2 depth.
2. Observe the Level 2 invariant samples (via existing diagnostics / any UI surfacing) and confirm:
   - invariants still show `not_evaluable` (if inputs are still missing), BUT now include `details.reason` (and `details.missing_inputs` if used).
3. Run the same scenario twice from the same save and confirm the reason strings and missing_inputs lists are identical and stable.

---

## Git Preflight Gate (Mandatory)
Before ANY code changes, Codex must run and report:

- `git branch --show-current`
- `git status --short`
- `git log --oneline -n 5 --decorate`
- `git show HEAD:codex/runs/ACTIVE_RUN.txt`
- `git fetch origin`
- `git status -sb`
- Preferred wrapper: `powershell -ExecutionPolicy Bypass -File codex/tools/git_gates.ps1 -Mode Preflight`

Rules:
- If `git status --short` is not empty (modified OR untracked files), Codex MUST STOP and ask the user to choose ONE:
  A) Stash WIP (must include untracked): `git stash push -u -m "wip: <short description>"`
  B) Run the current issue’s Closeout Gate (stage ? staged diff review ? commit ? push)
- If `git status -sb` shows the branch is behind origin (e.g. `[behind N]`), Codex MUST STOP and instruct `git pull --ff-only` (or stash-or-closeout first if the tree is dirty).
- Codex must not proceed with any implementation until the working tree is clean AND the branch is not behind origin.

## Git Postflight & Closeout Gate (Mandatory)
After implementation is complete, Codex must perform these gates in order:

1) Review Gate (Staged Diff)
- Stage ONLY:
  - `codex/runs/ACTIVE_RUN.txt`
  - `codex/runs/<Run Folder Name>/**`
  - Whitelisted files for this job
- Then show:
  - `git diff --stat --staged`
  - `git diff --staged`
- Show staged diffs, then auto-closeout unless a gate violation is detected.
- STOP and request user input only if a gate violation or ambiguity is detected.

2) Closeout Gate (Commit + Push)
- If all gates pass and the staged set is whitelist-clean, Codex MUST auto-run closeout immediately (no explicit approval required).
- STOP conditions (user input required):
  - Working tree is dirty.
  - Branch is behind origin.
  - Staged set includes files outside ACTIVE_RUN.txt, codex/runs/<Run Folder Name>/**, or job whitelist.
  - Scope/whitelist/blacklist conflict or ambiguous instruction.
- Run:
  - `git commit -m "<Issue/Task ID>: <Short Title>"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- STOP.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/<Run Folder Name>/`
2) Write this job verbatim to `codex/runs/<Run Folder Name>/job.md`
3) Create `codex/runs/<Run Folder Name>/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `<Run Folder Name>`

Codex must write final results only to:
- `codex/runs/<Run Folder Name>/results.md`

Results must include:
- Root cause summary
- Fix summary
- Files changed (and why)
- Manual tests performed
- Regression checks performed
- Remaining risks or follow-ups
