# Refactor Job

## Run identity
- Issue/Task ID: issue-0099
- Short Title: Prune/age-out scrutiny memory (Level-2 violation ticks) deterministically
- Run Folder Name: issue-0099-prune-scrutiny-memory
- Job Type: refactor
- Author (human): Douglass Kyd
- Date: 2026-02-22

## Goal (no behavior change)
Refactor the Level-2 “heightened scrutiny” memory so it is deterministically pruned/aged out and bounded, preventing unbounded growth of `customs_recent_level2_violation_tick_by_location` over long saves, while preserving identical gameplay/inspection behavior for equivalent state.

## Non-Goals
- No gameplay changes.
- No feature additions.
- No behavior changes beyond structure/readability.
- No new logs (unless required for error safety; prefer none).

## Invariants (must remain true)
- Time advances only via `GameState.advance_time(reason)`.
- Docked UI interactions do not advance time.
- GameState remains authoritative for transitions.
- UI does not mutate state directly.
- Economy determinism remains keyed by `(system_id, tick, market_kind)`.
- Inspection depth selection results remain identical given the same effective “recent violation history” within the existing window.

## Scope
### Whitelist (ONLY)
- `res://singletons/GameState.gd`
- `codex/runs/issue-0099-prune-scrutiny-memory/job.md`
- `codex/runs/issue-0099-prune-scrutiny-memory/results.md`
- `codex/runs/ACTIVE_RUN.txt`

### Blacklist
- `data/**`
- `scenes/MainGame.tscn`

## Approach (high level)
1) Add a small internal helper in `GameState.gd` to deterministically prune `customs_recent_level2_violation_tick_by_location`:
   - Remove entries where `(current_tick - last_tick) > CUSTOMS_LEVEL2_VIOLATION_WINDOW_TICKS`
   - Remove invalid keys / non-int ticks / unknown locations (consistent with existing restore validation)
   - (Optional if needed for bounding) enforce a deterministic cap by keeping the most-recent ticks, tie-breaking by location_id.
2) Call the prune helper only at safe choke points (NOT per frame):
   - Prefer: inside `resolve_customs_inspection_depth(...)` before computing bias, and inside save serialization helper (so saves stay trimmed).
3) Ensure behavior equivalence:
   - The bias decision is already window-bounded; pruning removes only entries that could never contribute to bias.
   - No changes to window constant, bias constant, or depth clamp behavior.

## Verification
### Manual test steps
1) Load a save where scrutiny is active (depth_bias > 0). Confirm Port header + preview show the same scrutiny as before.
2) Advance time beyond the window, then confirm scrutiny returns to Normal as before (no regression).
3) Save, reload, and confirm no crashes and scrutiny behaves identically.

### Regression checklist
- [ ] No UI action advances time
- [ ] No state mutation moved into UI
- [ ] Logs still reflect real player actions
- [ ] No protected paths touched

## Governance requirements
- Run Git Preflight Gate before any edits.
- Scaffold `codex/runs/issue-0099-prune-scrutiny-memory/` and write this job verbatim to `job.md`, create empty `results.md`, and set `codex/runs/ACTIVE_RUN.txt` accordingly.
- Implement refactor strictly within whitelist.
- Stop at Review Gate with `git diff --stat --staged` and `git diff --staged`.

Proceed.