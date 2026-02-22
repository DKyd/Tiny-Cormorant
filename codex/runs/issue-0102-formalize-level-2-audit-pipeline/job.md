# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0102
- Short Title: Formalize Level 2 customs audit pipeline
- Run Folder Name: issue-0102-formalize-level-2-audit-pipeline
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-02-22

---

## Goal
When a customs inspection reaches **Level 2 depth**, the game must produce a deterministic, structured **Level 2 audit payload** (classification + findings + invariant results) and attach it to the inspection report.  
This creates a stable “Level 2” layer that can later drive UI and enforcement, without adding consequences now.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Level 2 evaluation is deterministic for the same stable inputs (system_id, effective checkpoint/location_id, tick, cargo snapshot, freight docs, evidence flags).
- Level 2 performs **no enforcement** and **no state mutation** (no cargo/credits/time/doc changes); it only reads state and emits report fields/logs.
- Level 1 triggers and behavior remain unchanged unless strictly required to call the Level 2 pipeline once a Level 2 depth path is already selected.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- Do NOT add enforcement (no fines, holds, seizures, delays, tariffs, arrests, or reputation changes).
- Do NOT add new triggers or mechanics to “reach” Level 2; only formalize the pipeline when Level 2 is already invoked by existing paths.

---

## Context
Customs currently supports deterministic pressure bucketing, Level 1 surface compliance checks, and a deterministic Level 2 invariant evaluator (`scripts/customs/CustomsInvariants.gd`, issue-0100).  
Formatting/validation helpers were recently extracted from `GameState.gd` into modules (`FreightDocRules.gd`, `CustomsReportFormatter.gd`, issue-0101).  
What’s missing is a coherent, stable **Level 2 orchestration layer** that (a) builds a consistent context snapshot, (b) runs invariants, (c) deterministically classifies results, (d) maps invariant failures into findings, and (e) attaches this to the inspection report as a standard payload.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements.

- Add a dedicated **Level 2 audit module** responsible for producing a stable `level2_audit` dictionary from an inspection context snapshot.
- Reuse `CustomsInvariants.evaluate(ctx)` as the invariant engine; do not duplicate invariant logic in the pipeline.
- Deterministically derive `level2_audit.classification` from invariant results (invalid > suspicious > clean) and generate a stable, sorted list of `findings` for failed invariants.
- Integrate in `Customs.gd` so that when Level 2 depth is reached, the report includes `level2_audit` (and remains compatible with existing logging via `CustomsReportFormatter`).
- Ensure missing inputs degrade gracefully (not evaluable/empty findings) and never crash.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `res://singletons/Customs.gd`
- `res://scripts/customs/CustomsInvariants.gd` (only if schema alignment is required; prefer no change)
- `res://scripts/customs/CustomsReportFormatter.gd` (only if compatibility adjustments are required; prefer no change)

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/MainGame.tscn`

---

## New Files Allowed?
- [x] Yes (must list exact paths below)
- [ ] No

If Yes, list exact new file paths:

- `res://scripts/customs/CustomsLevel2Audit.gd`

---

## Public API Changes
List any new or modified public methods, signals, or resources.  
If none, write “None”.

- `CustomsLevel2Audit.build_level2_audit(ctx: Dictionary) -> Dictionary` (new; pure/deterministic)
- `Customs.gd` report payload includes `report["level2_audit"]` when Level 2 depth is invoked (existing signal payload extended; no signal signature change)

---

## Data Model & Persistence
Required if this job adds or modifies saved state **or introduces new required in-memory fields**.

- New or changed saved fields:
  - None.
- Migration / backward-compat expectations:
  - Older saves load unchanged; Level 2 simply omits `level2_audit` unless Level 2 is invoked.
- Save/load verification requirements:
  - Load an older save and confirm inspections run without errors and Level 1 behavior is unchanged.

---

## Determinism & Stability (If Applicable)
- What must be deterministic?
  - `level2_audit.classification`, ordering/content of `level2_audit.findings`, and the invariant result list for the same state snapshot.
- What inputs must remain stable?
  - `system_id`, effective checkpoint/location_id, `GameState.time_tick`, `freight_docs` content, evidence flags, and cargo snapshot.
- What must not introduce randomness or time-based variance?
  - No wall clock, no non-seeded randomness, no iteration-order dependence (must sort keys/ids for stable output).

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] When a customs inspection is executed at Level 2 depth (via existing paths), the emitted report includes `level2_audit` with: `classification`, `invariants`, and `findings`.
- [ ] `level2_audit.classification` is deterministically derived from invariant results:
  - any failed invariant with severity `invalid` => `invalid`
  - else any failed invariant => `suspicious`
  - else => `clean`
- [ ] Route consistency remains non-evaluable: `L2INV-002` must not be evaluated for origin/destination mismatch until mandated-route contracts exist.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Run a scenario that triggers a customs inspection which reaches Level 2 depth (existing deterministic path). Confirm the report contains `level2_audit` with expected keys.
2. Create a deterministic invariant failure (e.g., mismatch cargo vs declaration quantities) and re-run the same context (same system/location/tick) to confirm the same invariant id fails and the same `level2_audit.classification` is produced.
3. Confirm no cargo/credits/time/documents are modified by Level 2 evaluation (compare before/after state snapshots; verify no extra time advancement).

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Missing/partial docs or missing cargo snapshot: Level 2 must produce `not_evaluable` invariant statuses and/or empty findings without crashing.
- Systems with no locations / checkpoint fallback: Level 2 must evaluate deterministically using the existing effective-checkpoint selection logic.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Existing code may not have a clean “Level 2 depth invoked here” seam; integration must be minimal and must not introduce new triggers.
- Report schema compatibility: if older fields (e.g., `level2_invariant_summary`) exist, ensure they remain coherent or are derived from `level2_audit` without breaking consumers.
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
- Summary of changes and rationale
- Files changed (with brief explanation per file)
- Assumptions made
- Known limitations or TODOs

---

## Logging Checklist
- [ ] All explicit player actions that succeed or fail emit a clear log entry
- [ ] All time advancement paths log a reason and tick delta
- [ ] No UI-only interactions produce log entries
- [ ] No per-frame or loop-driven spam was introduced
- [ ] Log messages are human-readable
- [ ] `print()` usage is debug-only or removed in favor of `Log.add_entry()`
- [ ] Log volume feels appropriate for a capped, recent-history log