# Refactor Job: ISSUE-REFACTOR-PRINTCLEAN — Remove/Replace Noisy print() Output

## Goal
Eliminate cluttered console output by removing or replacing noisy `print()` statements, while preserving a small set of high-signal player-facing events via `Log.add_entry()`.

## Non-goals
- No gameplay behavior changes.
- No UI polish work.
- No new features.
- No changes to time advancement rules.
- No overhaul of the logging system beyond necessary call-site changes.

## Invariants (must remain true)
- Time advances only via `GameState.advance_time(reason)` from explicit actions.
- Docked UI interactions do not advance time.
- GameState remains authoritative for system/location/time transitions.
- UI does not mutate state directly; uses read-only system APIs.
- Economy determinism remains keyed by `(system_id, tick, market_kind)`.
- `Log.add_entry(text)` remains the canonical player-facing event stream.

## Scope

### Files allowed (whitelist)
- `scripts/**.gd`
- `singletons/**.gd`

### Prohibited
- `data/**`
- `scenes/MainGame.tscn`

## Policy: What output we keep
We will keep only these categories of messages (as `Log.add_entry`, not raw prints):
1) **System entry / travel confirmations**
   - e.g. “Traveled to <SystemName>. +N ticks.”
2) **Player-incurred fees** (customs / duties / tariffs) — if implemented anywhere
   - e.g. “Paid customs fee: <amount>.”
3) **Time tick information** (only when time advances)
   - Prefer logging via the reason string emitted by time advancement, not spam elsewhere.

All other `print()` statements should be removed or converted to debug-gated output (only if truly needed for developer debugging).

## Approach (high level)
1) Find all `print()` usages in allowed files.
2) Classify each print into one of:
   - Keep as player-facing log (`Log.add_entry`)
   - Remove entirely (noise)
   - Convert to debug-only gated output (rare; requires clear justification)
3) For messages kept as logs, normalize wording using the patterns in `docs/LOGGING.md`.
4) Ensure no duplicate messages are produced (avoid logging the same event in multiple layers).

## Verification

### Manual test steps
1) Launch the game in debug mode.
2) Perform actions that should still produce messages:
   - Travel to a new system (confirm a concise log entry appears).
   - Advance time via travel and via dockside wait (confirm tick-related entry appears).
   - If any fee system exists: perform an action that incurs fees and confirm a fee entry appears.
3) Confirm the console output is significantly quieter than before.
4) Confirm no errors/warnings were introduced.

### Print usage verification
- Search for `print(` across `scripts/` and `singletons/`:
  - Allowed occurrences: **0**, unless explicitly documented below as debug-gated prints.
- If any debug-gated prints remain, list them here with justification:
  - <file>:<line> — <why it must remain> — <gate mechanism>

### Regression checklist
- [ ] Travel/system entry still emits a clear `Log.add_entry` line.
- [ ] Time advancement still emits a reason/tick delta line.
- [ ] Fee-related events (if present) still emit a clear log line.
- [ ] No UI navigation emits logs.
- [ ] No spammy loop output remains.
- [ ] No behavior changes were introduced.

## Migration Notes
None.
