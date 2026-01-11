# Feature Job

## Metadata
- Issue/Task ID: issue-0007
- Short Title: System travel without auto-docking (explicit port selection)
- Author (human): Douglass Kyd
- Date: 2026-01-10

---

## Goal
Traveling to a star system without selecting a specific destination location should place the player “in-system but not docked.” Docking must occur only when the player explicitly selects a port/location, via `GameState.set_current_location()`.

---

## Non-Goals
- Do NOT change contract acceptance or completion behavior (issue-0005 / issue-0006).
- Do NOT add new travel mechanics (fuel, encounters, combat, etc.).
- Do NOT refactor existing navigation UI or systems beyond what’s required to stop auto-docking.
- Do NOT modify `data/**`.
- Do NOT modify `scenes/MainGame.tscn` unless explicitly required and whitelisted (assume forbidden).

---

## Context
- `GameState` is authoritative for docking and location changes; `GameState.set_current_location()` is the only authoritative docking path.
- Contract boards refresh once per dock via `GameState.set_current_location()`.
- Contract completion is docking-based and location-specific (issue-0006).
- Current behavior: selecting only a system in the galaxy map, traveling there, then using “Port” results in docking at the first location in that system (implicit auto-dock).
- Missing behavior: a clear “arrived in system, not docked” state, and an explicit port/location selection step before docking.

---

## Proposed Approach
- Introduce/standardize an explicit “not docked” state when arriving at a system without a destination location (e.g., `current_location_id = ""` and `docked = false`).
- Ensure “system-only travel” updates the current system but does NOT call `GameState.set_current_location()`.
- Update the “Port” interaction so that when the player is not docked, it prompts the player to select a destination location/port instead of auto-selecting the first location.
- Keep all authoritative state transitions in system APIs; UI remains a caller/observer.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `singletons/GameState.gd`
- `scripts/` (only the specific script(s) that handle galaxy map destination selection and the “Port” button behavior; list exact paths during implementation in results.md)

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/MainGame.tscn`
- Any file not listed in the whitelist

---

## New Files Allowed?
- [ ] Yes (must list exact paths below)
- [x] No

If Yes, list exact new file paths:

-

---

## Public API Changes
List any new or modified public methods, signals, or resources.
If none, write “None”.

- None (prefer internal behavior changes only). If a new explicit method is required (e.g., `GameState.set_current_system()`), document it here in results.md and keep it minimal.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] Traveling to a system-only destination results in: current system updated, `docked == false`, and no current location set (or equivalent “not docked” sentinel).
- [ ] After system-only travel, clicking “Port” does NOT dock automatically to the first location in the system.
- [ ] After system-only travel, the player can explicitly choose a location/port and only then docking occurs via `GameState.set_current_location()`.
- [ ] Contract boards refresh only when docking occurs (not merely on system arrival).
- [ ] Contract completion behavior remains unchanged: contracts complete only when docking at their destination location (issue-0006).

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Start a game in a system with multiple locations/ports.
2. Use the galaxy map to select ONLY a destination system (no location) and travel there.
3. Verify the player is in the destination system but NOT docked (no market/contract board refresh triggered by arrival alone).
4. Click “Port”.
5. Verify the game prompts you to select a location/port (or otherwise requires an explicit choice) and does NOT auto-dock to the first location.
6. Select a specific location/port.
7. Verify docking occurs and port-related panels behave normally (market/contract boards refresh on dock).
8. Verify existing active contracts do NOT complete on system arrival; they complete only when docking at the correct destination location.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Destination system has zero locations: “Port” should fail gracefully (log or UI message) and remain not docked.
- Destination system has one location: still require explicit docking action; no auto-dock.
- Player clicks “Port” while already docked: behavior remains unchanged (opens port UI as before).
- Any missing/invalid destination selection should not crash; it should log and leave state unchanged.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,
or architectural concerns.

- “Port” flow currently assumes a location exists; removing auto-dock may reveal hidden UI dependencies.
- Must ensure system-arrival does not trigger dock-only side effects (board refresh, contract completion checks, etc.).
- Keep changes minimal and localized to travel selection + port entry points.

---

## Codex Output Requirements
Codex must write results to:

- `codex/runs/<job>/results.md`

If `results.md` does not exist, Codex is permitted to create it.
No other new files may be created.

Results must include:
- Summary of changes and rationale
- Files changed with brief explanation per file
- Assumptions made
- Known limitations or TODOs
