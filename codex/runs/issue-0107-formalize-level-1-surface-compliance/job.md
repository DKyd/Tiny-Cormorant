# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0107
- Short Title: Formalize Level 1 surface compliance checks and Level 1 audit payload
- Run Folder Name: issue-0107-formalize-level-1-surface-compliance
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-02-23

---

## Goal
When a customs inspection reaches **Level 1 depth**, the game must produce a deterministic, structured **Level 1 audit payload** (`level1_audit`) that reports surface compliance issues (missing required docs, missing required fields, malformed/empty obvious data) and attach it to the inspection report.  
This adds the “paperwork formalism” primitives required by the North Star without adding enforcement.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Level 1 evaluation is deterministic for the same stable inputs (system_id, location_id/effective checkpoint, tick, cargo snapshot, freight docs snapshot, evidence flags).
- Level 1 performs **no enforcement** and **no state mutation** (no cargo/credits/time/doc changes); it only reads state and emits report fields/logs.
- Existing inspection triggers, pressure, and max depth selection remain unchanged; Level 1 only runs when Level 1 depth is already selected by existing paths.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- Do NOT add enforcement (no fines, holds, seizures, delays, tariffs, arrests, or reputation changes).
- Do NOT implement issuer/signature validation beyond placeholder field presence checks (no cryptography, no verification, no new authority simulation).

---

## Context
Customs currently supports deterministic inspection rolls and pressure bucketing, and Level 2 audits are now formalized with a `level2_audit` payload and invariant findings (issues 0100–0106).  
What’s missing per the North Star is **Phase A paperwork formalism**: Level 1 “surface compliance” checks that validate required docs/fields and produce a stable payload that can later drive UI and enforcement.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements.

- Add a dedicated Level 1 module that produces `level1_audit` from an inspection context snapshot (pure/deterministic).
- Define a minimal required-field schema for the doc types currently produced/used in gameplay (Contract, FreightDoc/declaration-like, Bill of Sale if present, container_meta if present).
- Implement Level 1 findings for: missing required docs, missing required fields, empty required arrays (e.g., cargo_lines empty), and obviously malformed values (blank ids, non-positive qty where required).
- Deterministically derive `level1_audit.classification` and stable sorted findings; attach to the report when Level 1 depth is invoked.
- Keep compatibility: do not remove existing report fields; only extend payload.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `res://singletons/Customs.gd`
- `res://scripts/customs/CustomsReportFormatter.gd` (only if needed to keep logs coherent; prefer minimal/no change)

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

- `res://scripts/customs/CustomsLevel1Audit.gd`

---

## Public API Changes
List any new or modified public methods, signals, or resources.  
If none, write “None”.

- `CustomsLevel1Audit.build_level1_audit(ctx: Dictionary) -> Dictionary` (new; pure/deterministic)
- `Customs.gd` report payload includes `report["level1_audit"]` when Level 1 depth is invoked (existing report extended; no signature changes)

---

## Data Model & Persistence
Required if this job adds or modifies saved state **or introduces new required in-memory fields**.

- New or changed saved fields:
  - None.
- Migration / backward-compat expectations:
  - Older saves load unchanged; Level 1 simply omits `level1_audit` unless Level 1 is invoked.
- Save/load verification requirements:
  - Load an older save and confirm inspections run without errors and existing logs still appear.

---

## Determinism & Stability (If Applicable)
- What must be deterministic?
  - `level1_audit.classification`, ordering/content of `level1_audit.findings`, and any derived required-field results for the same snapshot.
- What inputs must remain stable?
  - `system_id`, effective checkpoint/location_id, `tick`, `docs` snapshot, cargo snapshot, evidence flags (if referenced).
- What must not introduce randomness or time-based variance?
  - No wall clock, no non-seeded randomness, no iteration-order dependence (sort keys/ids for stable output).

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] When a customs inspection runs at Level 1 depth, the emitted report includes `level1_audit` with keys: `classification`, `checks`, and `findings`.
- [ ] `level1_audit.findings` is stable and sorted (deterministic ordering) for the same context.
- [ ] `level1_audit.classification` is deterministically derived:
  - any finding with severity `invalid` => `invalid`
  - else any finding => `suspicious`
  - else => `clean`

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Trigger a customs inspection that runs at Level 1 depth. Confirm the report includes `level1_audit` and logs remain readable.
2. Create a surface-compliance failure (e.g., remove/blank a required field in a FreightDoc or create a doc with empty cargo_lines) and re-run the same context to confirm the same finding id appears and the same classification results.
3. Confirm no cargo/credits/time/docs are mutated by Level 1 evaluation (compare before/after snapshots; verify no extra time advancement).

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Missing docs snapshot or missing cargo snapshot: Level 1 must produce `unavailable/not_evaluable` check entries and/or empty findings without crashing.
- Documents present but partially malformed (blank ids, missing arrays): findings should be produced without exceptions.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Existing report schema consumers may expect older fields; integration must be additive-only.
- Required-field schema may not match current doc shapes; if assumptions prove false, Codex must stop and report rather than inventing solutions.
- If Level 1 and Level 2 both run in the same inspection path, ensure they remain independent payloads (no retroactive changes).

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
