# Results

Summary of fixes
- Hide the Purchase Order dialog on MarketPanel initialization to prevent it from showing on Port entry.

Files changed
- `scripts/MarketPanel.gd`

Manual test steps run (and outcomes)
- Not run (manual verification required).

Behavior confirmation
- Dialog is hidden on entry and only opened by explicit Create Purchase Order action.

Assumptions made
- MarketPanel `_ready()` runs on Port entry and is the earliest safe spot to hide the dialog.

Known limitations/TODOs
- None.
