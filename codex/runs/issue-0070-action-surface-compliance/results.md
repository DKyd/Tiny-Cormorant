# Results

## Summary of changes and rationale
- Added a declarative action-level surface compliance registry (`SURFACE_ACTION_REQUIREMENTS`) defining which FreightDoc types are required for specific player-action boundaries (ENTRY_CLEARANCE, SELL_CARGO) when cargo is present.
- Implemented `validate_action_surface_compliance()` to deterministically verify required doc-type presence without mutating documents or performing plausibility/reconciliation logic.
- Integrated action-level surface compliance into `run_customs_inspection()` so inspections can classify as INVALID when required paperwork is missing, and can report both schema-level and action-level failures when they co-occur.

## Files changed (with brief explanation per file)
- `res://singletons/GameState.gd`
  - Added `SURFACE_ACTION_REQUIREMENTS` registry.
  - Added `_has_positive_cargo()` and `validate_action_surface_compliance()`.
  - Wired `context.action` into `run_customs_inspection()` to compute and include `action_surface` findings and doc-summary counters.
  - Updated classification logic to avoid masking action-level missing-doc failures when schema surface failures are also present.

## Assumptions made
- Phase A / Level-1 action compliance requires the presence of at least one source document type (`purchase_order` OR `contract`) when cargo is present.
- Action identifiers are passed explicitly via `run_customs_inspection({ "action": ... })` and are not inferred from game state.
- Missing required action docs should classify as `invalid` at inspection time (Level-1 surface compliance outcome), with explainable reasons.

## Known limitations or TODOs
- Action compliance is only evaluated when `context.action` is provided; this job does not add new triggers that call inspections.
- Action compliance checks doc-type presence only; it does not validate per-commodity coverage, quantities, or cross-document consistency (intentionally deferred to Level 2+).
- Unsupported actions are reported in `action_surface` but do not currently influence inspection classification unless future design requires it.
