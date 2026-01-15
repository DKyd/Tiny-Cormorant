# Refactor Job: issue-0016-refactor-debug-cleanup — Remove MapPanel-era debug scaffolding

## Goal
Remove temporary debugging scaffolding and noisy diagnostics added during the Galaxy Map / MapPanel troubleshooting so logs are clean and code is easier to read, without changing gameplay behavior.

## Non-goals
- No gameplay or balance changes.
- No UI layout or styling changes (beyond removing debug-only formatting).
- No changes to contract generation logic, travel logic, or save/load behavior.
- No new features (including 2D map work).

## Invariants (must remain true)
- Time advances only via `GameState.advance_time(reason)` from explicit actions.
- Docked UI interactions do not advance time.
- GameState remains authoritative for system/location/time transitions.
- UI does not mutate state directly; uses read-only system APIs (signals/intent are OK).
- Economy determinism remains keyed by `(system_id, tick, market_kind)`.
- Player-facing logs for real actions and failures remain (e.g., travel, docking, accepting contracts, contract repair failures). Only remove debug spam / temporary diagnostics.

## Scope
### Files allowed (whitelist)
- `scripts/MapPanel.gd`
- `scripts/Bridge.gd`
- `singletons/Log.gd` (only if needed to remove debug helpers / formatting; avoid otherwise)
- `codex/runs/issue-0016-refactor-debug-cleanup/results.md`  # REQUIRED: Codex must write this at the end

### Prohibited
- `data/**`
- `scenes/MainGame.tscn`
- Any other files not listed in the whitelist

## Approach (high level)
1) Identify debug-only code paths introduced during MapPanel troubleshooting:
   - debug toggles (`_MAP_DEBUG`)
   - `_dbg()` / `_assert_true()` scaffolding
   - temporary log dumps (TreeState, instance/path spam)
   - temporary `print()` statements
2) Remove or gate these debug-only behaviors:
   - Delete dead debug code if no longer needed
   - Ensure any remaining debug helpers are OFF by default and do not spam logs
3) Keep behavior identical:
   - No changes to state mutation, signals, navigation, contract logic, or UI actions
   - Only remove noise; keep real player-facing logs

## Verification

### Manual test steps
1) Launch game, go to Bridge. Verify the Galaxy Map list appears and remains stable.
2) Travel to another system from the Bridge map and confirm:
   - Travel still works
   - Map stays visible
   - No debug spam appears in Log during refresh
3) Dock at a location via MapPanel and confirm:
   - Docking still works
   - Relevant action logs still appear (course set / docking)
   - No debug spam appears from MapPanel refresh loops
4) If possible, accept a contract and confirm contract acceptance logs still appear (and no extra debug noise).

### Regression checklist
- [ ] No UI action advances time.
- [ ] Time-advancing actions still log reason strings.
- [ ] No new direct state mutation from UI.
- [ ] No access of protected paths.
- [ ] No debug/diagnostic log spam reintroduced.

## Completion (required)
At the end of the job, Codex must create or update:

- `codex/runs/issue-0016-refactor-debug-cleanup/results.md`

`results.md` must include:
- Summary (what changed and why)
- Files changed
- Manual test results (which steps were run and outcomes)
- Behavior notes / edge cases
- Follow-ups / known gaps (if any)
- Confirmation prohibited paths were not modified

No additional code changes should be made during this step beyond what is already required by the job.

## Migration Notes
None.

## Logging Checklist
- [ ] All explicit player actions that succeed or fail emit a clear log entry
- [ ] All time advancement paths log a reason and tick delta
- [ ] No UI-only interactions produce log entries
- [ ] No per-frame or loop-driven spam was introduced
- [ ] Log messages are human-readable (no raw structs or IDs unless necessary)
- [ ] `print()` usage is debug-only or removed in favor of `Log.add_entry()`
- [ ] Log volume feels appropriate for a capped, recent-history log
