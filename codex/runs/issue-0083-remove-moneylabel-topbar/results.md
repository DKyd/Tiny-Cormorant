# issue-0083 Results

## Summary of Refactor
- Removed MainGame TopBar MoneyLabel wiring that was redundant/stale:
  - deleted cached node reference for `VBoxContainer/TopBar/MoneyLabel`
  - removed money text update path from `_refresh_top_bar()`
  - removed `GameState.ship_changed` connection and its handler (`_on_ship_changed`) that only existed to refresh that label
- Kept all other MainGame behavior and flow unchanged.

## Files Changed
- `scripts/MainGame.gd`
  - Removed MoneyLabel-specific UI/plumbing only.
- `codex/runs/ACTIVE_RUN.txt`
  - Set to `issue-0083-remove-moneylabel-topbar` per scaffolding requirement.
- `codex/runs/issue-0083-remove-moneylabel-topbar/job.md`
  - Added verbatim job definition.
- `codex/runs/issue-0083-remove-moneylabel-topbar/results.md`
  - Added this results report.

## Manual Test Results
- Not executed in this shell environment (Godot editor runtime unavailable here).
- Required manual verification remains:
  1. Launch MainGame and confirm no missing-node errors.
  2. Dock and open/close market + black market UIs; verify no TopBar regressions.
  3. Perform buy/sell and verify state/log behavior remains correct.

## Confirmation Behavior Is Unchanged
- No gameplay/state mutation logic was edited.
- No time-advance paths were edited.
- No logs were added/removed by this refactor.
- Cleanup is limited to obsolete TopBar money-display wiring in `MainGame.gd`.

## Follow-ups / Known Gaps
- `scenes/MainGame.tscn` was explicitly blacklisted, so this run does not remove the physical `MoneyLabel` node from the scene tree. This run removes its code dependency/wiring only.
