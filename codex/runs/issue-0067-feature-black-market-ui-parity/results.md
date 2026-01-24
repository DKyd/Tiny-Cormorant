# Results

Summary of changes and rationale
- Updated Black Market UI to mirror the Market panel layout with a top InfoRow and two-column ContentRow using Tree grids for offers and inventory.
- Replaced ItemLists with Trees, storing commodity id and price metadata on offers and keeping deterministic sorting for inventory.

Files changed
- `scenes/ui/BlackMarketPanel.tscn`: restructured nodes into InfoRow, header rows, and Tree-based grids.
- `scripts/ui/BlackMarketPanel.gd`: updated node paths and Tree population/configuration logic.

Manual test results
- Not run (manual verification required).

Assumptions made
- Black market offer entries provide `name`, `price`, and `commodity_id` or legacy `id`.

Known limitations/TODOs
- None.
