# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0129
- Short Title: Add read-only reconciliation primitive accessors
- Run Folder Name: issue-0129-add-read-only-reconciliation-primitive-accessors
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-05-04

---

## Goal
Add narrow read-only accessors for the inert Level 3 reconciliation primitives so future jobs can look up commodity customs mass, container class/tare data, and reconciliation tolerance policy data safely. These helpers must remain pure data access only and must not wire reconciliation behavior into inspections, pressure, UI, or gameplay.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Accessors must be read-only and deterministic.
- No runtime gameplay path may use the new accessors for outcomes during this job.
- `customs_mass_per_unit` remains inert and must not affect cargo, market, documents, inspections, pressure, UI, save/load, or enforcement.
- `CustomsReconciliationDB` must not be added to `project.godot` autoloads.
- Level 2 quantity/cargo reconciliation must remain policy-disabled.
- No enforcement may be introduced: no fines, seizures, holds, cargo denial, travel blocking, reputation effects, physical inspections, or forced offloads.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- Do not add Level 3 reconciliation helper logic.
- Do not compare documents to cargo, mass, containers, or tolerance policies.
- Do not add UI surfacing, pressure effects, inspection triggers, audit integration, or enforcement.
- Do not modify `GameState`, `Customs`, customs invariant logic, document rules, scenes, scripts, project settings, or autoloads.
- Do not run Desloppify or external audit tooling.

---

## Context
`issue-0126` added inert `customs_mass_per_unit` values to commodity data. `issue-0128` added an inert `data/CustomsReconciliationDB.gd` surface with `CONTAINER_CLASSES`, `RECONCILIATION_TOLERANCE_POLICIES`, and default IDs. No runtime readers were added.

Before adding any Level 3 read-only reconciliation helper, the project needs safe primitive lookup functions that can return deterministic values and fail closed on missing or malformed IDs. This job should add accessors only to the data surfaces themselves, without integrating them into customs audit or gameplay systems.

---

## Proposed Approach
A short, high-level plan (3-6 bullets).  
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements.

