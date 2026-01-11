# Results: issue-0007-system-travel-no-autodock

## Summary
- System travel no longer auto-docks; arrival leaves `current_location_id` empty to represent an explicit “in-system, not docked” state.
- When not docked, the Port action routes to the map view and logs a prompt to select a location. Port opens only after an explicit location selection triggers `GameState.location_changed`.
- The galaxy map now refreshes immediately on system arrival so the current system updates without re-entering Bridge.

## Files Changed
- `singletons/GameState.gd`: removed default auto-docking on system travel to preserve an explicit not-docked state on arrival.
- `scripts/MainGame.gd`: added a pending-port flow so Port opens only after a location is explicitly selected; when not docked, Port routes to the map view and logs a prompt.
- `scripts/MapPanel.gd`: refreshes the system list when `GameState.system_changed` fires so the map reflects the current system on arrival.

## New Public APIs
- None.

## Manual Test Steps
1. Start a game in a system with multiple locations/ports.
2. Use the galaxy map to select ONLY a destination system (no location) and travel there.
3. Verify the player is in the destination system but NOT docked (no market/contract board refresh triggered by arrival alone).
4. Click Port.
5. Verify the game prompts you to select a location/port and does NOT auto-dock to the first location.
6. Select a specific location/port.
7. Verify docking occurs and port-related panels behave normally (market/contract boards refresh on dock).
8. Verify existing active contracts do NOT complete on system arrival; they complete only when docking at the correct destination location.
9. After arriving in a new system, verify the galaxy map reflects the new current system immediately without needing to re-enter Bridge.

## Assumptions Made
- `MapPanel.tscn` is the intended in-main-view navigation UI for selecting a docking location when not docked.
- Selecting a location from the map triggers `GameState.set_current_location()`, emitting `location_changed`.

## Known Limitations / Follow-ups
- None noted.
