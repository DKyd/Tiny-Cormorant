# Bugfix Job

## Metadata (Required)
- Issue/Task ID: issue-0085
- Short Title: Fix docking failure / unable to dock at locations
- Run Folder Name: issue-0085-bug-cannot-dock-at-locations
- Job Type: bugfix
- Author (human): Douglass
- Date: 2026-02-20

---

## Bug Description
Player is unable to dock at locations. Attempting to dock does not transition the game into a docked state (or otherwise prevents docking), blocking normal gameplay loops that require docking (market, contracts, etc.).

---

## Expected Behavior
When the player selects a valid location and chooses to Dock, the game should successfully dock at that location:
- `current_location_id` becomes the selected location
- docked UI/state activates as normal
- any relevant logs/notifications appear
- no erroneous “no route” / “cannot dock” behavior occurs unless truly invalid

---

## Repro Steps
1. Launch the game and load/start a run.
2. Travel to any system with at least one valid location.
3. From the map/system/location UI, attempt to dock at a location (click Dock / select location ? Dock).
4. Observe docking does not occur.

---

## Observed Output / Error Text
- UI message: Dock button does not perform docking action.
- Log lines (CUSTOMS / SHIP / OTHER): No docking transition log from Dock button path.
- Godot output/errors: none observed from static path review.

---

## Suspected Area (Optional)
- MapPanel / navigation UI (dock action wiring)
- Port/Bridge transition logic
- GameState location change / docking state

---

## Scope Constraints
- Changes are limited strictly to fixing the described bug.
- No refactors, cleanup, stylistic changes, or redesigns.
- No new features may be introduced.

---

## Files: Allowed to Modify (Whitelist)
- `singletons/GameState.gd`
- `scripts/MapPanel.gd`
- `scripts/Bridge.gd`
- `scripts/Port.gd`
- `scripts/ui/*` (ONLY if required to fix Dock button wiring)

---

## Files: Forbidden to Modify (Blacklist)
- `data/**`
- `scenes/MainGame.tscn`

---

## New Files Allowed?
- [x] No

---

## Acceptance Criteria (Must Be Testable)
- [ ] Player can dock at a valid location in a system with locations.
- [ ] Docking correctly updates game state (location/system) and UI/state transitions occur as expected.
- [ ] No new errors appear in Godot output when docking.
- [ ] If docking is invalid (no locations / impossible state), player receives a clear message and the game does not crash.

---

## Regression Checks
- Travel between systems still works.
- Customs inspection triggers at player-action boundaries (sell/depart/entry) still function.
- Market / Black Market panels still open normally when docked (if they previously worked).

---

## Manual Test Plan
1. Start a new run (or load a save).
2. Select a system with known locations and attempt Dock at 2 different locations.
3. Confirm `current_location_id` changes and port UI/state appears.
4. Undock (if available), then dock again to confirm repeatability.
5. Attempt docking in an edge case system with zero locations (if any exist) and confirm graceful failure message.

---

## Codex Scaffolding & Output Requirements (Mandatory)
1) Create `codex/runs/<Run Folder Name>/`
2) Write this job verbatim to `codex/runs/<Run Folder Name>/job.md`
3) Create `codex/runs/<Run Folder Name>/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `<Run Folder Name>`

Codex must write final results only to:
- `codex/runs/<Run Folder Name>/results.md`

Results must include:
- Root cause summary
- Fix summary
- Files changed (and why)
- Manual tests performed
- Regression checks performed
- Remaining risks or follow-ups
