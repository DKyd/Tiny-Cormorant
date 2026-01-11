# Feature Job

## Metadata
- Issue/Task ID: issue-0008
- Short Title: Show contract availability on map (functional, no highlighting)
- Author (human): Douglass Kyd
- Date: 2026-01-10

---

## Goal
Expose contract availability in the galaxy/map UI so the player can see which systems and locations have available contracts without docking. This job is functional only: it should provide clear, testable indicators (e.g., counts/text/structure) without any styling, highlighting, icons, or aesthetic polish.

---

## Non-Goals
- Do NOT add visual highlighting (no colors, icons, animations, special fonts, emphasis styling).
- Do NOT add new UI art or redesign layout beyond what is required to show functional indicators.
- Do NOT change contract acceptance/completion behavior (issue-0005 / issue-0006).
- Do NOT change contract generation/refresh cadence.
- Do NOT add sorting/filtering beyond the minimum needed for correctness.
- Do NOT modify `data/**`.
- Do NOT modify `scenes/MainGame.tscn` unless explicitly required and whitelisted (assume forbidden).

---

## Context
- Contracts are owned per origin location and stored in `Contracts.contracts_by_location_id`.
- Boards refresh once per dock via `GameState.set_current_location()`.
- UI reads state and does not mutate it directly; UI triggers actions only via system APIs.
- Map UI (e.g., `MapPanel`) displays systems/locations but currently does not reflect contract availability.
- Player need: see where contracts exist without docking into each location.

---

## Proposed Approach
- Add a read-only query to the Contracts system to report contract counts by location (and optionally by system derived from those counts).
- Update the map UI to display contract presence at the location level using non-stylized indicators (e.g., “(3)” suffix or “Contracts: 3” text).
- Auto-expand systems in the map view if any child location has one or more contracts.
- Keep changes minimal and deterministic; avoid any UI styling decisions.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `singletons/Contracts.gd`
- `scripts/MapPanel.gd`

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

- Add read-only contract availability query (one of the following, choose minimal fit):
  - `Contracts.get_contract_count_for_location(location_id: String) -> int`
  - and/or `Contracts.get_contract_counts_by_location() -> Dictionary[String, int]`

(Exact method(s) implemented must be documented in results.md.)

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] The map UI displays a functional indicator of available contract count per location (text-only; no highlighting/icons).
- [ ] Systems containing at least one location with available contracts are auto-expanded in the map UI.
- [ ] Systems with no contract-bearing locations are not auto-expanded (existing behavior otherwise unchanged).
- [ ] Contract indicators update correctly after docking refreshes boards (i.e., after `GameState.set_current_location()` refresh behavior runs).
- [ ] No behavior changes to contract acceptance/completion; only visibility changes.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Start a game and dock at a location where contracts are generated/refreshed.
2. Open the map view.
3. Verify that locations with available contracts display a contract count indicator (text-only).
4. Verify that any system containing at least one such location is auto-expanded.
5. Travel/dock elsewhere to trigger a board refresh (per existing docking refresh rules).
6. Re-open or refresh the map view and verify the counts reflect the updated boards.
7. Accept a contract from a location (per existing UI), then confirm the map view no longer shows that contract on that origin location (count decreases accordingly) after the state refresh.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Location has zero contracts: indicator should be absent or show “0” (pick one consistent rule and document it in results.md).
- System has locations but none have contracts: system should not auto-expand.
- Missing/unknown location ids in the map should not crash; treat as zero contracts.
- Contract counts should not go negative; if state is inconsistent, log an error and display zero.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,
or architectural concerns.

- MapPanel may currently rebuild its tree without considering external per-location metadata; keep modifications localized to the rebuild/refresh path.
- Ensure the Contracts query is read-only and does not introduce UI-owned state.
- Auto-expansion should be deterministic and not override deliberate user collapse/expand beyond initial rebuild (document chosen behavior).

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
