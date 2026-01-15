# Refactor Job: ISSUE-REFACTOR-LOGCAP  Cap Log History to Prevent Unbounded Growth

## Goal
Introduce a bounded log history to prevent unbounded memory growth while preserving all existing logging behavior and debuggability.

## Non-goals
- No changes to gameplay behavior.
- No changes to time advancement rules.
- No changes to log message content or wording (except where strictly required for structure).
- No persistence of logs to disk.
- No UI polish or new log viewer features.

## Invariants (must remain true)
- Logging remains centralized via `Log.add_entry(text)`.
- All existing log-producing actions (travel, wait, errors) still emit log entries.
- Log entries remain ordered chronologically (oldest  newest).
- No UI action advances time as a result of logging changes.
- GameState authority and behavior remain unchanged.

## Scope

### Files allowed (whitelist)
- `singletons/Log.gd`
- Any UI script that reads from Log history (read-only adjustments only, if needed)

### Prohibited
- `data/**`
- `scenes/MainGame.tscn`

## Approach (high level)
1) Introduce a hard maximum log entry count constant in `Log.gd`:
   - `MAX_LOG_ENTRIES = 300`
2) Modify `Log.add_entry()` so that when the cap is exceeded, the oldest entries are discarded.
3) Ensure trimming occurs atomically with insertion (no intermediate invalid states).
4) Preserve existing public API shape so callers do not need to change.
5) Add minimal internal comments explaining the cap and rationale.

## Verification

### Manual test steps
1) Launch the game in debug mode.
2) Generate many log lines:
   - Dock and press **W** to wait repeatedly (enough times to exceed 300 entries).
   - Travel between systems/locations to generate additional entries.
3) Confirm:
   - Log continues to append new entries.
   - Once > 300 entries would exist, the oldest entries are removed and total count stays at 300.
   - No errors or warnings appear in the output.
4) Confirm `time_tick` behavior is unchanged and correct.
5) Confirm any UI displaying logs still functions correctly.

### Regression checklist
- [ ] Log entries still appear for travel actions.
- [ ] Log entries still appear for wait actions.
- [ ] Error logs still appear when invalid actions are attempted.
- [ ] No new prints or logging side-effects were introduced.
- [ ] No changes to time advancement behavior.

## Migration Notes
None. Log history is ephemeral and not persisted.
