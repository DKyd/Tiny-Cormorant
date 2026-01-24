# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0068 
- Short Title: Black Market panel mirrors Market panel layout + purchase-order flow
- Run Folder Name: issue-0068-feature-black-market-mirror-market 
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-24

---

## Goal
Update the Black Market UI so it mirrors the Market panel’s structure and interaction flow: a clean InfoRow, two Tree grids (offers + ship inventory), and a Purchase Order dialog-based buying flow rather than the current inline quantity+buy behavior.

---

## Invariants (Must Hold After This Job)
- Time advances only via `GameState.advance_time(reason)`.
- Docked UI interactions do not advance time.
- GameState remains authoritative for transitions.
- UI does not mutate game state directly (UI requests actions; GameState performs state changes).
- Economy determinism remains keyed by `(system_id, tick, market_kind)`.

---

## Non-Goals
- Do not add new gameplay systems (no customs logic changes, no new org/influence logic).
- Do not change pricing logic or how black market offers are generated.
- Do not refactor unrelated UI or shared systems outside the whitelist.

---

## Context
- `MarketPanel` already has a clean, consistent layout:
  - InfoRow (Credits/Cargo)
  - ContentRow with two columns:
    - Market column: Tree grid + header row including "Create Purchase Order" button
    - Inventory column: Tree grid + header row including "Sell Manifest Inventory" button
  - Buying is mediated by `PurchaseOrderDialog` (Window) and uses `GameState.purchase_market_goods()` from the MarketPanel flow.
- `BlackMarketPanel` recently moved to Tree grids and added ship inventory, but still differs from MarketPanel in:
  - grid column structure (2 columns vs 3)
  - missing header button flow
  - buying uses inline quantity SpinBox + Buy button rather than PurchaseOrderDialog.
- The desired end state is for BlackMarketPanel to “feel” identical to MarketPanel in layout and interaction, while still using black market offers and black market market_kind when recording purchases.

---

## Proposed Approach
- Restructure `BlackMarketPanel.tscn` to match MarketPanel’s node hierarchy and naming conventions where practical (InfoRow, ContentRow, Offers/Inventory columns, header rows with spacer controls).
- Update `BlackMarketPanel.gd` to:
  - configure offers Tree as **3 columns** ("Commodity", "Qty", "Price") matching MarketPanel; offers Qty can be "-" to mirror MarketPanel.
  - configure inventory Tree as **3 columns** ("Commodity", "Qty", "Price") matching MarketPanel; inventory Price can be "-" or show black market unit price only if easily available without adding new systems.
  - introduce a `PurchaseOrderDialog` Window in the BlackMarketPanel scene and wire it like MarketPanel (confirmed/cancelled, hidden by default).
  - replace inline buy flow with:
    - select offer in offers grid
    - click a header button (mirroring "Create Purchase Order") to open PurchaseOrderDialog
    - on confirm, call the appropriate GameState purchase method using the BLACK_MARKET market kind, and refresh the panel.
- Preserve the existing “no black market at this location” disabled state behavior.

---

## Files: Allowed to Modify (Whitelist)
- `scenes/ui/BlackMarketPanel.tscn`
- `scripts/ui/BlackMarketPanel.gd`
- `scenes/ui/PurchaseOrderDialog.tscn` (ONLY if required to support reuse in BlackMarket; prefer no changes)
- `scripts/ui/PurchaseOrderDialog.gd` (ONLY if required to support reuse in BlackMarket; prefer no changes)

---

## Files: Forbidden to Modify (Blacklist)
- `data/**`
- `scenes/MainGame.tscn`

---

## New Files Allowed?
- [ ] Yes (must list exact paths below)
- [x] No

If Yes, list exact new file paths:
- (none)

---

## Public API Changes
None.

---

## Data Model & Persistence
- New or changed saved fields:
  - None.
- Migration / backward-compat expectations:
  - None.
- Save/load verification requirements:
  - Not applicable (UI-only changes).

---

## Determinism & Stability (If Applicable)
- Black market offers must remain deterministic as provided by Economy for `(system_id, tick, market_kind)`.
- No UI changes may introduce randomness, time-based variance, or hidden time advancement.

---

## Acceptance Criteria (Must Be Testable)
- [ ] Black Market panel layout mirrors Market panel: InfoRow at top, ContentRow with two columns, each column has a header row and a Tree grid with column titles.
- [ ] Offers grid uses 3 columns ("Commodity", "Qty", "Price") and displays Qty as "-" (or equivalent) for offers, matching MarketPanel’s visual rhythm.
- [ ] Buying an item uses the PurchaseOrderDialog flow (open dialog from an explicit button in the offers header; confirm/cancel works; dialog is hidden by default and never appears unexpectedly on Port entry).
- [ ] Confirming a purchase results in cargo being added and credits deducted via GameState, and the purchase is recorded as BLACK_MARKET (or equivalent black market kind) for downstream document/logging behavior.
- [ ] When no black market is available at the current location, the panel shows a clear message and disables interaction (offers/inventory grids and buy flow).

---

## Manual Test Plan
1. Start the game, dock at a location with a black market available. Open Cantina ? Back Room (Black Market).
2. Verify UI structure:
   - Credits/Cargo appear in a top InfoRow.
   - Two columns exist with headers and Tree grids.
   - Offers grid column titles are Commodity/Qty/Price; Inventory grid titles are Commodity/Qty/Price.
3. Select a black market offer and press the header button to open PurchaseOrderDialog.
   - Confirm purchase of a quantity you can afford/carry.
   - Verify credits decrease and cargo increases, and the Black Market panel refreshes correctly.
4. Cancel out of the dialog and verify no purchase occurs and dialog hides.
5. Dock at a location without a black market and open the panel.
   - Verify message "No black market at this location." (or equivalent) and interaction is disabled.

---

## Edge Cases / Failure Modes
- Selected offer has missing commodity id or missing price: PurchaseOrderDialog should not open; a status message should be shown (or a log entry) and the panel should remain stable.
- Player lacks credits or cargo capacity: purchase should fail gracefully with a clear status/log message; no state corruption.
- Current system id is empty: panel should show a clear message and disable buy flow.

---

## Risks / Notes
- `PurchaseOrderDialog` must be hidden on initialization (like MarketPanel) to prevent it appearing unexpectedly when entering Port/Black Market.
- Keep scope tight: mimic MarketPanel structure and wiring; do not introduce new custom dialogs or new market systems.
- If assumptions about PurchaseOrderDialog’s callable interface (`setup`, `set_status`, signals) prove false, Codex must stop and report rather than inventing solutions.

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
