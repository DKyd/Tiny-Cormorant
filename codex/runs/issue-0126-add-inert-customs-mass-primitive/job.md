# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0126
- Short Title: Add inert customs mass primitive
- Run Folder Name: issue-0126-add-inert-customs-mass-primitive
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-05-04

---

## Goal
Add a customs-owned commodity mass primitive for future Level 3 reconciliation work without wiring it into gameplay, inspections, pressure, UI, or enforcement. The new primitive should make customs mass ownership explicit while preserving existing `weight_per_unit` cargo-capacity semantics.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Existing `weight_per_unit` behavior and cargo-capacity semantics must not change.
- The new customs mass primitive must be inert: no inspection, pressure, audit, UI, save/load, market, cargo, or document behavior may read it for outcomes during this job.
- Level 2 quantity/cargo reconciliation must remain policy-disabled.
- No enforcement may be introduced: no fines, seizures, holds, cargo denial, travel blocking, reputation effects, or forced offloads.
- All commodity mass data must remain deterministic, numeric, and non-negative.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- Do not add Level 3 reconciliation logic.
- Do not add container tare weights, tolerance rules, hull mass, gross/net mass, measured mass, or UI surfacing.
- Do not modify `GameState`, `Customs`, customs invariant logic, document rules, scenes, or scripts.
- Do not change existing cargo capacity, market, trade, contract, document, save/load, or inspection behavior.
- Do not run Desloppify or external audit tooling.

---

## Context
`issue-0124` planned Level 3 reconciliation data primitives and identified commodity mass-per-unit as the first necessary primitive. `issue-0125` audited existing commodity weight semantics and recommended treating `weight_per_unit` as ambiguous for customs mass because it currently functions as gameplay cargo-capacity weight, not a customs-owned mass source of truth.

Future Level 3 reconciliation needs a customs-owned commodity mass primitive before read-only reconciliation helpers can compare documentary declarations against physical/runtime facts. This job should add only the inert data/schema field, likely in `data/CommodityDB.gd`, and verify that all commodities have deterministic values.

---

## Proposed Approach
A short, high-level plan (3-6 bullets).  
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements.

- Add an explicit customs-owned mass field to each commodity definition.
- Initialize values conservatively, likely mirroring current `weight_per_unit` values unless source inspection reveals a safer local convention.
- Add or update narrow static validation/accessor support only if it already belongs in `CommodityDB.gd` and does not wire into gameplay outcomes.
- Verify every commodity has numeric, non-negative customs mass data.
- Avoid touching customs audit logic, GameState, UI, scenes, and other runtime systems.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `data/CommodityDB.gd`
- `codex/runs/ACTIVE_RUN.txt`
- `codex/runs/issue-0126-add-inert-customs-mass-primitive/job.md`
- `codex/runs/issue-0126-add-inert-customs-mass-primitive/results.md`

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**` except `data/CommodityDB.gd`
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

- `codex/runs/issue-0126-add-inert-customs-mass-primitive/job.md`
- `codex/runs/issue-0126-add-inert-customs-mass-primitive/results.md`

---

## Public API Changes
List any new or modified public methods, signals, or resources.  
If none, write “None”.

- New commodity data field: `customs_mass_per_unit` or an equivalently explicit customs-owned mass field name.
- Optional narrow read-only helper in `CommodityDB.gd` only if needed for static verification and kept inert.

---

## Data Model & Persistence
Required if this job adds or modifies saved state or introduces new required in-memory fields.

- New or changed saved fields:
  - Commodity definitions gain a customs-owned mass-per-unit primitive.
- Migration / backward-compat expectations:
  - No save migration required; commodity definitions are static data.
  - Existing runtime cargo, market, contract, and document behavior should continue using existing fields unless a future job explicitly changes that.
- Save/load verification requirements:
  - None required for saved state; verify no save/load code is modified.

---

## Determinism & Stability (If Applicable)
- What must be deterministic?
  - Commodity customs mass values and any static validation/accessor output.
- What inputs must remain stable?
  - Existing commodity IDs, `weight_per_unit`, cargo capacity calculations, market/trade data, and document cargo-line data.
- What must not introduce randomness or time-based variance?
  - No random values, generated values, wall-clock dependence, or runtime mutation.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] Every commodity in `CommodityDB.COMMODITIES` has an explicit customs-owned mass-per-unit primitive.
- [ ] Customs mass values are numeric, deterministic, and non-negative.
- [ ] Existing `weight_per_unit` values remain present and unchanged.
- [ ] No runtime gameplay path is wired to use customs mass for inspection, pressure, cargo, market, contract, document, UI, or save/load outcomes.
- [ ] Level 2 quantity/cargo reconciliation remains policy-disabled.
- [ ] Only `data/CommodityDB.gd`, the active run files, and `codex/runs/ACTIVE_RUN.txt` are modified.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Open the canonical project in Godot 4.6.1.
2. Confirm the project starts without parse errors.
3. Inspect `data/CommodityDB.gd` and confirm every commodity has the new customs mass primitive.
4. Start a new game and confirm basic cargo/market interactions still behave as before where practical.
5. Trigger or view Customs inspection UI where practical and confirm no new Level 3 reconciliation, enforcement, or pressure behavior appears.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- A commodity missing the customs mass primitive should be caught by static inspection or any narrow validation added in `CommodityDB.gd`.
- Non-numeric or negative mass values should be avoided entirely.
- If `CommodityDB.gd` structure makes adding a separate field unsafe or ambiguous, Codex must stop and report rather than changing runtime systems.
- If static validation requires touching files outside the whitelist, Codex must stop and ask.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts, architectural concerns, or future refactors.

- `data/**` is protected and conceptually important; keep the diff small and table-focused.
- Mirroring `weight_per_unit` values initially is acceptable only as inert seed data; future jobs may tune customs mass separately.
- This job intentionally does not add container tare, tolerance, hull mass, or reconciliation helpers.
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
  - `codex/runs/issue-0126-add-inert-customs-mass-primitive/**`
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
  - Staged set includes files outside ACTIVE_RUN.txt, codex/runs/issue-0126-add-inert-customs-mass-primitive/**, or job whitelist.
  - Scope/whitelist/blacklist conflict or ambiguous instruction.
- Run:
  - `git commit -m "issue-0126: Add inert customs mass primitive"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- STOP.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0126-add-inert-customs-mass-primitive/`
2) Write this job verbatim to `codex/runs/issue-0126-add-inert-customs-mass-primitive/job.md`
3) Create `codex/runs/issue-0126-add-inert-customs-mass-primitive/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0126-add-inert-customs-mass-primitive`

Codex must write final results only to:
- `codex/runs/issue-0126-add-inert-customs-mass-primitive/results.md`

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
