# Feature Job

## Metadata
- Issue/Task ID: Issue-0010
- Short Title: Time advancement policy and Wait action
- Author (human): Douglass Kyd
- Date: Jan 2026

---

## Goal
Define and implement explicit rules for how in-game time advances, and add a player-accessible **Wait** action that intentionally advances time without movement.

Time advancement must be fully explicit, debuggable, and routed through `GameState.advance_time(reason)`.

---

## Non-Goals
This job must NOT:

- Implement contract deadline enforcement logic
- Implement crew happiness or morale systems (design hooks only)
- Add or polish HUD time indicators (ship/local time)
- Advance time implicitly (e.g. per frame or per second)
- Modify market pricing logic
- Modify travel mechanics beyond calling `advance_time`
- Add visual polish or animations

---

## Context
- `GameState` now owns a monotonic `time_tick` and exposes `advance_time(reason)`.
- The economy and markets already react deterministically to `time_tick`.
- Time must remain **free while thinking** and **costly while acting**.
- Future contracts will include time clauses; missed deadlines must be explainable.
- Players need an intentional way to advance time while docked (“Wait”).
- Waiting will later interact with **crew happiness/morale**, but that system does not exist yet.

---

## Time Advancement Rules (Authoritative)
- While docked at a location, time does **not** advance automatically.
- UI interactions (markets, contracts, map, planning) do **not** advance time.
- Intra-system travel between locations advances time **significantly** (sub-light travel).
- Inter-system travel advances time **moderately** (FTL travel).
- Time advances **only** via explicit game actions.
- All time advancement must occur through `GameState.advance_time(reason)`.

---

## Proposed Approach
- Centralize time advancement calls in gameplay actions (travel and waiting).
- Add a **Wait** action that advances time by a fixed, explicit number of ticks.
- Ensure all time advancement includes a human-readable reason string.
- Do not add UI polish; a minimal trigger (button or menu entry) is sufficient.
- Leave hooks/comments for future crew happiness integration.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `res://singletons/GameState.gd`
- One existing UI or input-handling script to trigger the Wait action (must be named explicitly in `results.md`)
- Travel-related script(s) if required to add explicit `advance_time` calls

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `res://data/**`
- `res://scenes/MainGame.tscn`
- Economy pricing logic
- Contract completion or validation logic
- Any files not listed in the whitelist

---

## New Files Allowed?
- [ ] Yes (must list exact paths below)
- [x] No

---

## Public API Changes
List any new or modified public methods, signals, or resources.

- (Optional) `GameState.wait(ticks: int, reason: String)`  
  OR  
- Use `GameState.advance_time(reason)` directly from Wait action

If no new APIs are added, document usage patterns only.

---

## Acceptance Criteria (Must Be Testable)
- [ ] Time does not advance while docked unless the player explicitly chooses to Wait.
- [ ] Executing a Wait action advances `time_tick` by a documented number of ticks.
- [ ] Intra-system travel advances time more than inter-system travel.
- [ ] All time advancement paths include a descriptive reason string.
- [ ] No implicit or background time advancement exists.
- [ ] Markets reflect time advancement deterministically after waiting or travel.

---

## Manual Test Plan
1. Dock at a location and confirm `time_tick` does not change while using UI.
2. Trigger the Wait action once; confirm `time_tick` increments.
3. Trigger the Wait action repeatedly; confirm predictable tick advancement.
4. Travel between two locations in the same system; confirm larger tick increase.
5. Travel between two systems; confirm smaller tick increase.
6. Verify market prices change only after time advances.

---

## Edge Cases / Failure Modes
- Waiting while not docked
- Attempting to Wait during travel
- Multiple Wait actions in rapid succession
- Time advancement without a reason string

---

## Risks / Notes
- Waiting is a future dependency for crew happiness/morale systems.
- HUD indicators for ship time vs local time are intentionally deferred.
- Tick values and ratios are subject to later tuning.

---

## Codex Output Requirements
Codex must write results to:

- `codex/runs/issue-0010/results.md`

If `results.md` does not exist, Codex is permitted to create it.

Results must include:
- Summary of changes and rationale
- Files changed with brief explanation per file
- Assumptions made
- Known limitations and explicit TODOs (crew happiness, HUD time indicators)
