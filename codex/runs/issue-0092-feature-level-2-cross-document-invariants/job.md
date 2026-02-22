# Feature Job

## Metadata (Required)
- Issue/Task ID: feature-0092
- Short Title: Level-2 Cross-Document Invariants (Detection Only)
- Run Folder Name: feature-0092-level-2-cross-document-invariants
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-02-21

---

## Goal
Introduce Level-2 inspection logic that evaluates cross-document consistency (invariants) during customs inspections. The system must detect and report document contradictions without applying enforcement, penalties, or gameplay consequences.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Inspections remain detection-only (no fines, seizures, holds, or reputation effects).
- Deterministic inspection behavior remains fully preserved.
- Customs does not directly mutate GameState outside existing inspection boundaries.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- No enforcement mechanics (fines, seizure, holds, tariffs).
- No authenticity scoring system.
- No UI changes or new inspection banners.
- No modification of cargo data structures.
- No reputation or faction impact logic.

---

## Context
Customs currently evaluates surface-level document validity (Phase 1) and operates deterministically based on pressure buckets and triggers. Contracts are signed at acceptance, and inspection entry checks are functional.

However, Customs does not yet evaluate whether related documents agree with each other (e.g., manifest vs. contract quantity). There is no centralized cross-document invariant evaluation layer.

This job introduces that detection layer without altering enforcement or persistence.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  

- Introduce a dedicated `_evaluate_cross_document_invariants()` method in `Customs.gd`.
- Define a centralized list of Level-2 invariant checks.
- During inspection resolution, call invariant evaluation after Phase-1 checks.
- Return structured invariant violations in the inspection result object.
- Log invariant violations under the CUSTOMS log channel (human-readable).

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `res://singletons/Customs.gd`
- `res://singletons/GameState.gd` (inspection report wiring for Level-2 invariant output; no gameplay/enforcement mutation)

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

- N/A

---

## Public API Changes
List any new or modified public methods, signals, or resources.  
If none, write “None”.

- Customs inspection result structure may gain:
  - `invariant_violations: Array`
- No public method signatures removed or renamed.

---

## Data Model & Persistence
Required if this job adds or modifies saved state **or introduces new required in-memory fields**.

- New or changed saved fields:
  - None
- Migration / backward-compat expectations:
  - Fully backward compatible.
- Save/load verification requirements:
  - No save format changes.

---

## Determinism & Stability (If Applicable)
- What must be deterministic?
  - Invariant evaluation must produce identical results for identical world state.
- What inputs must remain stable?
  - system_id, location_id, time_tick, cargo contents, contract data.
- What must not introduce randomness or time-based variance?
  - No RNG, no time-based drift, no floating-point instability in comparisons.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] Inspections detect mismatched quantities between manifest and contract.
- [ ] Inspections detect missing or destroyed supporting documents.
- [ ] No enforcement or gameplay side effects occur when violations are detected.
- [ ] All violations are logged under CUSTOMS channel.
- [ ] Deterministic re-run of the same inspection yields identical violation output.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Accept a freight contract and load matching cargo.
2. Modify cargo quantity manually (simulate mismatch).
3. Trigger system entry inspection.
4. Confirm CUSTOMS log reports invariant violation.
5. Reload game state and repeat inspection to confirm deterministic output.
6. Confirm no fines, holds, or cargo changes occurred.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Missing document references should produce a violation entry rather than crash.
- Null or empty cargo arrays must not cause runtime errors.
- Partial cargo delivery must not falsely trigger invariant violation unless mismatch exists.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Cross-document evaluation must not introduce hidden mutation.
- Care must be taken not to duplicate Phase-1 validation logic.
- If assumptions about contract data structure prove false, Codex must stop and report rather than inventing solutions.

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
  - `codex/runs/feature-0092-level-2-cross-document-invariants/**`
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
  - `git commit -m "feature-0092: Level-2 Cross-Document Invariants (Detection Only)"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- STOP.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/feature-0092-level-2-cross-document-invariants/`
2) Write this job verbatim to `codex/runs/feature-0092-level-2-cross-document-invariants/job.md`
3) Create `codex/runs/feature-0092-level-2-cross-document-invariants/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `feature-0092-level-2-cross-document-invariants`

Codex must write final results only to:
- `codex/runs/feature-0092-level-2-cross-document-invariants/results.md`

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
