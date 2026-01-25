# Refactor Job

## Metadata (Required)
- Issue/Task ID: issue-0073
- Short Title: Deterministic customs entry checks via GameState helpers
- Run Folder Name: issue-0073-refactor-customs-entry-determinism
- Job Type: refactor
- Author (human): DKyd
- Date: 2026-01-25

---

## Goal
Enforce the North Star responsibility split for **system entry customs checks** by:
- moving **entry jurisdiction selection** (highest-pressure location) into `GameState.gd`
- moving **deterministic inspection roll** (seeded/replicable) into `GameState.gd`
- refactoring `Customs.gd` to **only** decide whether to attempt an inspection (bucket ? chance) and delegate selection/roll to `GameState`

No behavior changes are intended beyond:
- eliminating nondeterminism from inspection attempts
- ensuring entry jurisdiction selection matches North Star verbatim

---

## Non-Goals
- No gameplay changes beyond determinism correctness and jurisdiction selection correctness.
- No feature additions (no new inspection levels, no new penalties, no UI work).
- No changes to inspection classification logic, evidence flags, or freight doc validation.
- No tuning of chance values or pressure formula.
- No cleanup outside the customs entry flow / helper additions required for this refactor.

---

## Invariants (Must Remain True)
- Time advances only via `GameState.advance_time(reason)`.
- Docked UI interactions do not advance time.
- GameState remains authoritative for transitions.
- UI does not mutate state directly.
- Economy determinism remains keyed by `(system_id, tick, market_kind)`.

### Job-Specific Invariants (Must Remain True)
- `Customs.gd` decides **whether** an inspection attempt occurs (bucket ? chance).
- `GameState.gd` decides **how** an inspection works (pressure computation, buckets, location selection, deterministic roll, inspection execution/reporting).
- `Customs.gd` MUST NOT:
  - compute customs pressure
  - select entry jurisdiction locations
  - inspect documents directly
  - mutate cargo, credits, or freight docs
  - call global RNG (`randf()`, `randi()`, etc.) for inspection attempts
- System entry jurisdiction selection MUST be deterministic and pressure-driven:
  - select the **highest-pressure location** in the system
  - ties broken by lexicographically smallest `location_id`
- Randomness (inspection frequency) MUST be deterministic / seedable and must not rely on global RNG state.

---

## Scope

### Files Allowed to Modify (Whitelist)
- `scripts/Customs.gd`
- `singletons/GameState.gd`

### Files Forbidden to Modify (Blacklist)
- `data/**`
- `scenes/MainGame.tscn`

---

## Approach (High Level)
1) Add **two public helpers** to `GameState.gd`:
   - `get_entry_customs_location_id(system_id: String) -> String`
   - `roll_customs_inspection(system_id: String, location_id: String, action: String, chance: float) -> bool`
2) Refactor `Customs.gd::run_entry_check` to:
   - stop selecting locations or using `current_location_id` fallbacks
   - call `GameState.get_entry_customs_location_id(system_id)` for jurisdiction
   - compute bucket via `GameState.get_customs_pressure_bucket(location_id)`
   - map bucket ? chance using existing `inspection_chance`
   - perform roll via `GameState.roll_customs_inspection(...)`
   - if roll passes, call `GameState.run_customs_inspection(...)`
3) Preserve behavior equivalence except for:
   - eliminating non-determinism (`randf()`) in inspection attempts
   - aligning jurisdiction selection with North Star (highest-pressure location)

---

## Detailed Requirements (Must Implement)

### A) GameState.gd — Entry Jurisdiction Selection Helper
Add:
```gdscript
func get_entry_customs_location_id(system_id: String) -> String:
```
Rules:

If system_id is empty OR Galaxy.get_system(system_id) is empty ? return ""

Evaluate all locations from Galaxy.get_location_ids_for_system(system_id)

For each candidate location_id, compute pressure using existing get_customs_pressure(location_id)

Select the location with the maximum pressure

Tie-break: lexicographically smallest location_id

No randomness, no side effects

B) GameState.gd — Deterministic Inspection Roll Helper
Add:

func roll_customs_inspection(system_id: String, location_id: String, action: String, chance: float) -> bool:
Rules:

Clamp chance to [0.0, 1.0]

MUST NOT use randf() / global RNG

MUST be deterministic/seedable

Recommended seed inputs (stable + explainable):

system_id, location_id, action, time_tick

Implementation guidance:

derive an integer hash from a seed string and convert to a unit float in [0, 1)

return roll <= chance (or equivalent deterministic comparison)

No side effects

C) Customs.gd — Refactor run_entry_check
Modify run_entry_check(system_id: String, location_id: String = "") so that:

It does NOT:

default to GameState.current_location_id

sort/pick first location

use randf()

It DOES:

Validate system exists as it currently does

Determine entry jurisdiction by calling:
location_id = GameState.get_entry_customs_location_id(system_id)

If empty ? return

Compute bucket:
var bucket: String = GameState.get_customs_pressure_bucket(location_id)

Chance lookup:
var chance: float = float(inspection_chance.get(bucket, 0.3))

Deterministic roll:
if not GameState.roll_customs_inspection(system_id, location_id, "ENTRY_CLEARANCE", chance): return

If roll passes, call GameState.run_customs_inspection({ ... }) as before

Note: Customs.gd may continue to log the final inspection message; no other logging changes are required.

Verification
Manual Test Steps
Start a new game (or load a save) and travel to a system where current_location_id becomes "" on arrival.

Confirm that entry checks (when they occur) consistently reference the same jurisdiction for that system (highest-pressure location).

Repeat step 1–2 multiple times (including restarting the game) and verify behavior is reproducible (no reliance on global RNG state).

Confirm no errors/warnings are introduced and that the game continues to run normally.

Regression Checklist
 No UI action advances time

 No state mutation moved into UI

 Logs still reflect real player actions

 No protected paths touched

 No randf() / global RNG used for customs inspection attempt decisions

 Entry jurisdiction selection matches North Star: highest-pressure location with lexicographic tie-break

Codex Scaffolding & Output Requirements (Mandatory)
Codex must perform the following before any code changes:

Create codex/runs/<Run Folder Name>/

Write this job verbatim to codex/runs/<Run Folder Name>/job.md

Create codex/runs/<Run Folder Name>/results.md if missing

Write codex/runs/ACTIVE_RUN.txt = <Run Folder Name>

Codex must write final results only to:

codex/runs/<Run Folder Name>/results.md

Results must include:

Summary of refactor

Files changed

Manual test results

Confirmation behavior is unchanged (except determinism/jurisdiction correctness as specified)

Follow-ups / known gaps (if any)

Migration Notes
None.

Logging Checklist
 No debug spam added

 No meaningful logs removed

 print() removed or debug-only

 Log volume appropriate
