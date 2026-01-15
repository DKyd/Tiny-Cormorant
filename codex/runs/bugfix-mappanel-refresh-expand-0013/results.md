# Results: BUG-MAPPANEL-REFRESH-EXPAND-0013

## Root Cause Summary
- MapPanel could refresh during a travel transition when `Galaxy.get_all_system_ids()` returns empty, which cleared the tree and left the map empty until reopened.
- MapPanel is the runtime owner of the Tree UI, so fixes must be applied to the script attached to `MapPanel.tscn`.

## Fix Summary
- Added a retry-on-empty guard in `_refresh_all()` to defer one frame when system entries are empty, preventing the tree from clearing during travel transitions.
- Added a public `request_refresh()` hook for Bridge to trigger a deferred refresh without touching Tree internals.

## Files Changed
- `scripts/MapPanel.gd`: added retry-on-empty guard and `request_refresh()`; refresh logic remains centralized in MapPanel.

## Manual Test Steps (to run)
1. Start undocked (`current_location_id == ""`), open Galaxy Map.
2. Travel to a different system (system-to-system travel) while the map is open.
3. Confirm the map updates immediately without reopening and the new system shows `[HERE]`.
4. Confirm the current system is expanded even if it has zero contracts.
5. Confirm systems with contracts (or active destinations) are expanded; unrelated systems are collapsed.
6. Use search filter + clear it; confirm expansion rules still apply.

## Regression Checks (to run)
- Selecting a system/location still updates route info and Set Course works.
- Search filtering still rebuilds the list correctly.
- Double-click activation still behaves like Set Course.

## Assumptions Made
- `visibility_changed` fires when MapPanel is shown/hidden in the Bridge view.

## Follow-ups
- None noted.

## Map UI Wiring Audit
- `scenes/MapPanel.tscn` attaches `res://scripts/MapPanel.gd` to the root MapPanel node.
- No other `MapPanel.gd` files found in the repo.
- Bridge instantiates the map in `scripts/Bridge.gd` via `_load_map_panel()` (loads `res://scenes/MapPanel.tscn`).

## Recommendations (report only)
- Keep MapPanel script path stable and document it in the bugfix job to avoid future ambiguity.
