# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0074
- Short Title: Wire deterministic customs entry inspections on system arrival
- Run Folder Name: issue-0074-feature-entry-inspections
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-25

---

## Goal
Ensure that Customs entry inspections are triggered deterministically at the player-action boundary of **successful system arrival**, using the existing deterministic jurisdiction selection and deterministic roll infrastructure.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Time advances only via `GameState.advance_time(reason)`.
- Docked UI interactions do not advance time.
- Entry inspections must remain deterministic (no global RNG usage) and must not rely on `randf()` or RNG state.
- Customs inspections must not mutate cargo, credits, or freight documents (inspection is evaluation + logging only).

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- Do not add enforcement outcomes (no fines, seizures, holds, denial of travel/sale, or reputation effects).
- Do not refactor unrelated systems (UI, economy, contracts, org influence, freight doc editing) beyond the minimal wiring required.
- Do not introduce new inspection levels, audit logic, or port authority simulation.

---

## Context
Describe relevant existing systems, scenes, or scripts.  
Include what already exists and what is missing.  
Do not propose solutions here.

- `res://singletons/Customs.gd` contains `run_entry_check(system_id)` which:
  - selects a deterministic entry jurisdiction using `GameState.get_entry_customs_location_id(system_id)`
  - derives an inspection chance from `GameState.get_customs_pressure_bucket(location_id)` and a bucket map
  - performs a deterministic roll using `GameState.roll_customs_inspection(system_id, location_id, "ENTRY_CLEARANCE", chance)`
  - when rolled-in, calls `GameState.run_customs_inspection({ action="ENTRY_CLEARANCE" })` and logs summary output
- `res://singletons/GameState.gd` already provides:
  - `get_entry_customs_location_id(system_id)` (highest-pressure location in system; tie-break lexicographic)
  - `roll_customs_inspection(system_id, location_id, action, chance)` (deterministic hash-based roll seeded by `(system_id, location_id, action, time_tick)`)
  - `run_customs_inspection(context)` which evaluates document evidence/surface compliance and emits logs/signals without enforcement
- Missing: `Customs.run_entry_check()` is not currently guaranteed to fire at the actual system-arrival boundary during inter-system travel.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements.

- Identify the authoritative player-action boundary for “system arrival” (successful completion of `GameState.travel_to_system`).
- Wire a single call to `Customs.run_entry_check(new_system_id)` on successful arrival only.
- Ensure the call occurs after inter-system travel time advancement so the deterministic roll uses the correct arrival `time_tick`.
- Confirm that entry checks do not trigger during intra-system docking changes, UI navigation, or failed travel attempts.
- Keep logging behavior non-spammy (no logs on roll miss; existing logs on roll hit remain unchanged).

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

- None

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
  - Whether an entry inspection attempt occurs must remain deterministic and must use `GameState.roll_customs_inspection(...)`.
  - Jurisdiction selection must remain deterministic via `GameState.get_entry_customs_location_id(system_id)`.
- What inputs must remain stable?
  - Deterministic roll inputs remain `(system_id, location_id, action, time_tick)`; action remains `"ENTRY_CLEARANCE"`.
- What must not introduce randomness or time-based variance?
  - Do not use `randf()`, `RandomNumberGenerator`, or global RNG state.
  - Do not add time-based variance outside of existing `time_tick`.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] On every **successful** inter-system travel arrival, exactly one entry-check attempt is made via `Customs.run_entry_check(new_system_id)`.
- [ ] Entry checks do **not** fire on failed travel attempts (unknown system, insufficient credits, or no route).
- [ ] Entry checks do **not** fire due to docking changes (`set_current_location`) or UI navigation between Bridge/Port panels.
- [ ] Entry checks remain deterministic (no use of global RNG / `randf()`).
- [ ] Entry checks do not mutate cargo, credits, or freight documents; only evaluation + logging occurs.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Launch the game and note current tick (and optionally open the log panel).
2. Travel to a different system using the Bridge navigation.
3. Confirm inter-system travel advances time by the expected number of ticks and that an entry-check attempt occurs on arrival:
   - On roll miss: no customs spam/log beyond existing travel logs.
   - On roll hit: customs inspection logs appear (existing format), and the inspection action is `"ENTRY_CLEARANCE"`.
4. Repeat step 2 a few times across different systems and confirm:
   - Entry checks only occur on successful arrivals.
   - Docking within a system does not trigger entry checks.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Traveling to an unknown system should not trigger an entry check and should not crash.
- Systems with zero locations must not crash; entry check should safely no-op (existing `get_entry_customs_location_id` returns empty).

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Risk: placing the entry-check call before time advancement would change which `time_tick` seeds the roll; ensure wiring occurs after travel ticks advance.
- Risk: calling entry checks on non-arrival events (signals/UI refresh) would create perceived “random” spam; ensure wiring is only in the travel success path.
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
