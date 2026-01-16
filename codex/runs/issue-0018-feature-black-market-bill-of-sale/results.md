# Results: issue-0018-feature-black-market-bill-of-sale

## Summary
- Added bill-of-sale freight docs for market purchases and stored a per-purchase cargo line record linked to the doc.
- Updated FreightDocsPanel to display bill-of-sale entries without debug spam and to log readable details on selection.

## Files Changed
- singletons/GameState.gd: added cargo line tracking, bill-of-sale doc creation, market-kind normalization, and save/load persistence for new fields; legacy docs get doc_type="contract" on load.
- scripts/MarketPanel.gd: records each successful purchase via GameState.record_market_purchase using standardized market kind constants.
- scripts/FreightDocsPanel.gd: removed debug prints, added doc_type-aware labels and selection logging, and updated empty-state hint.

## New Public APIs
- GameState.record_market_purchase(commodity_id, quantity, unit_price, total_cost, market_kind)
- GameState.MARKET_KIND_LEGAL
- GameState.MARKET_KIND_BLACK_MARKET

## Manual Test Steps
1. Load an existing save with a docked ship.
2. Buy a legal commodity from a normal market.
3. Open FreightDocsPanel from the Port and inspect the Bill of Sale.
4. Open FreightDocsPanel from the Bridge and inspect the same doc.
5. Save the game, reload, and re-verify all cargo and docs.

## Assumptions Made
- Market purchases currently flow through MarketPanel (legal market); black market flow is not present yet and should call GameState.record_market_purchase with MARKET_KIND_BLACK_MARKET when introduced.
- A docked location is available when purchases occur, so purchase location metadata is valid.

## Known Limitations / Follow-ups
- Bill-of-sale docs contain denormalized declared cargo fields; actual cargo remains authoritative in GameState.cargo.
- Black market purchase UI/flow is not yet present; when added, it must pass MARKET_KIND_BLACK_MARKET into record_market_purchase.
 - Bridge already exposes FreightDocsPanel via Bridge.gd; no additional wiring was required here.
