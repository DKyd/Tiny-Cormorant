# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0076
- Short Title: Add deterministic customs clearance on port departure
- Run Folder Name: issue-0076-feature-port-departure-clearance
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-25

---

## Goal
Introduce a deterministic Customs inspection attempt when the player departs a docked location to travel between systems. Port departure clearance should mirror entry and sale checks: pressure-driven, deterministic, and non-blocking.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Time advances only via `GameState.advance_time(reason)`.
- Docked UI interactions do not advance time.
- Randomness affects **whether** a check occurs, never inspection outcomes.
- All Customs inspection attempts remain deterministic and reproducible.
- Customs inspections do not mutate cargo, credits, or freight documents.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- Do not add enforcement outcomes (fines, seizures, holds, denial of travel).
- Do not block or delay travel based on inspection results.
- Do not add Port Authority simulation, crew checks, or ship operations logic.
- Do not refactor existing inspection logic beyond the minimal wiring required.

---

## Context
Describe relevant existing systems, scenes, or scripts.  
Include what already exists and what is missing.  
Do not propose solutions here.

- `Customs.run_entry_check(system_id)` performs deterministic inspection gating for system entry using pressure bucket ? chance ? deterministic roll.
- `Customs.run_sale_check(system_id, location_id)` performs deterministic inspection gating for legal cargo sales.
- `GameState.travel_to_system(new_system_id)` handles inter-system travel, including time advancement and entry checks on arrival.
- There is currently no explicit Customs inspection triggered at the moment the player departs a docked location; departure is an unobserved boundary.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements.

- Introduce a Customs helper to evaluate whether a departure inspection should occur, mirroring entry and sale patterns.
- Trigger the departure inspection only when leaving a docked state (`current_location_id != ""`) to initiate inter-system travel.
- Use the docked location’s customs pressure bucket to derive inspection chance.
- Perform a deterministic roll keyed to the pre-departure tick and a stable action identifier.
- Execute inspection via `GameState.run_customs_inspection(...)` only when the roll passes.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `res://singletons/GameState.gd`
- `res://singletons/Customs.gd`

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

- (none)

---

## Public API Changes
List any new or modified public methods, signals, or resources.  
If none, write “None”.

- Add: `Customs.run_departure_check(system_id: String, location_id: String) -> void`
- None (no other public API changes)

---

## Data Model & Persistence
Required if this job adds or modifies saved state **or introduces new required in-memory fields**.

- New or changed saved fields:
  - None
- Migration / backward-compat expectations:
  - None
- Save/load verification requirements:
  - None

---

## Determinism & Stability (If Applicable)
- What must be deterministic?
  - Whether a port-departure inspection occurs.
- What inputs must remain stable?
  - `(system_id, location_id, action="PORT_DEPARTURE_CLEARANCE", time_tick)` and the pressure bucket ? chance mapping.
- What must not introduce randomness or time-based variance?
  - No use of `randf()`, global RNG state, or wall-clock time.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] When departing a docked location for inter-system travel, exactly one deterministic departure inspection attempt is made.
- [ ] Departure inspections do not trigger when the player is already undocked or during UI-only interactions.
- [ ] Departure inspections do not block travel or mutate cargo, credits, or freight documents.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Dock at a location with cargo and valid documents.
2. Initiate inter-system travel from the docked state.
3. Observe that:
   - Travel proceeds normally.
   - Sometimes a Customs inspection occurs at departure (depending on deterministic roll).
   - When it occurs, logs reference a departure clearance action.
4. Repeat with multiple departures across different ticks to verify deterministic behavior.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Initiating travel when `current_location_id` is empty must not trigger a departure inspection.
- Invalid or empty `system_id` or `location_id` must not crash; inspection should safely no-op.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Risk: Triggering departure inspections after time advancement would seed rolls incorrectly; ensure rolls occur on the pre-departure tick.
- Risk: Accidental double-inspection (departure + entry) must be avoided by scoping checks strictly to their boundaries.
- If assumptions prove false, Codex must stop and report rather than inventing solutions.

---

## Governance & Review Gates (Mandatory)
- Codex must not make code changes until required preflight/review steps are complete.
- Codex must present diffs for review before declaring results final.
- If scope, whitelist, or non-goals are violated, Codex must stop and report the issue.

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
