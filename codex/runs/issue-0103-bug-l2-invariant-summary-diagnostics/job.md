# Bugfix Job

## Metadata (Required)
- Issue/Task ID: issue-0103
- Short Title: Improve Level 2 invariant summary logging (diagnostics for empty results)
- Run Folder Name: issue-0103-bug-l2-invariant-summary-diagnostics
- Job Type: bugfix
- Author (human): Douglass Kyd
- Date: 2026-02-22

---

## Bug Description
When a customs inspection reaches **Level 2 depth**, the log line sometimes reports:
`Level-2 invariants: none found.`
even in scenarios where the player intentionally creates a **doc vs cargo quantity mismatch** that should produce at least one invariant failure finding.
This makes it unclear whether Level 2 invariants are actually being evaluated, whether they are unevaluable due to missing context inputs, or whether the formatter is reading the wrong fields.

---

## Expected Behavior
When Level 2 depth is reached, the Level 2 invariants summary log line should provide enough information to diagnose what the system is seeing, without adding spam:
- If `level2_audit` is present, show invariant count, finding count, and a small sample of invariant ids/statuses.
- If `level2_audit` is missing, say so and list which related keys (if any) are present on the report.

This is an observability bugfix only; no mechanics change.

---

## Repro Steps
Provide the minimal steps required to reproduce the issue reliably.

1. Start a game state that can produce a customs inspection that reaches **Level 2 depth**.
2. Create a deterministic **doc vs cargo quantity mismatch** (e.g., declared qty differs from actual cargo qty).
3. Trigger an entry clearance inspection and observe the log line for Level 2 invariants.

---

## Observed Output / Error Text
`Level-2 invariants: none found.`

(Also often accompanied by other Level 2-related lines like “Modification evidence present.”)

---

## Suspected Area (Optional)
- `res://scripts/customs/CustomsReportFormatter.gd` (Level 2 summary string generation paths)
- Potential mismatch between formatter expectations and `report["level2_audit"]` schema introduced in issue-0102

---

## Scope Constraints
- Changes are limited strictly to fixing the described bug.
- No refactors, cleanup, stylistic changes, or redesigns.
- No new features may be introduced.
- Do NOT change invariants evaluation behavior, inspection triggers, or any enforcement/state mutation.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `res://scripts/customs/CustomsReportFormatter.gd`

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

- [ ] When Level 2 depth is reached and the report contains `level2_audit`, the Level 2 invariants summary line includes:
  - invariants count
  - findings count
  - and a short, stable sample of invariant ids (and status/severity) without excessive verbosity.
- [ ] When Level 2 depth is reached but the report lacks `level2_audit`, the summary line states `missing level2_audit` and includes a short list of relevant present keys (e.g., any legacy Level 2-related keys).
- [ ] The change does not affect game mechanics, determinism, triggers, or state (log output only).

---

## Regression Checks
List behaviors that must still work after the fix.

- Existing customs report formatting remains readable and does not spam the log.
- Level 1 report formatting and summary lines remain unchanged.
- Any existing “violation(s) [%s]” formatting path still works when findings exist.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the fix.

1. Run a scenario that reaches Level 2 depth where you previously saw: `Level-2 invariants: none found.`
2. Reproduce a doc vs cargo quantity mismatch and trigger entry clearance inspection again.
3. Confirm the Level 2 invariants summary line now indicates which case applies:
   - `level2_audit present` with invariants/findings counts (and sample ids), OR
   - `missing level2_audit` with related present keys.
4. Confirm the log remains single-line and non-spammy (no long dumps).

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
