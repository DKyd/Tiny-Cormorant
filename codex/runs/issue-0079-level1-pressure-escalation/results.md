# Results

## Summary of changes and rationale
- Added a runtime-only customs pressure escalation helper that increments government influence deltas on failed Level-1 inspections and logs increased scrutiny.
- Wired escalation into Level-1 inspection results when classification is `invalid`, without blocking or mutating cargo/credits/docs.

## Files changed (with brief explanation per file)
- `res://singletons/GameState.gd`: added `apply_customs_pressure_increase`, escalation constant, improved scrutiny log message, and invocation on invalid inspections.

## Assumptions made
- Runtime-only pressure escalation via location `delta_influences` is acceptable and resets on reload.
- Escalation clamps the delta entry weight only; effective influence may exceed 1.0 if base is already high.
- Escalation is applied only on failed Level-1 inspection outcomes (classification `invalid`), never on pass, and never from preview paths.

## Known limitations or TODOs
- Pressure escalation is not persisted across save/load cycles.
