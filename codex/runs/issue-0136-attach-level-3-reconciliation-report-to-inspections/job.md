# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0136
- Short Title: Attach Level 3 reconciliation report to inspections
- Run Folder Name: issue-0136-attach-level-3-reconciliation-report-to-inspections
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-05-05

---

## Goal
Attach the existing pure Level 3 read-only reconciliation report to customs inspection reports when the resolved inspection depth reaches Level 3. The integration must be report-only and must not change pressure, logs, UI, enforcement, inspection triggers, or Level 2 behavior.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Level 3 reconciliation attaches only when resolved `max_depth >= 3`.
- The report key must be `level3_reconciliation`.
- `CustomsLevel3Reconciliation` must remain pure/read-only.
- Level 2 quantity/cargo reconciliation must remain policy-disabled.
- No pressure, scrutiny, depth bias, log, UI, save/load, cargo, credit, document, travel, or enforcement behavior may change.
- No fines, seizures, holds, cargo denial, travel blocking, reputation effects, physical inspections, or forced offloads may be introduced.
- Existing Level 1 and Level 2 report behavior must continue to work.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- Do not surface Level 3 findings in UI.
- Do not add pressure/scrutiny effects from Level 3 findings.
- Do not change inspection chance, trigger timing, jurisdiction selection, or depth bias rules.
- Do not alter Level 1 or Level 2 classification semantics.
- Do not add container class generation, new data primitives, scenario harnesses, logs, or enforcement.
- Do not run Desloppify or external audit tooling.

---

## Context
`issue-0131` implemented `scripts/customs/CustomsLevel3Reconciliation.gd` as a pure static helper. `issue-0133` added a deterministic validation harness. `issue-0134` ran the harness twice through Godot 4.6.1 with exit code `0`. `issue-0135` planned the integration and recommended:

- report key: `level3_reconciliation`
- gate: attach only when `max_depth >= 3`
- seam: `GameState.run_customs_inspection(context)`
- placement: after existing Level 2 work and current log formatting, but before `customs_inspection_completed` and `return`
- context ownership: `Customs.gd` wrapper/normalization, `GameState.gd` attachment decision, helper remains pure

This job should implement that narrow report attachment only.

---

## Proposed Approach
A short, high-level plan (3-6 bullets).  
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements.

