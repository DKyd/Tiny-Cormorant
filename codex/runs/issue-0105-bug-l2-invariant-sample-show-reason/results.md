# issue-0105 results

## Root cause summary
- Level 2 diagnostic samples formatted each invariant as `id[status/severity]` and ignored `details.reason` even when issue-0104 populated deterministic not-evaluable reasons.
- This hid the immediate cause of `not_evaluable` outcomes in the log sample.

## Fix summary
- Updated `_build_level2_invariant_sample_from_audit(...)` in `CustomsReportFormatter.gd`:
  - For `status == "not_evaluable"`, append `:details.reason` inside sample brackets when a non-empty reason exists.
  - Keep existing format unchanged when reason is absent.
  - Keep pass/fail sample format unchanged.
- Added a short trim guard (`_trim_for_customs_log(..., 48)`) on the appended reason to preserve low-noise logging.

## Files changed (and why)
- `scripts/customs/CustomsReportFormatter.gd`
  - Extended sample-string formatting to surface not-evaluable reason without changing invariant evaluation behavior.

## Manual tests performed
- Not run in Godot in this environment.

## Regression checks performed
- Code inspection confirms only formatter output for sample entries changed.
- Pass/fail sample formatting path remains `id[status/severity]`.
- Formatter remains resilient when `details` is missing or non-dictionary.

## Remaining risks or follow-ups
- Runtime verification in Godot is still needed to confirm readability and determinism in end-to-end logs.
- If external tooling parses exact sample token format, it may need to tolerate optional `:reason` suffix for not-evaluable entries.
