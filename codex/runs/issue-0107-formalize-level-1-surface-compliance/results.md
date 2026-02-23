# issue-0107 results

## Summary of changes and rationale
- Added a new deterministic Level 1 audit module (`CustomsLevel1Audit`) to formalize paperwork surface-compliance checks.
- Wired Level 1 payload attachment in existing inspection report paths in `Customs.gd` without changing trigger logic, pressure logic, or depth selection.
- Kept integration additive-only (`report["level1_audit"]`) and read-only (no cargo/credits/docs/time mutation).

## Files changed (with brief explanation per file)
- `scripts/customs/CustomsLevel1Audit.gd`
  - New pure/deterministic builder: `build_level1_audit(ctx)`.
  - Produces structured payload with `classification`, `checks`, and `findings`.
  - Implements stable sorting for checks/findings and deterministic classification derivation.
  - Handles missing docs/cargo snapshots gracefully via not-evaluable checks and explicit findings where appropriate.
- `singletons/Customs.gd`
  - Added preload for `CustomsLevel1Audit`.
  - Added `_build_level1_context(system_id, location_id, action)` using deterministic snapshot fields: `system_id`, `location_id`, `action`, `tick`, `docs`, `cargo`.
  - Attached `report["level1_audit"] = CustomsLevel1Audit.build_level1_audit(ctx)` in the existing report-producing inspection paths (`sale`, `departure`, `entry`) when Level 1 depth is invoked (`max_depth >= 1`).

## Assumptions made
- Existing inspection report paths in `Customs.gd` are the intended integration points for this feature scope.
- Reusing `_normalize_level2_docs_for_audit(...)` for Level 1 docs snapshot shaping is acceptable for deterministic declaration-like doc availability.
- `max_depth >= 1` represents existing Level 1 invocation (no trigger/depth changes introduced).

## Known limitations or TODOs
- Manual Godot runtime verification remains required to confirm end-to-end payload surfacing and log readability.
- `CustomsReportFormatter.gd` was intentionally left unchanged; `level1_audit` is attached to report payload only.
- Save/load compatibility validation is pending manual test pass.
