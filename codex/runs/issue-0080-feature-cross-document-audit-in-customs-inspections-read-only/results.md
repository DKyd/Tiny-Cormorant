# Results

## Summary
- Added a deterministic Level-2 document chain audit and log snippet support for Customs inspections.
- Integrated the Level-2 audit into `run_customs_inspection` with max-depth gating and INVALID pressure escalation.
- Customs inspections now pass max-depth from the inspection preview into the inspection context.

## Files Changed
- `res://singletons/GameState.gd`: added the Level-2 audit helper, integrated it into inspection reports/logs, and applied Level-2 INVALID pressure escalation.
- `res://singletons/Customs.gd`: passed inspection preview `max_depth` into inspection contexts.

## New Public APIs
- `GameState.run_level2_customs_audit(context: Dictionary = {}) -> Dictionary`

## Manual Test Steps
1. Load an existing save or start a new game, dock at a location with a market, buy legal goods to generate purchase orders.
2. Sell some of the goods legally to generate a bill of sale with sources; trigger a legal sale inspection. Confirm logs and that cargo/credits behave normally.
3. Force a Level-2-capable inspection context (per Customs.gd gating added in this job) and repeat a sale/entry/departure inspection; confirm `level2_audit` appears in the inspection report (use existing debug/log output) and the formatted Customs log includes a Level-2 summary line.
4. Create a deliberate paper trail contradiction (e.g., destroy a source purchase order that is referenced by an existing bill of sale; or craft an oversell scenario if achievable via gameplay/tools) and trigger a Level-2 inspection; confirm Level-2 becomes INVALID, pressure increases, and no action is blocked.

## Assumptions Made
- Inspection `max_depth` is supplied by the caller (Customs now passes `get_inspection_preview().max_depth`), so Level-2 runs only when contexts provide `max_depth >= 2`.
- Level-2 source availability uses `cargo_lines[].declared_qty` (with a fallback to `quantity` fields when present).
- Temporal checks only flag missing ticks for purchase orders; contracts without ticks do not trigger missing-tick warnings.

## Known Limitations / Follow-ups
- There is no new mapping from customs pressure to Level-2 depth; Level-2 runs only when `max_depth >= 2` is provided in the inspection context.
- Level-2 auditing is limited to document-chain coherence and does not add new UI or enforcement mechanics.
