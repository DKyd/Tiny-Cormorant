# Refactor Job

## Metadata (Required)
- Issue/Task ID: issue-0086 
- Short Title: refactor docking into in-system vs at-location state
- Run Folder Name: issue-0086-refactor-dock-undock-state 
- Job Type: refactor
- Author (human): Douglass Kyd
- Date: 2026-02-21

---

## Goal
Refactor navigation/docking so player position is represented cleanly as:

- **In-system (not at a location)**: `current_system_id` set, `current_location_id == ""`
- **Docked (at a location)**: `current_system_id` set, `current_location_id != ""`

Dock/Undock become explicit transitions between these two states, and UI verbiage reflects “Dock” vs “Undock” based on whether the player is currently at a location.

This structural cleanup is intended to remove ambiguous “docked” gating logic and make future routing/port/market work predictable.

**Bounded behavior change (acceptable for this job):**
- Docking is only possible when the player is **in-system and not currently at a location**.
- Undocking moves the player from a location to its parent system (i.e., clears `current_location_id` but keeps `current_system_id`).
- Arriving to a system via Set Course places the player **in-system and not at a location** (no implicit docking on arrival).
- The Dock button label changes dynamically between “Dock” and “Undock” based on current state.

---

## Non-Goals
- No economy changes.
- No inspections/customs behavior changes.
- No new gameplay systems (fuel, holds, enforcement, etc.).
- No UI redesign beyond changing the Dock button label and making it call the new/refactored API.
- No save/migration format changes (if discovered necessary, STOP and report).

---

## Invariants (Must Remain True)
- Time advances only via `GameState.advance_time(reason)`.
- Dock/Undock UI interactions do not advance time.
- GameState remains authoritative for transitions.
- UI does not mutate state directly (UI calls GameState methods).
- Economy determinism remains keyed by `(system_id, tick, market_kind)`.

### Job-Specific Invariants
- Locations are nested within systems; `current_location_id` (when set) must belong to `current_system_id`.
- “Dock” action:
  - Valid only if `current_location_id == ""`
  - Sets `current_location_id` to a selected location that belongs to `current_system_id`
- “Undock” action:
  - Valid only if `current_location_id != ""`
  - Clears `current_location_id` and leaves `current_system_id` unchanged
- “Set Course (System)” does not change `current_location_id` directly; arrival results in `current_location_id == ""` in the destination system.
- Port/location context derives from `current_system_id` + `current_location_id`, not from a separate docked flag.
- If an existing `is_docked` variable exists, it must not gate Port access or docking logic after this refactor (it may remain temporarily but must be unused for gating).

---

## Scope

### Files Allowed to Modify (Whitelist)
- `singletons/GameState.gd`
- `singletons/Galaxy.gd` *(only if a “location ? system” helper is missing/incorrect or location containment checks are needed)*
- `scripts/Port.gd` *(only if Port context is currently gated by docked state and needs to read from GameState position state)*
- `scripts/ui/MapPanel.gd` *(if MapPanel owns Dock/Set Course UI logic)*
- `scripts/MapPanel.gd` *(alternate if MapPanel lives here)*
- Travel/arrival resolution script(s), **only if required to ensure arrival leaves player in-system and undocked**:
  - `scripts/Ship.gd`
  - `singletons/Travel.gd`
  - `scripts/Travel.gd`
  - or the specific file Codex identifies as the arrival resolver

### Files Forbidden to Modify (Blacklist)
- `data/**`
- `scenes/MainGame.tscn`

---

## Approach (High Level)
1) Identify current navigation state representation:
   - where `current_system_id`, `current_location_id`, and any “docked” flags are set/checked
   - where arrival/travel completion is resolved

2) Consolidate state and transitions in GameState:
   - Implement/standardize `dock_to_location(location_id)` and `undock()`
   - Ensure `dock_to_location` enforces containment: location must belong to `current_system_id`
   - Ensure arrival to a system results in `current_location_id == ""` (no implicit dock)

3) Update UI call sites:
   - Dock button calls either `dock_to_location(selected_location_id)` or `undock()` based on whether player is currently at a location
   - Dock button label dynamically displays “Dock” vs “Undock” based on `current_location_id`

4) Remove/disable any gating that prevents docking unless some legacy “is_docked” flag is set.
   - Preserve logs and determinism.

5) Confirm no time advancement is introduced.

---

## Verification

### Manual Test Steps
1) Start in **System A / Location A1** (docked). Confirm Dock button shows **Undock**.
2) Press **Undock**.
   - Expected: `current_system_id == A`, `current_location_id == ""`
   - Dock button now shows **Dock**
3) While in-system (A) and undocked, select **Location A2** and press **Dock**.
   - Expected: `current_location_id == A2`
4) Select **System B** and press **Set Course** (system-level).
5) Resolve travel/arrival using the game’s existing mechanism.
   - Expected on arrival: `current_system_id == B`, `current_location_id == ""` (undocked)
6) While in-system (B) and undocked, select **Location B1** and press **Dock**.
   - Expected: `current_location_id == B1`
7) Attempt to Dock to a location not in the current system (if UI allows selecting cross-system locations while undocked).
   - Expected: action is rejected safely (no state corruption); UI remains stable.

### Regression Checklist
- [ ] No UI action advances time
- [ ] No state mutation moved into UI
- [ ] Logs still reflect real player actions
- [ ] No protected paths touched
- [ ] No `.godot/**` churn (revert if present)

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
- Summary of refactor + bounded behavior change
- Files changed
- Manual test results
- Confirmation invariants are preserved
- Follow-ups / known gaps (if any)

---

## Migration Notes
None expected.
If a save/load dependency on legacy docked flags is discovered, do not change save format in this job. STOP and report.

---

## Logging Checklist
- [ ] No debug spam added
- [ ] No meaningful logs removed
- [ ] `print()` removed or debug-only
- [ ] Log volume appropriate