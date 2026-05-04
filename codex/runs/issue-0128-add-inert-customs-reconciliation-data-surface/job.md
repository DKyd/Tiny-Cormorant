# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0128
- Short Title: Add inert customs reconciliation data surface
- Run Folder Name: issue-0128-add-inert-customs-reconciliation-data-surface
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-05-04

---

## Goal
Add a dedicated inert data surface for future Level 3 customs reconciliation primitives. Define container class/tare data and reconciliation tolerance policy data without wiring them into gameplay, autoloads, inspections, pressure, UI, or enforcement.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- The new data surface must be inert: no runtime gameplay path may read it for outcomes during this job.
- `customs_mass_per_unit` from `issue-0126` remains inert and unwired.
- Level 2 quantity/cargo reconciliation must remain policy-disabled.
- No enforcement may be introduced: no fines, seizures, holds, cargo denial, travel blocking, reputation effects, physical inspections, or forced offloads.
- Existing commodity, cargo, market, contract, document, customs, pressure, UI, and save/load behavior must not change.
- The new data must be deterministic and static.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- Do not add Level 3 reconciliation helper logic.
- Do not add UI surfacing, pressure effects, inspection triggers, audit integration, or enforcement.
- Do not modify `CommodityDB.gd`, `GameState`, `Customs`, customs invariant logic, document rules, scenes, scripts, project settings, or autoloads.
- Do not add `CustomsReconciliationDB` to `project.godot` autoloads.
- Do not run Desloppify or external audit tooling.

---

## Context
`issue-0124` planned Level 3 reconciliation data primitives. `issue-0125` concluded that `weight_per_unit` is ambiguous for customs mass. `issue-0126` added an inert customs-owned `customs_mass_per_unit` field to commodity data. `issue-0127` recommended a dedicated inert data surface at `data/CustomsReconciliationDB.gd` for container class/tare records and reconciliation tolerance policies, instead of placing this policy in `CommodityDB.gd`, `GameState`, or customs logic.

This job should create that dedicated data surface only. Future jobs may add read-only accessors, schema validators, or reconciliation helpers, but this job must not wire the data into behavior.

---

## Proposed Approach
A short, high-level plan (3-6 bullets).  
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements.

