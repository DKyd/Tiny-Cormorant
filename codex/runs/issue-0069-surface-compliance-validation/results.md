# Results

## Summary of changes and rationale
- Added a declarative Level-1 Surface Compliance rules registry (`SURFACE_COMPLIANCE_RULES`) plus validators to check required fields, required non-empty arrays, and non-negative numeric values without mutating FreightDocs.
- Implemented structured, explainable findings via new helpers `validate_freight_doc_surface()` and `validate_freight_docs_for_action()`.
- Integrated surface compliance findings into `run_customs_inspection()` classification/reporting so missing/malformed paperwork can produce explainable Level-1 failures.
- Added debug-only validation hooks after FreightDoc creation to surface malformed documents during development without changing release behavior.

## Files changed (with brief explanation per file)
- `res://singletons/GameState.gd`: added Level-1 surface compliance rules/validators, integrated findings into customs inspection reporting/classification, and added debug-only post-creation validation calls for contract, purchase order, and bill of sale docs.

## Assumptions made
- Level-1 surface compliance failures (missing/invalid required fields/structures) should classify inspections as `INVALID` (not merely `SUSPICIOUS`).
- Logging a single warning in debug builds for invalid newly created docs is acceptable and non-spammy.

## Known limitations or TODOs
- Surface compliance validates per-document structure only; it does not perform cross-document reconciliation, plausibility checks, or enforcement actions (Level 2+).
- No “required document types per player action” policy is implemented yet (e.g., action-level requirements for depart/sell); only per-doc schema validity is checked.