- Add a narrow `Customs.gd` wrapper that builds/normalizes a Level 3 reconciliation context and calls `CustomsLevel3Reconciliation.build_level3_reconciliation_report(ctx)`.
- In `GameState.run_customs_inspection(context)`, attach `report["level3_reconciliation"]` only when resolved `max_depth >= 3`.
- Place attachment after existing Level 2 report work and current log formatting, before the completion signal and return.
- Use duplicated snapshots for docs/cargo and do not mutate source state.
- Verify no pressure, logs, UI, enforcement, or Level 2 behavior changes were introduced.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `singletons/Customs.gd`
- `singletons/GameState.gd`
- `codex/runs/ACTIVE_RUN.txt`
- `codex/runs/issue-0136-attach-level-3-reconciliation-report-to-inspections/job.md`
- `codex/runs/issue-0136-attach-level-3-reconciliation-report-to-inspections/results.md`

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/**`
- `scripts/**`
- `singletons/**` except `singletons/Customs.gd` and `singletons/GameState.gd`
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

- `codex/runs/issue-0136-attach-level-3-reconciliation-report-to-inspections/job.md`
- `codex/runs/issue-0136-attach-level-3-reconciliation-report-to-inspections/results.md`

---

## Public API Changes
List any new or modified public methods, signals, or resources.  
If none, write “None”.

- `Customs.gd`: may add a narrow public or internal read-only wrapper for building Level 3 reconciliation reports.
- `GameState.run_customs_inspection(context)` report payload may include `level3_reconciliation` when `max_depth >= 3`.

---

## Data Model & Persistence
Required if this job adds or modifies saved state or introduces new required in-memory fields.

- New or changed saved fields:
  - None.
- Migration / backward-compat expectations:
  - No save migration required.
  - Existing inspection reports without Level 3 depth remain compatible because `level3_reconciliation` is absent unless `max_depth >= 3`.
- Save/load verification requirements:
  - Verify no save/load code is modified and the integration does not write saved state.

---

## Determinism & Stability (If Applicable)
- What must be deterministic?
  - Whether `level3_reconciliation` attaches based on `max_depth >= 3`, context construction, helper output, report key, and ordering.
- What inputs must remain stable?
  - Existing inspection context, Level 1/Level 2 report fields, cargo snapshot, freight doc snapshot, customs mass/tolerance accessors, and depth selection.
- What must not introduce randomness or time-based variance?
  - No RNG, wall-clock dependence, random sampling, new depth calculations, new trigger logic, logging side effects, or state mutation.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] `report["level3_reconciliation"]` is attached only when resolved `max_depth >= 3`.
- [ ] Reports with `max_depth < 3` do not include `level3_reconciliation`.
- [ ] Attachment uses `Customs.gd` context/wrapper normalization and the existing pure helper.
- [ ] Level 1 and Level 2 report behavior remains intact.
- [ ] Level 2 `policy_disabled_until_level3` behavior remains present.
- [ ] No pressure/scrutiny, logs, UI, cargo, credits, documents, time, travel, save/load, trigger, chance, or enforcement behavior changes are introduced.
- [ ] Static search confirms no UI files read or render `level3_reconciliation` in this job.
- [ ] Only whitelisted files are modified.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Ensure the OneDrive Tiny Cormorant project folder is marked “Always keep on this device.”
2. Run or inspect a path where `max_depth < 3` and confirm `level3_reconciliation` is not attached.
3. Run or inspect a path where `max_depth >= 3` and confirm `level3_reconciliation` is attached as a report dictionary.
4. Confirm Level 1 and Level 2 fields still appear as before.
5. Confirm no UI section displays Level 3 findings yet.
6. Confirm no cargo, credits, documents, time, pressure, logs, save/load, travel, or enforcement behavior changes occur from attachment.
7. Run static searches for mutation/log/UI/enforcement calls related to the new Level 3 attachment.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Missing or malformed docs snapshot should produce helper `not_evaluable`, not crash.
- Missing or malformed cargo snapshot should produce helper `not_evaluable`, not crash.
- Missing container class metadata should make container/tare checks `not_evaluable` while other checks may still evaluate.
- Unknown commodity or missing customs mass should produce helper `not_evaluable`.
- If `max_depth` is absent or not numeric, attachment must fail closed rather than attaching at the wrong depth.
- If safe context construction requires touching files outside the whitelist, Codex must stop and ask.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts, architectural concerns, or future refactors.

- This job touches core systems (`GameState.gd` and `Customs.gd`), so keep the implementation as small and auditable as possible.
- The first integration may often return `not_evaluable` for container/tare checks until container class metadata exists.
- UI surfacing must remain separate and later.
- Pressure/scrutiny effects from Level 3 findings must remain separate and later, likely requiring a planning job first.
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
  - `codex/runs/issue-0136-attach-level-3-reconciliation-report-to-inspections/**`
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
  - Staged set includes files outside ACTIVE_RUN.txt, codex/runs/issue-0136-attach-level-3-reconciliation-report-to-inspections/**, or job whitelist.
  - Scope/whitelist/blacklist conflict or ambiguous instruction.
- Run:
  - `git commit -m "issue-0136: Attach Level 3 reconciliation report to inspections"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- STOP.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0136-attach-level-3-reconciliation-report-to-inspections/`
2) Write this job verbatim to `codex/runs/issue-0136-attach-level-3-reconciliation-report-to-inspections/job.md`
3) Create `codex/runs/issue-0136-attach-level-3-reconciliation-report-to-inspections/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0136-attach-level-3-reconciliation-report-to-inspections`

Codex must write final results only to:
- `codex/runs/issue-0136-attach-level-3-reconciliation-report-to-inspections/results.md`

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