- Create `data/CustomsReconciliationDB.gd` as a static data script.
- Define deterministic `CONTAINER_CLASSES` records with class IDs and tare/mass-related primitive fields.
- Define deterministic `RECONCILIATION_TOLERANCE_POLICIES` records with tolerance values and missing-data behavior.
- Keep the file inert and unreferenced by runtime systems.
- Verify static shape, numeric/non-negative values, and that no runtime readers were added.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `data/CustomsReconciliationDB.gd`
- `data/CustomsReconciliationDB.gd.uid` only if Godot generates it during verification
- `codex/runs/ACTIVE_RUN.txt`
- `codex/runs/issue-0128-add-inert-customs-reconciliation-data-surface/job.md`
- `codex/runs/issue-0128-add-inert-customs-reconciliation-data-surface/results.md`

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**` except `data/CustomsReconciliationDB.gd` and `data/CustomsReconciliationDB.gd.uid`
- `scenes/**`
- `scripts/**`
- `singletons/**`
- `.godot/**`
- `.desloppify/**`
- `Documentation/**`
- `project.godot`
- `codex/AGENTS.md`
- `codex/README.md`
- `codex/CONTEXT.md`
- `codex/jobs/**`
- `codex/tools/**`

---

## New Files Allowed?
- [x] Yes (must list exact paths below)
- [ ] No

If Yes, list exact new file paths:

- `data/CustomsReconciliationDB.gd`
- `data/CustomsReconciliationDB.gd.uid` only if Godot generates it during verification
- `codex/runs/issue-0128-add-inert-customs-reconciliation-data-surface/job.md`
- `codex/runs/issue-0128-add-inert-customs-reconciliation-data-surface/results.md`

---

## Public API Changes
List any new or modified public methods, signals, or resources.  
If none, write “None”.

- New static data script: `data/CustomsReconciliationDB.gd`
- New constant: `CONTAINER_CLASSES`
- New constant: `RECONCILIATION_TOLERANCE_POLICIES`

---

## Data Model & Persistence
Required if this job adds or modifies saved state or introduces new required in-memory fields.

- New or changed saved fields:
  - None. This job adds static data only, not saved state.
- Migration / backward-compat expectations:
  - No save migration required.
  - Existing saves, cargo, documents, markets, and inspections must continue unchanged because no runtime reader is added.
- Save/load verification requirements:
  - None required for saved state; verify no save/load code is modified.

---

## Determinism & Stability (If Applicable)
- What must be deterministic?
  - Container class records, tare/mass values, tolerance policy values, missing-data policy strings, and ordering.
- What inputs must remain stable?
  - Existing commodity data, cargo data, document metadata, customs audit outputs, inspection reports, and pressure/scrutiny state.
- What must not introduce randomness or time-based variance?
  - No random values, generated values, wall-clock dependence, autoload registration, or runtime mutation.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] `data/CustomsReconciliationDB.gd` exists and defines `CONTAINER_CLASSES`.
- [ ] `data/CustomsReconciliationDB.gd` defines `RECONCILIATION_TOLERANCE_POLICIES`.
- [ ] Container class records include deterministic IDs and non-negative numeric tare/mass primitives.
- [ ] Tolerance policy records include deterministic numeric tolerance values and explicit missing-data behavior.
- [ ] The new data surface is not added to `project.godot` autoloads.
- [ ] No runtime code reads the new data surface for gameplay, inspection, pressure, UI, save/load, cargo, market, contract, or document outcomes.
- [ ] Level 2 quantity/cargo reconciliation remains policy-disabled.
- [ ] Only the whitelisted data file(s), active run files, and `codex/runs/ACTIVE_RUN.txt` are modified.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Inspect `data/CustomsReconciliationDB.gd` and confirm it defines container class and tolerance policy constants.
2. Confirm all numeric tare/mass/tolerance values are non-negative and deterministic.
3. Confirm `project.godot` does not include `CustomsReconciliationDB` in `[autoload]`.
4. Search the repo for `CustomsReconciliationDB`, `CONTAINER_CLASSES`, and `RECONCILIATION_TOLERANCE_POLICIES` and confirm no runtime readers were added outside the new data file and run results.
5. Open the project in Godot 4.6.1 if practical and confirm no parse/load errors from the new data script.
6. Confirm no Level 3 reconciliation behavior, pressure effect, UI surfacing, or enforcement appears in gameplay.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- If Godot generates a `.uid` for the new data script, it may be included only if it matches the explicitly allowed path.
- If a static parse/load check triggers unrelated Godot engine instability, record it in `results.md` and rely on source/static verification where appropriate.
- If adding the data surface requires changing autoloads, runtime readers, or files outside the whitelist, Codex must stop and ask.
- Missing-data behavior must be represented as explicit policy data rather than assumed by future code.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts, architectural concerns, or future refactors.

- `data/**` is protected and conceptually important; keep the diff small and static-data-only.
- This job intentionally does not provide accessors or validators; those should be future jobs if needed.
- Container class and tolerance seed values may need tuning later, but they must be deterministic and inert now.
- `issue-0126` reported a Godot headless engine signal 11; do not chase that in this job unless it directly prevents parsing the new data file.
- If assumptions prove false, Codex must stop and report rather than inventing solutions.

---

## Governance & Review Gates (Mandatory)
- Codex must not make code changes until required preflight/review steps are complete.
- Codex must present diffs for review before declaring results final.
- If scope, whitelist, or non-goals are violated, Codex must stop and report the issue.

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
  B) Run the current issue’s Closeout Gate (stage → staged diff review → commit → push)
- If `git status -sb` shows the branch is behind origin (e.g. `[behind N]`), Codex MUST STOP and instruct `git pull --ff-only` (or stash-or-closeout first if the tree is dirty).
- Codex must not proceed with any implementation until the working tree is clean AND the branch is not behind origin.

## Git Postflight & Closeout Gate (Mandatory)
After implementation is complete, Codex must perform these gates in order:

1) Review Gate (Staged Diff)
- Stage ONLY:
  - `codex/runs/ACTIVE_RUN.txt`
  - `codex/runs/issue-0128-add-inert-customs-reconciliation-data-surface/**`
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
  - Staged set includes files outside ACTIVE_RUN.txt, codex/runs/issue-0128-add-inert-customs-reconciliation-data-surface/**, or job whitelist.
  - Scope/whitelist/blacklist conflict or ambiguous instruction.
- Run:
  - `git commit -m "issue-0128: Add inert customs reconciliation data surface"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- STOP.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0128-add-inert-customs-reconciliation-data-surface/`
2) Write this job verbatim to `codex/runs/issue-0128-add-inert-customs-reconciliation-data-surface/job.md`
3) Create `codex/runs/issue-0128-add-inert-customs-reconciliation-data-surface/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0128-add-inert-customs-reconciliation-data-surface`

Codex must write final results only to:
- `codex/runs/issue-0128-add-inert-customs-reconciliation-data-surface/results.md`

Results must include:
- Summary of changes and rationale
- Files changed (with brief explanation per file)
- Assumptions made
- Known limitations or TODOs

---

## Logging Checklist
- [ ] All explicit player actions that succeed or fail emit a clear log entry
- [ ] All time advancement paths log a reason and tick delta
- [x] No UI-only interactions produce log entries
- [x] No per-frame or loop-driven spam was introduced
- [x] Log messages are human-readable
- [x] `print()` usage is debug-only or removed in favor of `Log.add_entry()`
- [x] Log volume feels appropriate for a capped, recent-history log
