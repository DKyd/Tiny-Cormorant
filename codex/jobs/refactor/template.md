# Refactor Job: <JOB_ID> — <TITLE>

## Goal
<1–2 sentences describing what structural improvement will be made and why.>

## Non-goals
- <Explicitly list what this will NOT do.>
- <No new gameplay features. No polish beyond required fixes.>

## Invariants (must remain true)
- Time advances only via `GameState.advance_time(reason)` from explicit actions.
- Docked UI interactions do not advance time.
- GameState remains authoritative for system/location/time transitions.
- UI does not mutate state directly; uses read-only system APIs.
- Economy determinism remains keyed by `(system_id, tick, market_kind)`.

<Add any job-specific invariants here.>

## Scope
### Files allowed (whitelist)
- <path/to/file1.gd>
- <path/to/file2.gd>
- <etc>

### Prohibited
- `data/**`
- `scenes/MainGame.tscn`

## Approach (high level)
1) <Step describing restructuring / consolidation / rename strategy.>
2) <Step describing how call sites will be updated.>
3) <Step describing how we’ll keep behavior identical and verifiable.>

## Verification

### Manual test steps
1) <Deterministic steps to confirm behavior unchanged.>
2) <Verify logs/signals/time ticks behave as before.>

### Rename verification (if applicable)
- Search for old identifier(s): `<OLD_NAME_1>`, `<OLD_NAME_2>` → **0 results**
- If a schema changed, confirm all producers/consumers updated.

### Regression checklist
- [ ] No UI action advances time.
- [ ] Time-advancing actions still log reason strings.
- [ ] No new direct state mutation from UI.
- [ ] No access of protected paths.

## Migration Notes
<Required if any schema/field names or saved/persisted data changes. Otherwise: “None.”>

## Logging Checklist

- [ ] All explicit player actions that succeed or fail emit a clear log entry
- [ ] All time advancement paths log a reason and tick delta
- [ ] No UI-only interactions produce log entries
- [ ] No per-frame or loop-driven spam was introduced
- [ ] Log messages are human-readable (no raw structs or IDs unless necessary)
- [ ] `print()` usage is debug-only or removed in favor of `Log.add_entry()`
- [ ] Log volume feels appropriate for a capped, recent-history log
