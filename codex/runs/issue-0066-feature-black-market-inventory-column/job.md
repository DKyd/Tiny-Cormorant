# Feature Job

## Metadata (Required)
- Issue/Task ID: ui-feature-black-market-inventory-column
- Short Title: Add player inventory column to Black Market (Cantina Back Room)
- Run Folder Name: issue-0066-feature-black-market-inventory-column
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-24

---

## Goal
Expose the player’s current cargo inventory alongside black market offers in the Cantina Back Room, mirroring the two-column layout used by the legal Market. This improves situational awareness without adding new mechanics or interactions.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- UI interactions in the Cantina Back Room must not advance time.
- UI must not directly mutate game state; all state changes remain in `GameState`.
- Black market behavior, pricing, and purchase logic remain unchanged.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- No selling from inventory in the Black Market UI.
- No changes to black market economics, detection, or inspection logic.
- No new gameplay mechanics related to smuggling or cargo handling.

---

## Context
The legal Market panel presents a two-column layout with offers on the left and the player’s inventory on the right, helping players reason about buying and selling decisions.  
The Black Market panel currently displays only a single-column list of offers, with credits and cargo weight shown below, making it harder for players to understand their current holdings while browsing illicit goods.  
An inventory display already exists conceptually (via `GameState.cargo`) but is not surfaced in the Black Market UI.

---

## Proposed Approach
- Update the Black Market panel scene layout to introduce an `HBoxContainer` that mirrors the Market panel structure.
- Add a read-only inventory column on the right side showing the player’s current cargo and quantities.
- Populate the inventory list from `GameState.cargo`, resolving commodity names via `CommodityDB`.
- Refresh the inventory display whenever the panel refreshes or when `ship_changed` is emitted.
- Do not introduce any new interactions (selection, selling, drag-and-drop) in the inventory column.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `scenes/ui/BlackMarketPanel.tscn`
- `scripts/ui/BlackMarketPanel.gd`

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/MainGame.tscn`

---

## New Files Allowed?
- [ ] Yes (must list exact paths below)
- [x] No

---

## Public API Changes
List any new or modified public methods, signals, or resources.  
If none, write “None”.

- None

---

## Data Model & Persistence
Required if this job adds or modifies saved state **or introduces new required in-memory fields**.

- New or changed saved fields:
  - None
- Migration / backward-compat expectations:
  - None
- Save/load verification requirements:
  - None

---

## Determinism & Stability (If Applicable)
- Inventory display order should be deterministic (e.g., sorted by commodity name).
- No randomness or time-based variance may be introduced.
- Display must reflect the current authoritative state in `GameState.cargo`.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] The Black Market panel displays a two-column layout with offers on the left and player inventory on the right.
- [ ] The inventory column lists all cargo items with quantity > 0, using human-readable commodity names.
- [ ] The inventory list updates immediately after buying items on the black market.
- [ ] Opening the Black Market at a location without cargo shows an empty (but stable) inventory list.
- [ ] No time advancement or errors occur when opening or interacting with the Black Market panel.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Load a save or start a new game and dock at a location with a black market.
2. Open the Cantina ? Back Room (Black Market).
3. Verify that an inventory column appears to the right of the offers list.
4. Buy an item from the black market and confirm the inventory list updates to include the new cargo.
5. Close and reopen the panel to confirm the inventory display remains correct.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Player has no cargo: inventory column should render empty without errors.
- Commodity data missing or unknown: inventory line should fall back to displaying the commodity ID.
- Location loses black market access while panel is open: existing disabled-state behavior must still apply.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Scene layout changes must not break existing signal connections or UI paths.
- Inventory display logic should not assume future sell mechanics.
- If assumptions about `GameState.cargo` structure are incorrect, Codex must stop and report rather than inventing solutions.

---

## Governance & Review Gates (Mandatory)
- Codex must not make code changes until required preflight/review steps are complete.
- Codex must present diffs for review before declaring results final.
- If scope, whitelist, or non-goals are violated, Codex must stop and report the issue.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/<Run Folder Name>/`
2) Write this job verbatim to `codex/runs/<Run Folder Name>/job.md`
3) Create `codex/runs/<Run Folder Name>/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `<Run Folder Name>`

Codex must write final results only to:
- `codex/runs/<Run Folder Name>/results.md`

Results must include:
- Summary of changes and rationale
- Files changed (with brief explanation per file)
- Assumptions made
- Known limitations or TODOs

---

## Logging Checklist
- [ ] All explicit player actions that succeed or fail emit a clear log entry
- [ ] All time advancement paths log a reason and tick delta
- [ ] No UI-only interactions produce log entries
- [ ] No per-frame or loop-driven spam was introduced
- [ ] Log messages are human-readable
- [ ] `print()` usage is debug-only or removed in favor of `Log.add_entry()`
- [ ] Log volume feels appropriate for a capped, recent-history log
