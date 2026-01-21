Summary
- Gated cantina/back-room availability and black market entry using the influence-derived `GameState.location_has_black_market` check so UI access now fails closed when cartel influence is insufficient.
- Added a defensive state in the black market panel that displays a clear no-market message and disables interactive controls when opened at an unavailable location.

Files Changed
- scripts/Port.gd: disabled cantina/back-room access unless a black market is available and guarded black market entry to return early when unavailable.
- scripts/ui/CantinaPanel.gd: hid/disabled the Back Room button when the current location lacks a black market.
- scripts/ui/BlackMarketPanel.gd: showed a no-market message and disabled buy/interaction controls when the location lacks a black market.

Assumptions Made
- `GameState.location_has_black_market(GameState.current_location_id)` is the single source of truth for black market availability.
- The Back Room button is the only Cantina path to black market access.

Known Limitations / TODOs
- The Port scene can still open the Cantina even if only a back room exists but the black market is unavailable; this matches the requirement to fail closed on black market access rather than removing cantina access entirely.
- No additional UI messaging is added in Port for blocked black market access (panel-level message provides feedback).

Manual Test Steps
1. Dock at a location where `location_has_black_market()` is false.
2. Open the Cantina and verify the Back Room button is hidden or disabled.
3. Attempt to open the Black Market (via back room or any available UI path) and verify the panel shows “No black market at this location.” and disables buying controls.
4. Dock at a location where `location_has_black_market()` is true and verify the existing Cantina and Black Market behaviors are unchanged.