- Add a read-only commodity customs mass accessor to `CommodityDB.gd`.
- Add read-only container class/tare and tolerance policy accessors to `CustomsReconciliationDB.gd`.
- Return duplicate dictionaries or primitive values so callers cannot mutate source data.
- Provide deterministic fallback/missing-data behavior for unknown commodity/container/policy IDs.
- Verify helpers through static/source inspection or limited non-persistent calls without adding runtime integration.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `data/CommodityDB.gd`
- `data/CustomsReconciliationDB.gd`
- `codex/runs/ACTIVE_RUN.txt`
- `codex/runs/issue-0129-add-read-only-reconciliation-primitive-accessors/job.md`
- `codex/runs/issue-0129-add-read-only-reconciliation-primitive-accessors/results.md`

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**` except `data/CommodityDB.gd` and `data/CustomsReconciliationDB.gd`
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

- `codex/runs/issue-0129-add-read-only-reconciliation-primitive-accessors/job.md`
- `codex/runs/issue-0129-add-read-only-reconciliation-primitive-accessors/results.md`

---

## Public API Changes
List any new or modified public methods, signals, or resources.  
If none, write “None”.

- `CommodityDB.gd`: new read-only accessor for customs mass per unit.
- `CustomsReconciliationDB.gd`: new read-only accessors for container classes/default container class and tolerance policies/default tolerance policy.

---

## Data Model & Persistence
Required if this job adds or modifies saved state or introduces new required in-memory fields.

- New or changed saved fields:
  - None.
- Migration / backward-compat expectations:
  - No save migration required.
  - Static data shape from `issue-0126` and `issue-0128` should remain compatible.
- Save/load verification requirements:
  - None required for saved state; verify no save/load code is modified.

---

## Determinism & Stability (If Applicable)
- What must be deterministic?
  - Accessor return values, missing-data fallbacks, and dictionary duplication behavior.
- What inputs must remain stable?
  - Existing commodity IDs, `weight_per_unit`, `customs_mass_per_unit`, container class IDs, tolerance policy IDs, and default IDs.
- What must not introduce randomness or time-based variance?
  - No RNG, no generated data, no wall-clock dependence, no autoload registration, and no runtime state mutation.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] `CommodityDB.gd` exposes a read-only way to retrieve customs mass per unit for a commodity ID.
- [ ] `CustomsReconciliationDB.gd` exposes read-only ways to retrieve container class data and tolerance policy data.
- [ ] Unknown or missing IDs return deterministic safe fallback values or empty/error dictionaries without crashing.
- [ ] Returned dictionaries are duplicates or otherwise safe from caller mutation of source constants.
- [ ] `CustomsReconciliationDB` is not added to `project.godot` autoloads.
- [ ] No customs audit, inspection, pressure, UI, cargo, market, contract, document, save/load, or enforcement path is wired to use these accessors.
- [ ] Level 2 quantity/cargo reconciliation remains policy-disabled.
- [ ] Only whitelisted data files, active run files, and `codex/runs/ACTIVE_RUN.txt` are modified.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Inspect `data/CommodityDB.gd` and confirm the new customs mass accessor is read-only and deterministic.
2. Inspect `data/CustomsReconciliationDB.gd` and confirm container/tolerance accessors return safe copies or primitive values.
3. Confirm unknown commodity/container/tolerance IDs have deterministic fallback behavior.
4. Search the repo for the new accessor names and confirm no runtime systems call them for gameplay outcomes.
5. Confirm `project.godot` does not include `CustomsReconciliationDB` in `[autoload]`.
6. Confirm Level 2 quantity/cargo reconciliation policy-disabled marker remains present.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Unknown commodity ID.
- Unknown container class ID.
- Unknown tolerance policy ID.
- Missing `customs_mass_per_unit` in a commodity record.
- Malformed container or tolerance records.
- Caller mutates a returned dictionary; source constants should remain unchanged.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts, architectural concerns, or future refactors.

- Adding accessors is the first step toward runtime usage, but this job must not integrate them into behavior.
- Keep helper names explicit so future jobs do not confuse cargo-capacity weight with customs mass.
- If `CommodityDB.gd` or `CustomsReconciliationDB.gd` structure makes safe accessors ambiguous, Codex must stop and report rather than modifying runtime systems.
- `issue-0126` reported a Godot headless engine signal 11; do not chase that in this job unless it directly prevents static verification.
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
  B) Run the current issue's Closeout Gate (stage -> staged diff review -> commit -> push)
- If `git status -sb` shows the branch is behind origin (e.g. `[behind N]`), Codex MUST STOP and instruct `git pull --ff-only` (or stash-or-closeout first if the tree is dirty).
- Codex must not proceed with any implementation until the working tree is clean AND the branch is not behind origin.

## Git Postflight & Closeout Gate (Mandatory)
After implementation is complete, Codex must perform these gates in order:

1) Review Gate (Staged Diff)
- Stage ONLY:
  - `codex/runs/ACTIVE_RUN.txt`
  - `codex/runs/issue-0129-add-read-only-reconciliation-primitive-accessors/**`
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
  - Staged set includes files outside ACTIVE_RUN.txt, codex/runs/issue-0129-add-read-only-reconciliation-primitive-accessors/**, or job whitelist.
  - Scope/whitelist/blacklist conflict or ambiguous instruction.
- Run:
  - `git commit -m "issue-0129: Add read-only reconciliation primitive accessors"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- STOP.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0129-add-read-only-reconciliation-primitive-accessors/`
2) Write this job verbatim to `codex/runs/issue-0129-add-read-only-reconciliation-primitive-accessors/job.md`
3) Create `codex/runs/issue-0129-add-read-only-reconciliation-primitive-accessors/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0129-add-read-only-reconciliation-primitive-accessors`

Codex must write final results only to:
- `codex/runs/issue-0129-add-read-only-reconciliation-primitive-accessors/results.md`

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
