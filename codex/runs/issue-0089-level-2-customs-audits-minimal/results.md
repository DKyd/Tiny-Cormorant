## Summary of changes and rationale
- Added `Customs.run_level_2_audit(context: Dictionary) -> Dictionary` as a context-normalizing wrapper for Level-2 audits.
- The wrapper now normalizes core context fields (`system_id`, `location_id`, `action`, `docs`, `tick`) before delegating to `GameState.run_level2_customs_audit(...)`.
- Rationale: keep Level-2 evaluation logic in `GameState` while providing a stable, minimal integration wrapper in `Customs` for external callers.
- The wrapper uses `GameState.get_freightdoc_chain_snapshot()` when `docs` are missing, passes docs-by-id as a `Dictionary`, and prefers snapshot tick for deterministic as-of-snapshot behavior.
- The wrapper does not invent jurisdiction: it only defaults `location_id` from `GameState.current_location_id` when that value is non-empty.
- Updated active run tracking to `issue-0089-level-2-customs-audits-minimal` in `codex/runs/ACTIVE_RUN.txt`, with trailing newline.

## Files changed (with brief explanation per file)
- `res://singletons/Customs.gd`
  - Added `run_level_2_audit(...)` wrapper and implemented context defaulting precedence:
    - preserve provided `tick`
    - if `docs` missing, load snapshot docs + snapshot tick fallback
    - if `docs` provided and `tick` missing, fallback to `GameState.time_tick`
  - Adjusted `location_id` defaulting to only use current location when non-empty.
- `codex/runs/ACTIVE_RUN.txt`
  - Set active run id to `issue-0089-level-2-customs-audits-minimal` and ensured newline termination.

## Assumptions made
- `GameState.get_freightdoc_chain_snapshot()` exists and returns a dictionary with `docs` (docs-by-id dictionary) and `tick`.
- Leaving `Customs.run_level_2_audit(...)` as a wrapper is acceptable even if currently optional in the main path.
- Snapshot tick is the preferred deterministic default when snapshot docs are used.

## Known limitations / TODOs
- No additional refactor was performed to remove optional wrapper usage elsewhere; this remains intentionally minimal.
- No enforcement logic was added at Level-2; behavior remains non-blocking/non-mutating by design.
- No UI changes, save-format changes, or randomness changes were introduced.
- Scope governance for this approved patch was kept to the whitelist files only.