# issue-0108 results

## Summary of changes and rationale
- Chose `CustomsInspectionPanel` as the minimal existing host because it is opened via an explicit player action (`Port -> Customs`) and does not require edits to `scenes/MainGame.tscn`.
- Added a dedicated `SurfaceAuditPanel` UI component to render Level 1 audit status (`PASS/WARN`) and findings list from payload only.
- Wired panel population through explicit action flow: `Port.gd` now backfills `report["level1_audit"]` only when missing, immediately after explicit customs inspection request, before opening the panel.
- Kept render path side-effect free: no `Log.add_entry()` in panel rendering functions.

## Files changed (with brief explanation per file)
- `codex/runs/issue-0108-surface-level1-audit-ui/job.md`
  - Updated whitelist to exact file paths after host selection.
- `scripts/ui/SurfaceAuditPanel.gd`
  - New panel script with `set_audit(audit_payload: Dictionary)`; safe fallback strings for missing/malformed payload.
- `scenes/ui/SurfaceAuditPanel.tscn`
  - New UI scene for Surface Audit readout (header, status label, findings text).
- `scenes/ui/CustomsInspectionPanel.tscn`
  - Embedded `SurfaceAuditPanel` instance into the existing customs inspection view.
- `scripts/ui/CustomsInspectionPanel.gd`
  - Bound `report["level1_audit"]` into the embedded panel in `set_report()` and reset path.
- `scripts/Port.gd`
  - Added explicit-action backfill helper for Level 1 payload (`_build_level1_audit_snapshot`) and populate-on-request if report lacks `level1_audit`.

## Assumptions made
- `Port -> Customs` is the intended explicit action for reading the latest inspection/audit output in this scope.
- Backfilling Level 1 payload in `Port.gd` is acceptable because it occurs on explicit player action and does not mutate gameplay state.
- Existing `GameState.run_customs_inspection()` schema can remain unchanged for this issue.

## Known limitations or TODOs
- UI currently surfaces the latest payload from explicit customs inspection request flow; no separate refresh button was added.
- Manual runtime verification in Godot is still required for final UX/readability validation.
- Existing debug `print()` calls in `scripts/Port.gd` predate this change and were not refactored in this scoped implementation.
