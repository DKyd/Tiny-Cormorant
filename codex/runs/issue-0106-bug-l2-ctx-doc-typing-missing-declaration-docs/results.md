# issue-0106 results

## Root cause summary
- `run_level_2_audit()` needed explicit docs/tick control flow and docs normalization assignment outside the fetch branch.
- Audit docs derivation for declaration-like comparison was too narrow, so FDOC-based scenarios could remain `missing_declaration_docs`.

## Fix summary
- Reworked `run_level_2_audit()` control flow to:
  - compute `docs_variant`
  - fetch chain snapshot docs when null and set tick from snapshot if missing
  - otherwise set tick from `GameState.time_tick` if missing
  - then normalize and assign `normalized_context["docs"]` outside the branch
- Added `_normalize_level2_docs_for_audit(docs_variant)` and expanded declaration-like derivation to trigger when:
  - `doc_type == "contract"`, or
  - doc id starts with `FDOC-`, or
  - `doc_type` in `{freightdoc, freight_doc, freight_docs}`
- Derived docs remain audit-only clones with:
  - `doc_id = <orig>__declaration_like`
  - `doc_type = purchase_order`
  - `derived_from_doc_id = <orig>`

## Files changed (and why)
- `singletons/Customs.gd`
  - Added deterministic audit-doc normalization and broadened declaration-like derivation.
  - Fixed `run_level_2_audit()` control-flow structure per requested shape.

## Manual tests performed
- Not run in Godot in this environment.

## Regression checks performed
- Verified no changes to invariant logic files.
- Verified changes are formatter/context-only and read-only relative to cargo/docs/time state.

## Remaining risks or follow-ups
- Runtime verification in Godot is still required to confirm L2INV-001 no longer reports `missing_declaration_docs` for FDOC mismatch repro.
