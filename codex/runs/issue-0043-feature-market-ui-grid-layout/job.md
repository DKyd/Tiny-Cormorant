# Feature Job

## Metadata (Required)
- Issue/Task ID: Issue-0043
- Short Title: Market UI MVP � Grid-Based Layout with Ship Inventory
- Run Folder Name: issue-0043-feature-market-ui-grid-layout
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-19

---

## Goal
Restructure the Market UI into a clear, grid-based layout that presents market goods and ship inventory side-by-side.  
The goal is to improve readability, comparison, and selection flow while keeping the market fully read-only.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- The Market UI remains strictly read-only; no buying, selling, or game-state mutation is introduced.
- All market and inventory data is queried from GameState; the UI performs no inference or state mutation.
- Navigation and view ownership rules remain unchanged (views swap only via `_show_view()` in `MainGame.gd`).

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- No trading logic (no buy/sell, no price negotiation, no cargo transfer).
- No economy changes, pricing logic changes, or market simulation updates.
- No CSV export or document-related functionality.
- No invention or simulation of market quantity data.

---

## Context
Describe relevant existing systems, scenes, or scripts.  
Include what already exists and what is missing.  
Do not propose solutions here.

- The current Market UI displays product information as vertically stacked, free-form text strings, which limits readability and alignment.
- Ship inventory is currently stacked vertically relative to market information, making comparison awkward and forcing unnecessary scrolling.
- Market data and ship inventory data are already available via GameState queries and are rendered read-only.
- Market quantity / availability data is not yet modeled in the economy; any UI representation must tolerate missing quantity values without inference.

---

## Proposed Approach
A short, high-level plan (3�6 bullets).  
Describe intent and boundaries, not specific code structure.

- Replace the existing vertical stacking with a horizontal, side-by-side layout for market goods and ship inventory.
- Present market goods using a grid or table-style control with aligned columns (e.g., commodity name, quantity, price).
- Present ship inventory using a visually consistent grid/table view.
- Ensure quantity columns are structurally supported but render empty or placeholder values when quantity data is unavailable.
- Preserve existing selection and inspection affordances, adapting them to row-based selection as needed.
- Ensure all data is sourced directly from GameState and remains read-only.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `scenes/ui/MarketPanel.tscn`
- `scripts/ui/MarketPanel.gd`
- `scripts/ui/ShipInventoryPanel.gd` (or equivalent inventory UI script, if separate)

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
If none, write �None�.

- None

---

## Data Model & Persistence
Required if this job adds or modifies saved state.

- New or changed saved fields:
  - None
- Migration / backward-compat expectations:
  - None (UI-only change).
- Save/load verification requirements:
  - None.

---

## Acceptance Criteria (Must Be Testable)
These define �done� and must be objectively verifiable.

- [ ] Market goods are displayed in a grid/table with clearly aligned columns for commodity name and price.
- [ ] A quantity (QTY) column exists but renders as empty or a placeholder (e.g., ���) when quantity data is unavailable.
- [ ] Ship inventory is displayed side-by-side with the market in a similarly structured grid/table layout.
- [ ] The Market UI remains fully read-only: no credits, cargo, or other game state changes occur due to UI interaction.
- [ ] All displayed data is sourced directly from GameState, with no inferred or hard-coded quantity values.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Launch the game and dock at a location with a market.
2. Open the Market UI and verify that market goods and ship inventory are displayed horizontally side-by-side.
3. Confirm that commodity names and prices are aligned in columns and that the QTY column renders empty or as a placeholder.
4. Interact with rows (hover/select/inspect) and verify no buying, selling, or state changes occur.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Market with zero available goods renders an empty but stable grid without errors.
- Ship inventory with zero cargo renders an empty inventory grid without layout breakage.
- Missing or null quantity values do not produce errors, warnings, or inferred data.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Care must be taken not to accidentally introduce state mutation (e.g., through reused handlers intended for future buy/sell logic).
- Column definitions should be stable and extensible to support future features (buy/sell, market snapshots, CSV export) without rework.
- Avoid encoding assumptions about quantity semantics before the economy model supports them.

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
- [ ] All explicit player actions that succeed or fail emit a clear log entry (N/A � UI-only)
- [ ] All time advancement paths log a reason and tick delta (N/A)
- [x] No UI-only interactions produce log entries
- [x] No per-frame or loop-driven spam was introduced
- [x] Log messages are human-readable (no new logs)
- [x] `print()` usage is debug-only or removed in favor of `Log.add_entry()`
- [x] Log volume feels appropriate for a capped, recent-history log
