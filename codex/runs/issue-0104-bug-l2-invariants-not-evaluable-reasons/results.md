# issue-0104 results

## Root cause summary
- `not_evaluable` invariant results had only a terse summary and sometimes only a single reason token, which did not identify concrete missing inputs.
- This made Level 2 diagnostics unable to explain why invariants did not evaluate in contexts that looked like they should have enough data.

## Fix summary
- Added `_build_not_evaluable_details(reason, missing_inputs)` in `scripts/customs/CustomsInvariants.gd` to standardize deterministic diagnostic payloads.
- Updated all `STATUS_NOT_EVALUABLE` return paths to include:
  - `details.reason` (existing reason code retained)
  - `details.missing_inputs` (stable sorted list where applicable)
- Kept pass/fail evaluation logic unchanged.

## Files changed (and why)
- `scripts/customs/CustomsInvariants.gd`
  - Added helper for deterministic not-evaluable detail construction.
  - Enriched every not-evaluable invariant path (quantity, route policy-disabled, timestamp, container metadata) with structured diagnostic detail.

## Manual tests performed
- Not run in Godot in this environment.

## Regression checks performed
- Code inspection confirms only `STATUS_NOT_EVALUABLE` detail payloads were changed.
- No pass/fail branch predicates or severity assignments were modified.
- Output remains deterministic due to sorted `missing_inputs` and fixed reason strings.

## Remaining risks or follow-ups
- Runtime validation in Godot is still needed to confirm surfaced diagnostics in end-to-end inspection logs/UI.
- If downstream code strictly compares full `details` dictionaries, added keys may require expectation updates.
