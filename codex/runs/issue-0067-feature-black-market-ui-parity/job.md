# Feature Job

## Metadata (Required)
- Issue/Task ID: ui-feature-black-market-parity-with-market
- Short Title: Make Black Market panel mirror Market panel layout and affordances
- Run Folder Name: issue-0067-feature-black-market-ui-parity
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-24

---

## Goal
Restructure the Black Market (Cantina Back Room) UI to mirror the clean, two-column Market panel layout: a left “offers” column with a header row and a right “ship inventory” column with a header row, both using grid-style presentation. The Black Market panel should feel visually consistent with the Market panel while preserving all existing buy behavior.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Time advances only via `GameState.advance_time(reason)`; opening/using the Black Market UI does not advance time.
- UI does not mutate game state directly; purchase actions still route through `GameState` APIs and existing purchase flow.
- Black market gating (`GameState.location_has_black_market`) remains fail-closed; when unavailable, the panel shows a clear “no market” state and disables interactive controls.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- No selling mechanics added to the Black Market panel (inventory is read-only).
- No changes to Economy pricing, offer generation, determinism, or market availability logic.
- No changes to customs/inspection systems or FreightDoc required-fields work (Phase 1 remains separate).

---

## Context
The Market panel currently has a clean structure: Title + InfoRow (credits/cargo), then a two-column ContentRow with per-column header rows and Tree-based grids.  
The Black Market panel has been improved with an inventory column, but it still differs visually and structurally from the Market panel (ItemLists vs Trees, no matching header rows, and bottom-placed credits/cargo).  
We want the Black Market to feel like the Market panel for readability and consistency, while keeping the Black Market’s behavior and mechanics unchanged.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements.

- Update `BlackMarketPanel.tscn` node structure to mirror `MarketPanel`’s layout conventions: Title, InfoRow, ContentRow (HBox), OffersColumn + InventoryColumn, each with a header row and a grid control.
- Replace the offers and inventory `ItemList` widgets with `Tree` widgets configured with stable, minimal columns (Offers: Commodity, Price; Inventory: Commodity, Qty).
- Move existing credits/cargo display to an InfoRow at the top (matching Market panel placement).
- Update `BlackMarketPanel.gd` to populate the Trees deterministically (sorted by commodity name; stable tie-breaker by commodity id).
- Preserve the existing disabled-state behavior when no black market is present (no-market message + disabled controls).
- Keep buy flow, quantity selection, and logs behavior-equivalent; only UI presentation changes.

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

If Yes, list exact new file paths:

- N/A

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
- Offer and inventory ordering must be deterministic (sorted by commodity name; stable tie-breaker by commodity id).
- No randomness or time-based variance introduced by UI.
- Economy determinism remains keyed by `(system_id, tick, market_kind)` and is not modified by this job.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] Black Market panel layout mirrors Market panel structure: Title + top InfoRow + two-column ContentRow with header rows for both columns.
- [ ] Offers and Inventory are displayed using Tree grids with appropriate columns (Offers: Commodity, Price; Inventory: Commodity, Qty), and content is deterministically sorted.
- [ ] Buying from the Black Market still works exactly as before (credits decrease, cargo increases, inventory grid updates), and the no-market disabled state still functions without errors.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Load the game and dock at a location where `GameState.location_has_black_market(location_id)` is true.
2. Open Cantina ? Back Room (Black Market) and verify the UI layout matches the Market panel (top info row + two columns + header rows + grids).
3. Select an offer, set quantity > 1, buy it, and verify:
   - Credits decrease appropriately,
   - Cargo weight increases appropriately,
   - Inventory grid updates immediately.
4. Travel/dock to a location without a black market and open Back Room; verify “no black market” messaging and disabled controls remain correct.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Player has no cargo: inventory grid should render empty (no crash, no placeholder spam).
- Commodity DB lookup fails for an id: UI falls back to displaying the commodity id instead of crashing.
- Offers list empty: “No black market offers available” state remains clear and disables Buy.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Scene restructuring may break node paths; all onready paths in `BlackMarketPanel.gd` must be updated to match the new tree.
- Tree configuration (columns, select mode) must remain user-friendly and not reintroduce clipping/spacing issues.
- If assumptions prove false, Codex must stop and report rather than inventing solutions.

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
