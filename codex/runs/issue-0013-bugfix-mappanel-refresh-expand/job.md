# Bugfix Job

## Metadata
- Issue/Task ID: BUG-MAPPANEL-REFRESH-EXPAND-0013
- Short Title: MapPanel refreshes on system travel and enforces expansion rules
- Author (human): Douglass
- Date: 2026-01-11

---

## Bug Description
When the player travels to another system while **not docked** (traveling to a system, not a location), the Galaxy Map UI does not refresh immediately. The map only reflects the new system after the player presses the Bridge button again (re-opening the panel).

Additionally, the Galaxy Map tree expansion state is incorrect: `node-00` remains expanded and the current system does not reliably expand. The map should always expand the current system and any systems that have open contracts.

---

## Expected Behavior
- The Galaxy Map updates immediately after inter-system travel even if the player is not docked, without requiring re-opening the panel.
- The Galaxy Map tree enforces consistent expansion rules:
  - The **current system** is always expanded.
  - Any system with **open contracts** is expanded.
  - Systems that do not meet those rules are collapsed.

---

## Repro Steps
1. Start in a system while **not docked** (`current_location_id == ""`).
2. Open the Galaxy Map.
3. Travel to a different system (system-to-system travel).
4. Observe that the Galaxy Map does not update until the panel is reopened.
5. Observe that `node-00` remains expanded and the current system is not expanded.

---

## Observed Output / Error Text
- No crash or explicit error text.
- Galaxy Map UI remains stale until reopened.
- Incorrect system expansion state.

---

## Suspected Area (Optional)
- `res://ui/MapPanel.gd`
- GameState signals: `system_changed`, `location_changed`

---

## Scope Constraints
- Changes are limited strictly to fixing the described bug.
- No refactors, cleanup, stylistic changes, or redesigns.
- No new features may be introduced.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `res://ui/MapPanel.gd`

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

## Acceptance Criteria (Must Be Testable)
All items must pass for the fix to be considered complete.

- [ ] Galaxy Map refreshes immediately after inter-system travel while not docked.
- [ ] Current system is always expanded in the Galaxy Map tree.
- [ ] Systems with open contracts are expanded.
- [ ] Systems without contracts and not current are collapsed.

---

## Regression Checks
List behaviors that must still work after the fix.

- Selecting a system or location still shows route info.
- Set Course still triggers travel correctly.
- Search filtering still works and rebuilds the list correctly.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the fix.

1. Launch the game.
2. Ensure the player is **not docked**.
3. Open the Galaxy Map.
4. Travel to another system.
5. Confirm the Galaxy Map updates immediately without reopening.
6. Confirm the current system row is expanded.
7. Confirm systems with open contracts are expanded.
8. Confirm unrelated systems are collapsed.
9. Use the search box and clear it; confirm expansion rules still apply.

---

## Codex Output Requirements
Codex must write results to:

- `codex/runs/bugfix-mappanel-refresh-expand-0013/results.md`

If `results.md` does not exist, Codex is permitted to create it.
No other new files may be created.

Results must include:
- Root cause summary (brief)
- Fix summary
- Files changed (and why)
- Manual test steps performed
- Regression checks performed
- Any remaining risks or follow-ups
