# Results: issue-0014-refactor-mappanel-owner-signals

## Summary
- Refactored `MapPanel.gd` to be a pure view: it no longer performs travel/docking or frees itself.
- Added intent signals from MapPanel (`navigate_to_system_requested`, `navigate_to_location_requested`, `close_requested`).
- Bridge now owns navigation execution: it listens to MapPanel intent signals, performs `GameState.auto_travel()` / `GameState.set_current_location()`, and refreshes Bridge status + the embedded MapPanel.
- Reduced MapPanel log spam by routing diagnostics through `_dbg()` with `_MAP_DEBUG=false` by default.

## Files Changed
- `scripts/MapPanel.gd`
  - Added intent signals.
  - Replaced direct state mutation (`GameState.auto_travel`, `GameState.set_current_location`) with signal emits.
  - Replaced `queue_free()`-based closing with `close_requested` signal.
  - Debug logging moved behind `_dbg()`; `_MAP_DEBUG` set to false.
- `scripts/Bridge.gd`
  - Wires MapPanel signals on instantiation (`_wire_map_panel`).
  - Implements travel/docking handlers that execute GameState actions.
  - Refreshes Bridge UI and requests MapPanel refresh after actions.

## Behavior Notes
- Embedded Bridge MapPanel is now persistent (MapPanel no longer self-removes).
- Travel/docking actions are executed by Bridge, consistent with owner-managed lifecycle.

## Manual Test Steps (Executed)
1) Start game; verify Bridge shows Galaxy Map.
2) From Bridge MapPanel, select a different system and press Set Course.
   - Expect travel occurs, Bridge status updates, MapPanel remains visible and refreshes.
3) From Bridge MapPanel, select a location (same or different system) and press Set Course.
   - Expect inter-system travel if needed, then docking completes; Bridge status updates; MapPanel remains visible.
4) Verify no blank Galaxy Map after system travel while undocked (no need to click Bridge again).

## Verification Checklist
- [x] MapPanel does not call `GameState.auto_travel()` or `GameState.set_current_location()`.
- [x] MapPanel does not call `queue_free()` on user actions.
- [x] Bridge owns travel/docking behavior and refreshes MapPanel after actions.
- [x] No prohibited paths modified (`data/**`, `scenes/MainGame.tscn`).

## Follow-ups / Known Gaps
- MainGame standalone MapPanel (used when pressing Port while undocked) still needs signal wiring/handling so navigation intents perform actions in that context (and Close returns to Bridge).
  - If not yet implemented, Set Course will only update MapPanel info text in that standalone mode.
- Optional cleanup: in Bridge docking handler, UI refresh occurs immediately after `auto_travel` even if travel stops early (harmless). Could be reordered later for cleanliness.

## Log Hygiene
- MapPanel debug output is gated behind `_MAP_DEBUG=false`.
- No new per-frame log spam introduced.
