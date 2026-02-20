## Summary
Implemented Level-2 Customs log visibility enhancements in a presentation-only path, without changing audit semantics or finding generation.

- Added deterministic Level-2 finding display ordering for logs: severity (`invalid` before `suspicious`), then invariant code ascending, then message.
- Added bounded top-N formatting (`N=3`) with deterministic `+X more` truncation suffix.
- Included invariant codes and short reasons in the Level-2 log snippet.
- Removed any DEV verbose append path from `_format_level2_log_snippet()` to keep this job strictly player-facing log formatting.
- Explicitly avoided runtime toggles, new keybindings, input handling changes, and full payload dumps.

## Files Changed
- `singletons/GameState.gd`
  - Added private/internal formatting helpers for deterministic Level-2 display sorting and truncation.
  - Updated `_format_level2_log_snippet()` to emit classification plus top-N invariant code/reason entries.
  - Removed the internal `_customs_log_verbose` variable and associated DEV log append block.
- `codex/runs/ACTIVE_RUN.txt`
  - Updated active run pointer to `issue-0083-l2-audit-visibility-customs-logs`.
  - Normalized file encoding/ending to UTF-8 without BOM and trailing newline.

## New Public APIs
None.

## Manual Test Steps
1. Load/start a save where Customs pressure can reach High and trigger a Customs inspection (sell cargo, depart, or entry) until Level-2 runs.
2. Create a known INVALID Level-2 scenario (for example, destroyed bill of sale or missing source document) and trigger inspection again.
3. Verify the Customs log includes `Level-2: <CLASSIFICATION>` plus ordered invariant entries with codes (for example `L2-06: ...`).
4. Verify ordering is deterministic: INVALID findings before SUSPICIOUS; within same severity, code ascending; tie-break by message.
5. Create >3 findings and verify log includes exactly top 3 and deterministic `+X more` suffix.
6. Confirm no new input toggles/keybindings were introduced and no full structured payload is dumped to logs.

## Assumptions Made
- Existing Level-2 finding entries continue to include stable `code`, `severity`, and `message` fields.
- Existing `run_level2_customs_audit()` semantics and output structure remain unchanged.

## Known Limitations / Follow-ups
- Manual in-engine validation is still required to verify real gameplay scenarios and log readability end-to-end.