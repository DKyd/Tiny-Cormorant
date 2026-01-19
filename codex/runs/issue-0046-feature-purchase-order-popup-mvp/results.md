Summary of changes and rationale
- Added GameState.purchase_market_goods to validate and execute market purchases with a single SHIP log on success or failure, keeping UI read-only and state mutations centralized.

Files changed (with brief explanation per file)
- singletons/GameState.gd: implemented purchase_market_goods with validation, credits/cargo updates, and SHIP-category logging.

Assumptions made
- Market price is derived from Economy.get_price_list_for_system(current_system_id).

Known limitations or TODOs
- Purchase does not create bill-of-sale docs to avoid extra log entries; this can be revisited when log policy allows.
