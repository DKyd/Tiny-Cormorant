# Bugfix Job

## Metadata (Required)
- Issue/Task ID: issue-0050
- Short Title: Dock selection fails after travel; Port shows map and cannot dock
- Run Folder Name: issue-0050-bug-dock-selection-fails-after-travel
- Job Type: bugfix
- Author (human): Douglass Kyd
- Date: 2026-01-19

---

## Bug Description
After traveling to a new system (e.g., Harvest-12) and pressing the Port button, the UI shows the Galaxy Map and the player cannot successfully dock even when a location row appears selected. Dock attempts produce “Select a location to dock.” and the game remains undocked.

This appears to be a selection/metadata mismatch: the visually highlighted location is not resolved to a valid dockable location_id by the Dock action.

---

## Expected Behavior
When the player selects a dockable location row in the Galaxy Map and presses Dock (or otherwise requests docking), the game should dock at that location and transition to the Port view as normal.

---

## Repro Steps
Provide the minimal steps required to reproduce the issue reliably.

1. Start from a docked location, purchase any commodity (optional, not required).
2. Travel to another system (e.g., set course to Harvest-12 and travel).
3. Press the Port button (or attempt to dock via Dock button on the Galaxy Map).
4. Select a location row (e.g., “Refinery Harvest-12-01 … [market]”) and press Dock.

---

## Observed Output / Error Text
- Repeated log line (on Dock attempts): “Select a location to dock.”
- UI remains on the Galaxy Map / Bridge context and does not dock.
- Bottom-left status text may show: “Docking requested.”

---

## Suspected Area (Optional)
- `scripts/MapPanel.gd` (Galaxy Map SystemTree selection + dock action)
- `scripts/MainGame.gd` (navigation / view routing for Port vs Bridge)

---

## Scope Constraints
- Changes are limited strictly to fixing the described bug.
- No refactors, cleanup, stylistic changes, or redesigns.
- No new features may be introduced.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `scripts/MapPanel.gd`
- `scripts/MainGame.gd`

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/MainGame.tscn`

---

## New Files Allowed?
- [ ] Yes (must list exact paths below)
- [x] No

---

## Acceptance Criteria (Must Be Testable)
All items must pass for the fix to be considered complete.

- [ ] Selecting a dockable location row in the Galaxy Map and pressing Dock successfully docks the player at that location.
- [ ] Pressing Port while undocked does not leave the player in a “cannot dock” state; the player can dock normally from the Galaxy Map.
- [ ] No new log spam is introduced; “Select a location to dock.” only appears when the player explicitly attempts to dock without a valid selection.

---

## Regression Checks
List behaviors that must still work after the fix.

- Galaxy Map SystemTree selection still works for systems and locations (expansion/collapse, selection highlight).
- Existing dock flow still works at the starting system/location.
- Bridge/Port/Captain’s Quarters navigation rules still hold (Port requires being docked; Bridge shows map).

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the fix.

1. From the starting system, select the starting location row and press Dock; verify docking succeeds and Port view works.
2. Travel to a different system (e.g., Harvest-12). On arrival, press Port (or remain on Bridge).
3. In the Galaxy Map, select a specific location row (not the system header) and press Dock.
4. Verify docking succeeds (log shows docked message, GameState current_location_id updates, Port view accessible).
5. Repeat step 3 with a different location in the same system (if available) to ensure selection/metadata is stable.

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
- Root cause summary
- Fix summary
- Files changed (and why)
- Manual tests performed
- Regression checks performed
- Remaining risks or follow-ups
