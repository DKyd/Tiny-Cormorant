# Results

Summary of changes and rationale
- Guarded `_refresh_inventory_list()` so it returns early when `inventory_list` is null, preventing crashes if the node is missing.
- Fixed cargo quantity lookup to read `GameState.cargo` using the original dictionary key variant to avoid type-mismatch misses.
- Verified there is no redundant `_refresh_inventory_list()` call at the end of `_refresh_market_list()`; no additional change required for that item.

Files changed (with brief explanation per file)
- `scripts/ui/BlackMarketPanel.gd`: added a null-guard and corrected cargo quantity lookup key.

Assumptions made
- `GameState.cargo` keys may not be Strings and should be used verbatim for lookups.

Known limitations or TODOs
- None.

Behavior unchanged confirmation
- Inventory display remains read-only and no time advancement or logging behavior changed.
