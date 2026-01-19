Root cause summary
- Purchase order log entries were added without explicit categories, and cargo line formatting remained consistent with existing raw-id output.

Fix summary
- Added explicit "OTHER" category to purchase order log entries to avoid unintended contract-style categorization and kept cargo lines unchanged to match existing contract output.

Files changed (and why)
- scripts/FreightDocsPanel.gd: applied "OTHER" category to purchase_order Log.add_entry calls only.

Manual tests performed
- Not run (not requested).

Regression checks performed
- Contract log formatting unchanged; purchase order list labeling unchanged.

Remaining risks or follow-ups
- None.
