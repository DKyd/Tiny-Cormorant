# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0056
- Short Title: Worldgen organization influence assignment + black market threshold
- Run Folder Name: issue-0056-worldgen-organization-influence-assignment-black-market-threshold
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-21

---

## Goal
Introduce deterministic, per-location organization influence data at world generation time and expose a stable query to determine black market availability based on cartel influence.

This enables future Organization-driven legality, markets, and conflict systems without schema drift or UI coupling.

---

## Invariants (Must Hold After This Job)
- Locations have organization influence data available immediately on new game start.
- Government influence exists at all non-OUTLAW locations.
- Organization influence assignment is deterministic for a given generated world.
- Black market availability is derived solely from influence data (not UI or hard-coded location flags).
- Older saves load without crashing and fail closed (no black market if influence data is missing).

---

## Non-Goals
- No UI changes or gating behavior.
- No legality filtering, inspections, or enforcement logic.
- No new persistence of Galaxy locations beyond existing save behavior.
- No organization roster, factions, or diplomacy systems.

---

## Context
Tiny Cormorant currently models legality and markets at the location level, but lacks a systemic concept of Organizations.

This job establishes the minimal data substrate required for Organizations by:
- Attaching influence data to generated locations.
- Providing influence aggregation helpers.
- Defining a single black market threshold rule.

This work is intentionally backend-only and does not alter presentation or player flow.

---

## Proposed Approach
- Add base and delta organization influence arrays to each generated location.
- Assign base influences deterministically during world generation using stable inputs.
- Treat OUTLAW locations as cartel-controlled by default.
- Aggregate influence via helper functions in GameState.
- Expose a single boolean query for black market availability based on cartel influence.
- Normalize missing influence arrays on load to preserve backward compatibility.

---

## Files: Allowed to Modify (Whitelist)
- `singletons/Galaxy.gd`
- `singletons/GameState.gd`

---

## Files: Forbidden to Modify (Blacklist)
- `data/**`
- `scenes/MainGame.tscn`
- `.godot/**`
- All UI scenes and panels

---

## New Files Allowed?
- [ ] Yes
- [x] No

---

## Public API Changes
- `GameState.get_location_effective_influences(location_id, min_weight := 0.01, max_orgs := 4) -> Array`
- `GameState.location_has_black_market(location_id) -> bool`

---

## Data Model & Persistence
- New in-memory location fields:
  - `base_influences: Array`
  - `delta_influences: Array`
- No new save payloads introduced.
- On load, missing influence arrays are initialized to empty lists.
- Older saves fail closed (no inferred black markets).

---

## Acceptance Criteria (Must Be Testable)
- [ ] Newly generated locations include base organization influences.
- [ ] Non-OUTLAW locations always include government influence.
- [ ] OUTLAW locations omit government influence.
- [ ] `location_has_black_market()` returns true iff effective cartel influence ≥ 0.10.
- [ ] Restarting with the same world produces identical influence assignments.
- [ ] Loading older saves does not crash and does not enable black markets.

---

## Manual Test Plan
1. Start a new game and dock at multiple locations.
2. Inspect location dictionaries (debug/inspector) to confirm base influences exist.
3. Verify at least one OUTLAW location has cartel influence only.
4. Confirm `location_has_black_market()` reflects influence values.
5. Reload an older save and confirm the game loads and markets function normally.

---

## Edge Cases / Failure Modes
- Locations missing system or economy metadata still produce deterministic influence.
- Influence arrays missing on load are safely initialized.
- Empty or unknown location IDs return no influence and no black market.

---

## Risks / Notes
- Organization IDs are currently hard-coded placeholders (“government”, “cartel”).
- Influence weights are additive and not normalized; future systems must account for this.
- UI gating and spatial changes are deferred to a follow-up issue (issue-0057).

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0056-worldgen-organization-influence-assignment-black-market-threshold/`
2) Write this job verbatim to `codex/runs/issue-0056-worldgen-organization-influence-assignment-black-market-threshold/job.md`
3) Create `codex/runs/issue-0056-worldgen-organization-influence-assignment-black-market-threshold/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0056-worldgen-organization-influence-assignment-black-market-threshold`

Codex must write final results only to:
- `codex/runs/issue-0056-worldgen-organization-influence-assignment-black-market-threshold/results.md`

---

## Logging Checklist
- [ ] No new per-frame or loop-driven logging introduced
- [ ] No UI-only interactions emit logs
- [ ] All logic is backend-only and silent
