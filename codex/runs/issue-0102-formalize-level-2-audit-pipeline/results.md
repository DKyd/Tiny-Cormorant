Summary of changes and rationale
- Added a dedicated deterministic Level 2 audit builder (`CustomsLevel2Audit`) that formalizes payload generation from invariant evaluation.
- Integrated the new builder at the existing Level 2 invocation seam (`Customs.run_level_2_audit`), preserving existing triggers and Level 1 behavior.
- Kept the pipeline read-only: it only builds/returns report data (`classification`, `invariants`, `findings`) and does not mutate game state directly.

Files changed
- `scripts/customs/CustomsLevel2Audit.gd`
  - New file.
  - Added `build_level2_audit(ctx: Dictionary) -> Dictionary`.
  - Calls `CustomsInvariants.evaluate(ctx)`.
  - Normalizes invariant ids with schema priority: `invariant_id` -> `id` -> `code`.
  - Produces deterministic classification:
    - any failed invariant with `severity == "invalid"` => `invalid`
    - else any failed invariant => `suspicious`
    - else => `clean`
  - Produces stable ordering by sorting normalized invariants/findings by invariant id (with index tie-breaker).
  - Findings include: `invariant_id`, `severity`, `status`, `message`, and `details` when present.
  - Includes `code` alias for compatibility with existing log formatting consumers.
  - Safe details handling only duplicates when `details` is a Dictionary and non-empty.

- `singletons/Customs.gd`
  - Added preload for `CustomsLevel2Audit`.
  - Updated `run_level_2_audit()` to build/read a normalized snapshot and return `CustomsLevel2Audit.build_level2_audit(normalized_context)`.
  - Reused existing Level 2 seam (invoked by `GameState.run_customs_inspection` when `max_depth >= 2`), without adding triggers.
  - Included cargo snapshot in context when missing so quantity invariants can evaluate deterministically.

- `codex/runs/ACTIVE_RUN.txt`
  - Updated to `issue-0102-formalize-level-2-audit-pipeline`.

Assumptions made
- Existing consumers can accept additional/normalized fields in `level2_audit.findings`.
- Keeping `code` in findings is acceptable for backward compatibility while introducing `invariant_id` as the canonical key.
- Existing Level 2 invocation in `GameState.run_customs_inspection` is the canonical seam and should remain unchanged.

Manual verification notes
- Static verification performed:
  - Confirmed integration remains on existing Level 2 path (`max_depth >= 2` in `GameState.run_customs_inspection` -> `Customs.run_level_2_audit`).
  - Confirmed no new triggers/mechanics were added.
  - Confirmed only report payload construction changed in `Customs` integration path.
- Runtime scenario execution in Godot was not run in this CLI session. Recommended manual checks:
  1. Trigger an inspection that reaches Level 2 and verify `report["level2_audit"]` has `classification`, `invariants`, `findings`.
  2. Create deterministic cargo-vs-declaration mismatch, rerun same context, verify identical classification/findings ordering.
  3. Verify cargo/credits/time/docs are unchanged by Level 2 evaluation itself.

Known limitations / TODOs
- `GameState.run_customs_inspection` still contains existing pressure/escalation behavior outside this new builder; this task intentionally did not alter those mechanics.
- Did not modify `CustomsReportFormatter.gd`; compatibility was handled by including `code` on findings.
- Full in-engine runtime validation should be completed to confirm behavior under live save/state scenarios.
