# Results: Issue-0010-time-policy-and-wait-action

## Summary
- Added explicit tick advancement for inter-system and in-system travel via GameState.advance_time with descriptive reasons.
- Added a minimal docked Wait action in Bridge (press W) that advances time by a fixed tick count and logs the action.

## Files Changed
- `singletons/GameState.gd`: advances time for inter-system travel and for in-system location changes (excluding initial spawn), using fixed tick constants and reason strings.
- `scripts/Bridge.gd`: adds a docked-only Wait hotkey (W) that advances time by `WAIT_TICKS` and logs the result.

## Tick Constants
- `INTER_SYSTEM_TRAVEL_TICKS = 2`: smaller cost for inter-system travel (placeholder tuning).
- `INTRA_SYSTEM_TRAVEL_TICKS = 5`: larger cost for in-system travel (placeholder tuning).
- `WAIT_TICKS = 3`: fixed dockside wait duration (placeholder tuning).

## Manual Test Steps
1. Dock at a location and confirm `time_tick` does not change while using UI.
2. Press W while docked; confirm `time_tick` increases by `WAIT_TICKS` and a log entry appears.
3. Press W while not docked; confirm log says "You must be docked to wait." and time does not advance.
4. Travel between two locations in the same system; confirm larger tick increase.
5. Travel between two systems; confirm smaller tick increase.
6. Verify market prices change only after time advances.

## Assumptions Made
- `scripts/Bridge.gd` receives `_unhandled_input` while the player is docked on the Bridge.
- System and location names are available for travel reason strings when present.

## Known Limitations / TODOs
- Crew happiness/morale integration for Wait is not implemented.
- HUD clocks and time indicators remain deferred.

## Notes
- Wait advances time by calling `GameState.advance_time()` repeatedly (`WAIT_TICKS` times), so `time_advanced` emits once per tick (and debug prints may be noisy).
- Initial docking does not advance time due to `_has_initialized_location` guard in `set_current_location()`.
