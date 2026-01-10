# Results: issue-0002-location-level-navigation

## Summary
- Added location-aware docking flow in the map panel, including validation and a guard against docking when travel can’t reach the destination system.
- Updated the Bridge header to display Current System + Current Location and refresh on location changes.

## Files Modified
- scripts/MapPanel.gd: Validate location selection, avoid docking when auto-travel can’t reach the target system, and keep intra-system docking working with existing log behavior.
- scenes/Bridge.tscn: Added a LocationLabel to the Bridge header row.
- scripts/Bridge.gd: Populate the new location label and refresh on `location_changed`.

## New Public Methods / Signals
- None.

## Manual Test Steps
1. Launch the game and enter normal gameplay.
2. Open the Bridge map and select a location within the current system.
3. Press Set Course and verify docking completes and the log shows “Docked at <LocationName>”.
4. Confirm the Bridge header shows Current System and Current Location.
5. Switch to Port and confirm its header still shows Current System and Current Location.
6. Select a location in a different system; verify inter-system travel still works and docking happens only after reaching the destination system.

## Assumptions Made
- `GameState.set_current_location(...)` remains the single source of truth for docking logs.
- Re-docking at the same location should re-log “Docked at …”.

## Known Limitations / Follow-ups
- If a location’s `system_id` is missing or incorrect in data, docking validation may block; verify data consistency if this appears.
