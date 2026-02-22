# issue-0103 results

## Root cause summary
- `build_level2_invariant_log_summary()` depended on `report["invariant_violations"]` for the summary line and returned `Level-2 invariants: none found.` when that array was empty.
- The summary did not include diagnostics from `report["level2_audit"]`, so it was impossible to tell whether Level 2 invariants were evaluated, missing, or schema-mismatched.

## Fix summary
- Added compact Level 2 diagnostics generation in `CustomsReportFormatter.gd`:
  - If `level2_audit` is present: includes invariant count, finding count, and a stable sorted sample of invariant `id[status/severity]`.
  - If `level2_audit` is missing/non-dictionary: emits `missing level2_audit` plus related present report keys containing `level2`/`invariant`.
- Updated all Level 2 invariant summary return paths (`unavailable`, `none found`, and `violation(s)`) to append the diagnostics payload.
- Preserved existing `violation(s) [%s]` formatting path when findings exist.

## Files changed (and why)
- `scripts/customs/CustomsReportFormatter.gd`
  - Added helper methods to gather related keys, build stable invariant samples, and format Level 2 audit diagnostics.
  - Updated `build_level2_invariant_log_summary()` to include diagnostics in single-line summary output for all cases.

## Manual tests performed
- Not run in Godot in this environment.

## Regression checks performed
- Code inspection confirms Level 1 formatting paths were not changed.
- Existing Level 2 `violation(s) [%s]` string path remains active and now includes appended diagnostics.
- Summary remains single-line and bounded by `level2_log_top_n` sample truncation.

## Remaining risks or follow-ups
- Runtime verification in Godot is still needed to confirm exact log readability under real inspection scenarios.
- If downstream log consumers parse exact previous text, appended diagnostics may require parser adjustments.
