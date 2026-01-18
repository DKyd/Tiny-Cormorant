## Summary
- Reworked the MainGame layout to place the LogPanel in a right-side column that persists across view swaps.
- Kept LogPanel behavior and logging flow unchanged; only scene layout and node paths were updated.

## Files Changed
- scenes/MainGame.tscn: added a ContentRow HBoxContainer and moved MainPanel/LogPanel into it for a persistent right-side layout.
- scripts/MainGame.gd: updated node paths for MainPanel and MainViewContainer to match the new scene hierarchy.
- scenes/ui/LogPanel.tscn: set a fixed minimum width for the right-side log panel.

## New Public APIs
- None.

## Manual Test Steps
1. Launch the game and observe the log positioned on the right side of the screen.
2. Switch between Bridge, Port, and Captain's Quarters using the TopBar.
3. Trigger several log events (travel, inspections, UI actions) and confirm they appear correctly and persist across views.

## Assumptions Made
- The MainGame scene owns the persistent HUD layout and is the correct place to host the right-side LogPanel.
- A 320px minimum width is acceptable for the log panel across supported resolutions.

## Known Limitations / Follow-ups
- If future UI scaling reduces available width, the log panel will keep its minimum size and could constrain the main view.
