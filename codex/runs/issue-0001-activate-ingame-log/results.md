# Results: issue-0001-activate-ingame-log

## Summary
- Standardized log API to `Log.add_entry(...)` and updated all in-repo call sites.
- Added a dedicated log panel scene and script, and instantiated it in the main gameplay UI for persistent visibility.

## Files Changed
- scenes/MainGame.tscn: Instanced the log panel under the main VBoxContainer so it is visible during gameplay.
- scenes/ui/LogPanel.tscn: New log panel scene (basic Label + ItemList) anchored by container layout.
- scripts/ui/LogPanel.gd: New log panel controller; listens to `Log.message_added` and refreshes list.
- singletons/Log.gd: Introduced `add_entry(text)` as the stable public API for log messages.
- singletons/GameState.gd: Updated log calls to use `Log.add_entry`.
- singletons/Customs.gd: Updated log calls to use `Log.add_entry`.
- singletons/Contracts.gd: Updated log calls to use `Log.add_entry`.
- scripts/FreightDocsPanel.gd: Updated log calls to use `Log.add_entry`.
- scripts/JobBoardPanel.gd: Updated log calls to use `Log.add_entry`.
- scripts/LocationsPanel.gd: Updated log calls to use `Log.add_entry`.
- scripts/MapPanel.gd: Updated log calls to use `Log.add_entry`.
- scripts/MarketPanel.gd: Updated log calls to use `Log.add_entry`.
- scripts/Port.gd: Updated log calls to use `Log.add_entry`.

## New Public APIs
- `Log.add_entry(text: String) -> void` in `singletons/Log.gd`.

## Manual Test Steps
1. Launch the game.
2. Start or load into normal gameplay.
3. Perform an action such as travel or a market transaction.
4. Verify a new log entry appears in the log UI at the bottom of the screen.
5. Change scenes and verify the log still functions and continues to accept new entries.

## Assumptions Made
- `Log` is already configured as an autoload singleton (per project settings).
- The log panel scene should be the shared UI instance for all gameplay views.

## Known Limitations / Follow-ups
- No persistence of log history across sessions.
- No filtering, categories, or advanced controls (per non-goals).
- External code (outside this repo) that called `Log.add(...)` would need to switch to `Log.add_entry(...)`.
