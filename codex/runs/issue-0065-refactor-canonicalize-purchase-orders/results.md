# Results

Summary of refactor
- `record_market_purchase(...)` now emits `purchase_order` FreightDocs via `create_purchase_order(...)` and links the new doc id to the cargo line.
- Black market UI reads commodity identity from `commodity_id` with fallback to legacy `id` to avoid schema drift issues.

Files changed
- `singletons/GameState.gd`
- `scripts/ui/BlackMarketPanel.gd`

Manual test results
- Not run (not requested).

Behavior unchanged confirmation
- Purchase flow still deducts credits, adds cargo, logs the purchase, and links the purchase doc id on the cargo line; only the emitted doc type for purchases is normalized to `purchase_order`.

Follow-ups / known gaps
- Manual verification of the black market purchase flow and doc type is still pending.
