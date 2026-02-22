# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0091
- Short Title: Persist Customs pressure escalation across travel and time (no enforcement)
- Run Folder Name: issue-0091-feature-persist-customs-pressure-escalation
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-02-21

---

## Goal
Make Customs pressure escalation **persist as state** (per location) instead of resetting implicitly, so inspection depth/gating remains consistent across travel and repeated actions.  
This is a detection-only systems change: persistence must not introduce enforcement, penalties, or new UI.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- No enforcement is introduced: no fines, seizures, holds, forced delays, or cargo/credit mutation beyond what already exists today.
- Customs pressure bucketing, deterministic triggers, and Level 1/2 audit semantics remain unchanged except for persisting the pressure state that already exists.
- Pressure evolution remains deterministic for the same sequence of player actions and time-ticks; no RNG or wall-clock time is introduced.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- Do not add Port Authority systems, inspections, or any enforcement outcomes (fines/seizures/holds/tariffs/reputation).
- Do not add new UI panels or new persistent HUD elements (logs are allowed if already part of existing flows).

---

## Context
Customs pressure exists as a concept and is surfaced read-only in the UI/logs, and certain actions can increase pressure.  
However, pressure does not currently behave like stable state across typical player loops (travel, docking/undocking, time advancement), which undermines inspection depth predictability and “perception before simulation.”  
We need pressure escalation to persist per relevant scope (location) and remain available when evaluating inspections and previews.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements. ⬅️ NEW

- Identify the canonical pressure state storage in `GameState` and ensure it is keyed deterministically by location (and system if required by existing data model).
- Ensure all existing pressure read paths (bucketing, preview lines, inspection context) read from the same persisted state.
- Ensure all existing pressure write paths (pressure increases) update the persisted state only (no new outcomes).
- Add a minimal, deterministic pressure decay rule only if an existing stable time-tick hook already exists and is used elsewhere; otherwise, do not add decay in this job.
- Add/adjust logs only where necessary to confirm persistence changes without spamming.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `singletons/GameState.gd`
- `singletons/Customs.gd`

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

## Public API Changes
List any new or modified public methods, signals, or resources.  
If none, write “None”.

- None (preferred). If an accessor is required, it must be internal/private unless already part of the existing public surface.

---

## Data Model & Persistence
Required if this job adds or modifies saved state **or introduces new required in-memory fields**. ⬅️ NEW

- New or changed saved fields:
  - If a save system is already present: add/extend the saved field that stores customs pressure per location (exact field name must follow existing conventions).
  - If no save system exists: store pressure persistently **in-memory** only and explicitly document this limitation in `results.md`.
- Migration / backward-compat expectations:
  - If adding a new saved field, default missing values to the current baseline pressure state without errors.
- Save/load verification requirements:
  - If save/load exists: verify pressure values survive save -> reload and are consistent across travel.

---

## Determinism & Stability (If Applicable) ⬅️ NEW
- What must be deterministic?
  - Pressure persistence and any updates (increase/optional decay) must be deterministic given the same action/tick sequence.
- What inputs must remain stable?
  - Location IDs (and system IDs if used) must be the sole keys; no node paths, UI state, or time-of-day.
- What must not introduce randomness or time-based variance?
  - No RNG; no wall-clock time; no frame-time deltas; only existing game tick/time advancement primitives if already used.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] After a pressure increase event occurs at a location, leaving and returning (or performing multiple actions over time) shows the same pressure state is still in effect (until changed by existing rules).
- [ ] Inspection preview / inspection depth gating uses the persisted pressure state and produces consistent results across repeated visits.
- [ ] No new enforcement behaviors are introduced; gameplay outcomes remain unchanged aside from pressure now behaving like stable state.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Start a session, travel to a location, and perform an action known to raise Customs pressure (e.g., a flagged sale/inspection path).
2. Observe the pressure readout/log state at the location; then travel away to another system/location and return.
3. Verify the original location’s pressure state is unchanged (persisted) and inspection previews/depth gating reflect it.
4. If save/load exists: save the game, reload, and verify the pressure state at the location is preserved and still drives inspection behavior.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Locations missing from the influence/pressure context (no locations in system): pressure read/write must fail safely (no crash) and default deterministically.
- New/unseen location IDs: pressure state initializes to baseline deterministically with no errors.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Risk: Multiple competing pressure storage paths exist (Customs vs GameState). This job must ensure a single canonical source of truth.
- Risk: Persisting pressure may reveal design gaps (e.g., no decay rule). If decay requires new systems, leave it out and document it as a follow-up.
- If assumptions prove false, Codex must stop and report rather than inventing solutions. ⬅️ NEW

---

## Governance & Review Gates (Mandatory) ⬅️ NEW
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
