# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0057
- Short Title: UI black market gating based on organization influence
- Run Folder Name: issue-0057-ui-black-market-gating
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-21

---

## Goal
Ensure that black market–related UI access reflects location organization influence by disabling or hiding Cantina back-room and Black Market access when a black market is not available at the current location.

This makes organization influence player-visible without altering market generation or legality logic.

---

## Invariants (Must Hold After This Job)
- Black market UI access is derived solely from `GameState.location_has_black_market(location_id)`.
- Black market access fails closed: when a location lacks sufficient cartel influence, entry is blocked where possible, and any opened black market UI shows a clear "No black market at this location." state with actions disabled.
- Core market logic, influence data, and persistence remain unchanged.

---

## Non-Goals
- No changes to influence generation or thresholds.
- No changes to market offer generation or filtering.
- No new legality or inspection logic.
- No new persistence or save/load changes.

---

## Context
Issue-0056 introduced deterministic organization influence at the location level and exposed
`GameState.location_has_black_market(location_id)` as the authoritative query.

Currently, Cantina and Black Market UI elements do not consult this query and may allow access regardless of influence state.

This job connects existing UI affordances to the new influence-derived availability signal.

---

## Proposed Approach
- Query `GameState.location_has_black_market()` when rendering or opening relevant UI panels.
- Disable or hide Cantina back-room access when no black market exists.
- Prevent entry into the Black Market panel when unavailable and present a clear, non-intrusive message.
- Keep all UI logic passive and query-driven; no influence mutation or inference.

---

## Files: Allowed to Modify (Whitelist)
- `scripts/Port.gd`
- `scripts/ui/CantinaPanel.gd`
- `scripts/ui/BlackMarketPanel.gd`

---

## Files: Forbidden to Modify (Blacklist)
- `data/**`
- `scenes/MainGame.tscn`
- `.godot/**`
- `singletons/Galaxy.gd`
- `singletons/GameState.gd`
- All market generation and economy logic

---

## New Files Allowed?
- [ ] Yes
- [x] No

---

## Public API Changes
None.

---

## Data Model & Persistence
None.

---

## Determinism & Stability (If Applicable)
- UI behavior must be deterministic for a given location and influence state.
- No randomness or time-based variance introduced.

---

## Acceptance Criteria (Must Be Testable)
- [ ] At a location where `location_has_black_market()` is false, Cantina back-room access is hidden or disabled.
- [ ] Attempting to open the Black Market UI at such a location is blocked.
- [ ] At a location where `location_has_black_market()` is true, existing behavior is unchanged.
- [ ] No crashes or errors occur when loading older saves.

---

## Manual Test Plan
1. Load a save or start a new game and dock at a location with no black market.
2. Open the Cantina and verify back-room access is unavailable.
3. Attempt to open the Black Market UI and verify access is blocked with a clear message.
4. Dock at a location with sufficient cartel influence and verify normal access.
5. Reload the game and repeat steps 1–4.

---

## Edge Cases / Failure Modes
- Missing or empty location ID fails closed (no black market access).
- UI panels opened via hotkeys or legacy paths still respect gating.
- Influence data missing on load does not enable black market access.

---

## Risks / Notes
- UI gating must not leak business logic into presentation layers.
- Any future change to black market rules must update `location_has_black_market()` only.
- If assumptions about UI entry points are incorrect, Codex must stop and report.

---

## Governance & Review Gates (Mandatory)
- Codex must not make code changes until preflight steps are complete.
- Codex must present full diffs for review before declaring results final.
- Any modification outside the whitelist requires an immediate stop and report.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0057-ui-black-market-gating/`
2) Write this job verbatim to `codex/runs/issue-0057-ui-black-market-gating/job.md`
3) Create `codex/runs/issue-0057-ui-black-market-gating/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0057-ui-black-market-gating`

Codex must write final results only to:
- `codex/runs/issue-0057-ui-black-market-gating/results.md`

---

## Logging Checklist
- [ ] No UI-only interactions emit log entries
- [ ] No per-frame or loop-driven logging introduced
- [ ] No changes to time advancement or player action logging
