# Bugfix Job

## Metadata (Required)
- Issue/Task ID: issue-0105
- Short Title: Surface not_evaluable reason in Level 2 invariant diagnostic sample
- Run Folder Name: issue-0105-bug-l2-invariant-sample-show-reason
- Job Type: bugfix
- Author (human): Douglass Kyd
- Date: 2026-02-22

---

## Bug Description
When a customs inspection reaches **Level 2 depth**, the log diagnostics (added in issue-0103) report:
- `level2_audit present; invariants=N, findings=0`
- sample entries like `L2INV-001[not_evaluable/none]`

After issue-0104, Level 2 invariant results now include deterministic `details.reason` and optional `details.missing_inputs` for `STATUS_NOT_EVALUABLE`, but the diagnostic sample does not display these fields. This prevents diagnosing why invariants are not evaluable in scenarios like doc-vs-cargo quantity mismatch.

---

## Expected Behavior
The Level 2 invariant diagnostic sample should include the not-evaluable reason when present, without adding spam.

Example desired format:
- `L2INV-001[not_evaluable/none:missing_cargo_snapshot]`
- `L2INV-003[not_evaluable/none:missing_declaration_docs]`

If no reason exists, keep current behavior.

---

## Repro Steps
Provide the minimal steps required to reproduce the issue reliably.

1. Run a scenario that reaches Level 2 depth and produces the Level 2 diagnostics line.
2. Create a deterministic doc-vs-cargo quantity mismatch and trigger entry clearance inspection.
3. Observe that invariant samples still appear as `not_evaluable/none` with no explanation.

---

## Observed Output / Error Text
Example:
`Level-2 invariants: none found (level2_audit present; invariants=4, findings=0, sample=L2INV-001[not_evaluable/none], ...).`

---

## Suspected Area (Optional)
- `res://scripts/customs/CustomsReportFormatter.gd`
  - `_build_level2_invariant_sample_from_audit(...)` currently formats only `[status/severity]` and omits `details.reason`.

---

## Scope Constraints
- Changes are limited strictly to fixing the described bug.
- No refactors, cleanup, stylistic changes, or redesigns.
- No new features may be introduced.
- Do NOT change invariant evaluation or inspection logic; formatter-only.

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

- [ ] When an invariant in the diagnostic sample has `status == "not_evaluable"` and includes `details.reason`, the sample string appends `:<reason>` inside the brackets.
- [ ] The diagnostics line remains single-line and low-noise (no full dumps; only reason string).
- [ ] Existing formatting for pass/fail samples remains unchanged.

---

## Regression Checks
List behaviors that must still work after the fix.

- Existing Level 2 diagnostics still show invariant counts, finding counts, and samples.
- Log output remains readable and not spammy.
- Formatter remains robust if `details` is missing or not a Dictionary.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the fix.

1. Run a scenario that reaches Level 2 depth and observe the Level 2 diagnostics line.
2. Create a doc-vs-cargo quantity mismatch and trigger entry clearance inspection.
3. Confirm sample entries now include a reason, e.g.:
   - `L2INV-001[not_evaluable/none:missing_cargo_snapshot]`
4. Repeat from the same save twice to confirm determinism (same reasons / ordering).

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
