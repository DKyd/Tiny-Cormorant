Summary of changes and rationale
- Added Purchase Order freight doc creation on successful market purchases to document cargo acquisition (not sale), including containerization provenance and packed_tick, without changing credit/cargo purchase mechanics.

Files changed (with brief explanation per file)
- singletons/GameState.gd: added create_purchase_order() and invoked it from purchase_market_goods() after a successful purchase; Purchase Order includes transaction fields plus container_meta (unsealed, packed_tick, provenance).

Assumptions made
- scripts/docs/FreightDoc.gd does not exist in this repo; Purchase Orders are stored as standard freight_docs dictionaries consistent with existing document handling.

Known limitations or TODOs
- No standalone PurchaseOrderDoc script/resource was added; the Purchase Order schema is implicit in the freight_docs dictionary.
- Purchase Order lifecycle remains "active" only; no completion/cancellation semantics yet.
