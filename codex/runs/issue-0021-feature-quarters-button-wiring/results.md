# Results: issue-0021-feature-quarters-button-wiring

## Summary
- Wired the Captain’s Quarters button to toggle a panel overlay without replacing the active view.
- Ensured a single overlay instance and clean teardown via a tree-exited handler.

## Files Changed
- scripts/MainGame.gd: toggles the Captain’s Quarters panel overlay and handles cleanup on close.

## Assumptions Made
- Using `main_panel` as the overlay host is safe and does not interfere with the active view container.
- The Captain’s Quarters panel handles its own internal Close button behavior.

## Known Limitations / TODOs
- None.
