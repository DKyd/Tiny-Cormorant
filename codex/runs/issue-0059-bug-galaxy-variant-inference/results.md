Root cause summary
- Typed GDScript inference in `singletons/Galaxy.gd` relied on `:=` and `clamp()` results sourced from Variant-returning calls, which triggers Variant inference warnings when warnings-as-errors is enabled.

Fix summary
- Added explicit float typing and casts in `_build_base_influences()` to keep types concrete while preserving existing influence logic.

Files changed
- singletons/Galaxy.gd: typing-only fixes; no logic changes.

Manual tests performed
- Project parses/runs with warnings-as-errors.
- Port org presence still renders.
- Black market gating unchanged.

Regression checks performed
- Project parses/runs with warnings-as-errors.
- Port org presence still renders.
- Black market gating unchanged.

Remaining risks / follow-ups
- Future untyped helpers returning Variant may require similar treatment.
