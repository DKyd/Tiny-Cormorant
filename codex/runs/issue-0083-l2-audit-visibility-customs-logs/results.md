## Summary of changes and rationale
- Kept Level-2 log visibility compact and deterministic while preserving existing audit semantics and enforcement behavior.
- Confirmed existing Level-2 log path already includes deterministic ordering (severity > code > message), top-N truncation, and invariant code display.
- Added a dev-only verbosity toggle (default off) that appends a structured payload to the same single summary line when explicitly enabled.

## Files changed
- `singletons/GameState.gd`
  - Added `CUSTOMS_LEVEL2_VERBOSE_LOG` constant (default `false`).
  - Extended `_format_level2_log_snippet(...)` to optionally append `[DEV:<json>]` structured payload containing classification, finding count, and top findings.
- `codex/runs/ACTIVE_RUN.txt`
  - Set to `issue-0083-l2-audit-visibility-customs-logs`.
- `codex/runs/issue-0083-l2-audit-visibility-customs-logs/results.md`
  - Recorded this run outcome.

## Assumptions made
- Existing Level-2 finding generation, ordering helper, and top-N truncation behavior in `GameState.gd` are canonical and should remain unchanged.
- Dev verbosity should remain opt-in and default-disabled to avoid log noise.

## Known limitations or TODOs
- No runtime toggle plumbing was added beyond the constant; enabling verbose mode is currently a code-level switch.
- No additional tests were added in this patch; verification remains via manual trigger/log inspection.
