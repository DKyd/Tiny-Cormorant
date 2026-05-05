# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0133
- Short Title: Add deterministic Level 3 helper validation harness
- Run Folder Name: issue-0133-add-deterministic-level-3-helper-validation-harness
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-05-05

---

## Goal
Add a narrow deterministic validation harness for the standalone Level 3 read-only reconciliation helper. The harness should exercise direct helper calls for clean, mismatch, and not-evaluable cases without wiring the helper into live inspections, UI, pressure, logs, or gameplay.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- The harness must not change runtime gameplay behavior.
- `CustomsLevel3Reconciliation` must remain unintegrated with live Customs/GameState/UI paths.
- Level 2 quantity/cargo reconciliation must remain policy-disabled.
- No enforcement may be introduced: no fines, seizures, holds, cargo denial, travel blocking, reputation effects, physical inspections, or forced offloads.
- Validation must be deterministic: repeated runs with the same fixture inputs should produce the same results.
- The OneDrive project folder must remain fully local/hydrated for Godot validation where applicable.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- Do not integrate Level 3 helper output into `Customs.gd`, `GameState.gd`, inspections, UI, logs, pressure, or gameplay.
- Do not add player-facing UI.
- Do not modify data primitives, tolerance policy, commodity data, scenes, singletons, project settings, or autoloads.
- Do not create a broad test framework.
- Do not fix unrelated Godot/editor/headless issues.
- Do not run Desloppify or external audit tooling.

---

## Context
`issue-0131` implemented `scripts/customs/CustomsLevel3Reconciliation.gd` as a pure static helper, but useful direct-call validation was blocked by recurring Godot crashes. `issue-0132` triaged those crashes, and the human later confirmed that setting the OneDrive project folder to “Always keep on this device” allowed Godot 4.6.1 to open successfully.

Before wiring the Level 3 helper into any live customs path, the project needs a small repeatable validation harness that can directly call the helper with deterministic fixture contexts and verify report-only behavior.

---

## Proposed Approach
A short, high-level plan (3-6 bullets).  
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements.

- Add a narrow validation script for `CustomsLevel3Reconciliation`.
- Build literal fixture contexts for clean, mismatch, missing docs, missing cargo, unknown commodity/mass, malformed tolerance, and missing container class cases.
- Call `CustomsLevel3Reconciliation.build_level3_reconciliation_report(ctx)` directly.
- Assert or report expected classification/status/not-evaluable behavior deterministically.
- Keep the harness isolated from live gameplay and document how to run it.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `scripts/customs/CustomsLevel3ReconciliationValidation.gd`
- `codex/runs/ACTIVE_RUN.txt`
- `codex/runs/issue-0133-add-deterministic-level-3-helper-validation-harness/job.md`
- `codex/runs/issue-0133-add-deterministic-level-3-helper-validation-harness/results.md`

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/**`
- `scripts/**` except `scripts/customs/CustomsLevel3ReconciliationValidation.gd`
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

- `scripts/customs/CustomsLevel3ReconciliationValidation.gd`
- `codex/runs/issue-0133-add-deterministic-level-3-helper-validation-harness/job.md`
- `codex/runs/issue-0133-add-deterministic-level-3-helper-validation-harness/results.md`

---

## Public API Changes
List any new or modified public methods, signals, or resources.  
If none, write “None”.

- New validation helper script: `scripts/customs/CustomsLevel3ReconciliationValidation.gd`
- Optional static validation entry point, for example `run_validation() -> Dictionary`, only if kept isolated from runtime gameplay.

---

## Data Model & Persistence
Required if this job adds or modifies saved state or introduces new required in-memory fields.

- New or changed saved fields:
  - None.
- Migration / backward-compat expectations:
  - No save migration required.
- Save/load verification requirements:
  - Verify no save/load code is modified and the validation harness does not write save data.

---

## Determinism & Stability (If Applicable)
- What must be deterministic?
  - Fixture inputs, report classifications/statuses, check/finding ordering, and validation summary output.
- What inputs must remain stable?
  - Existing Level 3 helper API, commodity IDs used in fixtures, customs mass accessors, container/tolerance accessors.
- What must not introduce randomness or time-based variance?
  - No RNG, wall-clock dependence, generated fixture data, autoload registration, signal emission, logging side effects, or runtime state mutation.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] A validation harness exists at `scripts/customs/CustomsLevel3ReconciliationValidation.gd`.
- [ ] The harness directly calls `CustomsLevel3Reconciliation.build_level3_reconciliation_report(ctx)`.
- [ ] The harness covers at least clean, mismatch, missing docs, missing cargo, unknown commodity/mass, malformed or missing tolerance policy, and missing container class/tare cases.
- [ ] Repeated validation runs produce deterministic results.
- [ ] The harness does not call or mutate `GameState`, `Customs`, cargo, documents, credits, time, pressure, logs, UI, travel, save/load, or inspection state.
- [ ] Static search confirms no live runtime systems call the validation harness.
- [ ] Level 2 quantity/cargo reconciliation remains policy-disabled.
- [ ] Only the new validation script, active run files, and `codex/runs/ACTIVE_RUN.txt` are modified.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Ensure the OneDrive Tiny Cormorant project folder is marked “Always keep on this device.”
2. Open the canonical project in Godot 4.6.1 or run the agreed headless/script validation command if available.
3. Execute the validation harness entry point directly.
4. Confirm all fixture cases return expected classifications/statuses.
5. Repeat the harness and confirm output is stable.
6. Search the repo for `CustomsLevel3ReconciliationValidation` and confirm no live runtime systems call it.
7. Confirm no `.godot/**` churn is staged or committed.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Godot validation cannot run because the OneDrive folder is not fully hydrated.
- Godot headless remains unstable even after hydration; record fallback source/static validation in `results.md`.
- Fixture data references a commodity ID that no longer exists.
- Helper output shape changes unexpectedly.
- Validation harness requires touching runtime files outside the whitelist; Codex must stop and ask.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts, architectural concerns, or future refactors.

- This harness is intentionally narrow and isolated; do not turn it into a broad testing framework.
- If the validation script cannot be run in Godot without adding project settings/autoloads/scenes, Codex must stop and report rather than expanding scope.
- This job is a prerequisite for safer future integration, not integration itself.
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
  - `codex/runs/issue-0133-add-deterministic-level-3-helper-validation-harness/**`
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
  - Staged set includes files outside ACTIVE_RUN.txt, codex/runs/issue-0133-add-deterministic-level-3-helper-validation-harness/**, or job whitelist.
  - Scope/whitelist/blacklist conflict or ambiguous instruction.
- Run:
  - `git commit -m "issue-0133: Add deterministic Level 3 helper validation harness"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- STOP.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0133-add-deterministic-level-3-helper-validation-harness/`
2) Write this job verbatim to `codex/runs/issue-0133-add-deterministic-level-3-helper-validation-harness/job.md`
3) Create `codex/runs/issue-0133-add-deterministic-level-3-helper-validation-harness/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0133-add-deterministic-level-3-helper-validation-harness`

Codex must write final results only to:
- `codex/runs/issue-0133-add-deterministic-level-3-helper-validation-harness/results.md`

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
