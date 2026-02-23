## Summary
Implemented Level 2 chain-coherence invariants `L2INV-005` through `L2INV-009` in `scripts/customs/CustomsInvariants.gd` so source-chain tampering is detected through the Level 2 invariant path. The implementation reads normalized `docs_by_id` as `doc_id -> doc Dictionary`, performs deterministic issue ordering, and preserves documentary-only evaluation.

## Changes and Rationale
- Added `L2INV-005` (source presence): fails when bill-of-sale lines with positive sold quantity have missing/empty sources.
- Added `L2INV-006` (source totals): fails when source qty totals do not match sold qty, and now also flags tampering where `sources` exists but is not an Array (`sources_field_not_array`).
- Added `L2INV-007` (source doc validity): validates source entries, source doc existence, allowed source doc type, and source quantity data/commodity availability.
- Added `L2INV-008` (destroyed source refs): checks `is_destroyed` on the actual source doc in `docs_by_id`.
- Added `L2INV-009` (aggregate oversell): aggregates sold qty by `(source_doc_id, commodity_id)` and fails as `suspicious` when availability cannot be established (`missing_availability_for_source`) instead of silently passing; fails as `invalid` on oversell.
- Added deterministic sorting helper for issue arrays using composite order `(bill_doc_id, line_index, source_index, reason)`.

## Files Changed
- `scripts/customs/CustomsInvariants.gd`
  - Added invariant IDs `L2INV-005..009`.
  - Wired new invariant evaluators into `evaluate()`.
  - Added helpers for bill-line collection, source availability extraction for quantity math, and deterministic issue sorting.
  - Implemented new chain-coherence invariant evaluators.
- `codex/runs/ACTIVE_RUN.txt`
  - Set active run to `issue-0109-l2-invariants-chain-coherence`.
- `codex/runs/issue-0109-l2-invariants-chain-coherence/job.md`
  - Added job record for this run.
- `codex/runs/issue-0109-l2-invariants-chain-coherence/results.md`
  - Added this implementation summary.

## Assumptions Made
- Canonical destroyed flag for source documents is `is_destroyed` on each source doc Dictionary.
- Allowed source doc types remain `purchase_order` and `contract`.
- Source availability for quantity math is derived from existing documentary fields (`cargo_lines[].declared_qty|quantity` or top-level `commodity_id` + `quantity`) without introducing new schema.
- User-confirmed whitelist path correction applies to `scripts/customs/CustomsInvariants.gd` and `scripts/customs/CustomsLevel2Audit.gd` for this issue.

## Known Limitations / TODOs
- No automated test harness changes were added in this job scope; validation is currently via deterministic invariant behavior and manual audit flows.
- `L2INV-006` returns a shared summary/details envelope for both totals mismatch and `sources` field-type tamper; issue-level `reason` disambiguates exact cause.