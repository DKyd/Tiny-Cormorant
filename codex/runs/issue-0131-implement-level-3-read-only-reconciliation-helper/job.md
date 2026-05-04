```markdown
# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0131
- Short Title: Implement Level 3 read-only reconciliation helper
- Run Folder Name: issue-0131-implement-level-3-read-only-reconciliation-helper
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-05-04

---

## Goal
Implement the first Level 3 read-only reconciliation helper as a pure static report builder. It should compare declaration-like documentary cargo totals against a runtime cargo snapshot using existing inert Level 3 primitives, and return a deterministic report payload without wiring into live inspections, UI, pressure, logs, or enforcement.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- The helper must be read-only and deterministic.
- The helper must not be called from live gameplay, inspection, UI, pressure, logging, save/load, cargo, market, contract, or document paths during this job.
- Level 2 quantity/cargo reconciliation must remain policy-disabled.
- The helper must not mutate `GameState`, cargo, freight docs, credits, time, pressure, logs, save data, UI, travel state, or any input dictionary/array.
- No enforcement may be introduced: no fines, seizures, holds, cargo denial, travel blocking, reputation effects, physical inspections, or forced offloads.
- Existing Level 3 data primitives and accessors must remain inert except for direct read-only use by the new helper.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- Do not integrate the helper into `Customs.gd`, `GameState.gd`, `run_customs_inspection()`, Level 1, Level 2, UI, logs, pressure, or gameplay.
- Do not add a scenario harness or broad test framework.
- Do not modify `data/**`, scenes, singletons, existing customs helpers, document rules, project settings, or autoloads.
- Do not add container class attachment to runtime `container_meta`.
- Do not return `invalid` from the first helper; use `clean`, `suspicious`, and `not_evaluable`.
- Do not run Desloppify or external audit tooling.

---

## Context
`issue-0130` planned the Level 3 read-only reconciliation helper and recommended implementing it before any scenario harness or live inspection integration. The planned owner is a new helper file, `scripts/customs/CustomsLevel3Reconciliation.gd`, with a public static entry point:

`static func build_level3_reconciliation_report(ctx: Dictionary) -> Dictionary`

Existing groundwork:
- `issue-0126`: `data/CommodityDB.gd` has inert `customs_mass_per_unit`.
- `issue-0128`: `data/CustomsReconciliationDB.gd` has inert container classes and tolerance policies.
- `issue-0129`: both data surfaces have read-only accessors.
- `issue-0130`: defined the proposed input context, output payload, statuses, missing-data behavior, deterministic comparison rules, and verification strategy.

This job should implement only the pure helper and verify that no runtime caller is added.

---

## Proposed Approach
A short, high-level plan (3-6 bullets).  
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements.

- Create `scripts/customs/CustomsLevel3Reconciliation.gd`.
- Implement `static func build_level3_reconciliation_report(ctx: Dictionary) -> Dictionary`.
- Deep-duplicate input context before reading and normalize docs/cargo data deterministically.
- Use existing read-only data accessors for customs mass, container class, and tolerance policy lookups.
- Return a structured report with classification, status, checks, findings, totals, not-evaluable entries, and context echo.
- Verify by direct helper calls/source inspection and confirm no live runtime integration exists.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `scripts/customs/CustomsLevel3Reconciliation.gd`
- `codex/runs/ACTIVE_RUN.txt`
- `codex/runs/issue-0131-implement-level-3-read-only-reconciliation-helper/job.md`
- `codex/runs/issue-0131-implement-level-3-read-only-reconciliation-helper/results.md`

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/**`
- `scripts/**` except `scripts/customs/CustomsLevel3Reconciliation.gd`
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

- `scripts/customs/CustomsLevel3Reconciliation.gd`
- `codex/runs/issue-0131-implement-level-3-read-only-reconciliation-helper/job.md`
- `codex/runs/issue-0131-implement-level-3-read-only-reconciliation-helper/results.md`

---

## Public API Changes
List any new or modified public methods, signals, or resources.  
If none, write “None”.

- New helper script: `scripts/customs/CustomsLevel3Reconciliation.gd`
- New class name: `CustomsLevel3Reconciliation`
- New static method: `build_level3_reconciliation_report(ctx: Dictionary) -> Dictionary`

---

## Data Model & Persistence
Required if this job adds or modifies saved state or introduces new required in-memory fields.

- New or changed saved fields:
  - None.
- Migration / backward-compat expectations:
  - No save migration required.
  - Existing saves, cargo, documents, markets, and inspections remain unchanged because the helper is not integrated into runtime paths.
- Save/load verification requirements:
  - Verify no save/load code is modified and the helper does not call save/load writers.

---

## Determinism & Stability (If Applicable)
- What must be deterministic?
  - Input normalization, check/finding ordering, totals, tolerance comparison, classification, status, and not-evaluable output.
- What inputs must remain stable?
  - Existing `ctx` dictionary shape, data accessor semantics, commodity IDs, cargo snapshot quantities, document cargo lines, tolerance policy IDs, and container class IDs.
- What must not introduce randomness or time-based variance?
  - No RNG, no generated data, no wall-clock dependence, no autoload registration, no signal emission, no logging, and no runtime state mutation.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] `scripts/customs/CustomsLevel3Reconciliation.gd` exists and defines `class_name CustomsLevel3Reconciliation`.
- [ ] The helper exposes `static func build_level3_reconciliation_report(ctx: Dictionary) -> Dictionary`.
- [ ] The helper returns structured reports with `schema_version`, `level`, `kind`, `classification`, `status`, `policy_id`, `summary`, `checks`, `findings`, `totals`, `not_evaluable`, and `context_echo`.
- [ ] Clean, mismatch, missing docs, missing cargo, unknown commodity/mass, missing/malformed tolerance policy, and missing container class cases produce deterministic report-only outputs.
- [ ] The helper uses only `clean`, `suspicious`, and `not_evaluable` report classifications; it does not return `invalid`.
- [ ] The helper does not mutate input dictionaries/arrays or any game state.
- [ ] Static search confirms no live runtime systems call `CustomsLevel3Reconciliation` or `build_level3_reconciliation_report`.
- [ ] Level 2 quantity/cargo reconciliation remains policy-disabled.
- [ ] Only the new helper file, active run files, and `codex/runs/ACTIVE_RUN.txt` are modified.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Inspect `scripts/customs/CustomsLevel3Reconciliation.gd` and confirm it is a standalone helper with no live runtime integration.
2. Run direct helper-call validation if practical for:
   - clean declared/runtime match
   - declared/runtime mismatch
   - missing docs
   - missing cargo
   - unknown commodity/mass
   - missing or malformed tolerance policy
   - missing container class/tare
3. Repeat one direct-call case and confirm output ordering is deterministic.
4. Search the repo for `CustomsLevel3Reconciliation` and `build_level3_reconciliation_report` and confirm no runtime systems call it.
5. Confirm `scripts/customs/CustomsInvariants.gd` still contains the Level 2 `policy_disabled_until_level3` behavior.
6. Confirm no cargo, credits, docs, time, pressure, logs, save/load, UI, or travel code changed.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Empty `ctx`.
- Missing or non-dictionary `docs`.
- Missing or non-dictionary `cargo`.
- Docs with malformed or missing `cargo_lines`.
- Cargo lines with unknown commodity IDs.
- Missing or invalid `customs_mass_per_unit`.
- Unknown or malformed tolerance policy ID.
- Missing container metadata or container class ID.
- Non-dictionary entries in docs or cargo lines.
- Negative or non-numeric quantities.
- Caller mutates returned report; source constants and input context must remain unaffected.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts, architectural concerns, or future refactors.

- This is the first behavior-adjacent Level 3 helper; keep it unintegrated and report-only.
- A deterministic scenario harness is recommended before later live inspection integration, but not required before this standalone helper.
- Runtime `container_meta` does not yet include `container_class_id`; container/tare checks should usually be `not_evaluable` unless context explicitly supplies usable class data.
- If implementing the helper requires touching `Customs.gd`, `GameState.gd`, data files, or existing audit helpers, Codex must stop and report instead of expanding scope.
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
  - `codex/runs/issue-0131-implement-level-3-read-only-reconciliation-helper/**`
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
  - Staged set includes files outside ACTIVE_RUN.txt, codex/runs/issue-0131-implement-level-3-read-only-reconciliation-helper/**, or job whitelist.
  - Scope/whitelist/blacklist conflict or ambiguous instruction.
- Run:
  - `git commit -m "issue-0131: Implement Level 3 read-only reconciliation helper"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- STOP.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0131-implement-level-3-read-only-reconciliation-helper/`
2) Write this job verbatim to `codex/runs/issue-0131-implement-level-3-read-only-reconciliation-helper/job.md`
3) Create `codex/runs/issue-0131-implement-level-3-read-only-reconciliation-helper/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0131-implement-level-3-read-only-reconciliation-helper`

Codex must write final results only to:
- `codex/runs/issue-0131-implement-level-3-read-only-reconciliation-helper/results.md`

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
```
