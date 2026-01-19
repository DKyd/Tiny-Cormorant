# Results: issue-0049-feature-sell-manifest-cargo

## Summary
- Expanded `Economy.quote_sale_price` to return base vs final pricing plus an adjustments list for future duties/taxes, without changing current pricing behavior.
- Implemented selling from ship manifest via `GameState.sell_manifest_goods`, generating line-based Bill of Sale FreightDocs with auditable source lineage that subtracts prior dispositions (Option B).
- Added a programmatic Sell modal in `MarketPanel` mirroring purchase UX (qty picker, quote preview, inline errors), calling GameState only on confirm.
- Updated FreightDocs UI to display Bills of Sale using `cargo_lines` as authoritative, with safe legacy fallbacks.

## Files Changed

### `singletons/Economy.gd`
- Updated `quote_sale_price` return shape to include:
  - `base_unit_price`
  - `adjustments`
  - `final_unit_price`
- `total_price` remains authoritative and unchanged in value.

### `singletons/GameState.gd`
- Implemented Bill of Sale source allocation that subtracts already-consumed quantities by scanning existing Bills of Sale sources (Option B).
- Hardened consumed-quantity aggregation to skip empty commodity IDs.
- Added defensive validation ensuring `sources` is an Array before proceeding.
- Aligned Bill of Sale container provenance label to `"bill_of_sale"`.

### `scripts/MarketPanel.gd`
- Added a programmatic Sell modal (Window + SpinBox) with quote preview via `Economy.quote_sale_price`.
- Capped sell quantity to available cargo and avoided opening the dialog when no cargo is present.
- Cleared stale status messages on successful quote refresh.
- Removed a stray no-op line.
- Fixed a runtime crash by replacing invalid `theme_override_constants` usage with Godot 4–supported `add_theme_constant_override()` calls.

### `scripts/FreightDocsPanel.gd`
- Bill of Sale display now reads `commodity_id` and `sold_qty` from `cargo_lines[0]` when present.
- Falls back to legacy top-level fields for backward compatibility.
- Added element type checks for safety.
- Prefers `location_name` with `purchase_location_name` fallback for older docs.

## Assumptions Made
- Bill of Sale docs are single-line (one commodity per sale) in this MVP.
- Sell actions occur only on explicit confirm input, preventing log spam.
- `final_unit_price` is the correct forward-facing price field; `total_price` remains authoritative.

## Known Limitations / TODOs
- Duties/taxes are not implemented; `adjustments` is currently empty and `final_unit_price == base_unit_price`.
- No customs inspection or enforcement yet; Bills of Sale provide lineage hooks for future reconciliation.
- If MarketPanel later supports multiple market kinds in the same UI context, `_sell_market_kind` should explicitly mirror the active market kind.

Update
- Sell confirm now blocks over-quantity attempts using raw input parsing, reports a clear status message, and logs a single blocked attempt without calling GameState.

Update
- Sell modal no longer opens without a valid inventory selection, and the quantity SpinBox allows out-of-range typed input so confirm-time validation can block over-max attempts.

Update
- Ensured the sell quantity LineEdit reflects the clamped value on open and confirm-time parsing falls back to SpinBox value when raw input is empty/invalid.
