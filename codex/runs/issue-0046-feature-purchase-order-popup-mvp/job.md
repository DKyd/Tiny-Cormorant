# Feature Job

## Metadata (Required)
- Issue/Task ID: Issue-0046
- Short Title: Purchase Order Popup MVP (Select Market Item -> Buy Qty)
- Run Folder Name: issue-0046-feature-purchase-order-popup-mvp
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-19

---

## Goal
Enable the player to buy market goods again by creating a simple “Purchase Order” popup from the Market UI.  
The player selects a commodity, enters a quantity, and confirms to execute a purchase (credits decrease, cargo increases) with a clear log entry.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- UI remains read-only with respect to game state; all mutations (credits/cargo/docs) occur via GameState methods.
- No UI-only interactions emit logs; only explicit player actions that succeed or fail emit a single clear log entry.
- Existing navigation and lifecycle rules remain unchanged (views swap only via `_show_view()`; panels do not manage global lifecycle).

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- No selling flow and no “Sell Manifest Inventory” behavior beyond placeholder signaling (if present).
- No market quantity enforcement (markets are effectively infinite for now); do not invent or simulate market stock limits.
- No CSV export, market snapshots, or Captain’s Quarters export UI.
- No enforcement, customs, fines, legality, reputation, or political systems.

---

## Context
Describe relevant existing systems, scenes, or scripts.  
Include what already exists and what is missing.  
Do not propose solutions here.

- Market UI was restructured to show two Tree grids: Market Goods and Ship Inventory side-by-side.
- The previous Buy/Sell buttons and quantity SpinBox were removed; MarketPanel currently cannot execute trades.
- MarketPanel now emits `request_create_purchase_order` when the “Create Purchase Order” button is pressed.
- Market grid rows contain commodity_id in TreeItem metadata (column 0), and market prices are available via GameState/Economy queries.
- Cargo capacity and money exist in GameState, and purchase/bill-of-sale recording has existed previously (may have been removed during UI restructure).

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries, not specific code structure.

- Add a modal popup (Purchase Order) opened from MarketPanel when the player has a valid market row selected and presses “Create Purchase Order”.
- Popup displays: selected commodity name, unit price, quantity input, computed total cost, current credits, and cargo capacity info.
- On confirm, call a single GameState method to validate and execute the purchase (credits and cargo mutation).
- Refresh MarketPanel UI after a successful purchase (money/cargo labels and inventory grid).
- Emit exactly one log entry on success and one on failure (SHIP category), with no logs for selection or dialog opening/closing.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `scripts/MarketPanel.gd`
- `scenes/ui/MarketPanel.tscn`
- `singletons/GameState.gd`
- `singletons/Log.gd`
- `scenes/ui/PurchaseOrderDialog.tscn`
- `scripts/ui/PurchaseOrderDialog.gd`

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/MainGame.tscn`

---

## New Files Allowed?
- [x] Yes (must list exact paths below)
- [ ] No

If Yes, list exact new file paths:

- `scenes/ui/PurchaseOrderDialog.tscn`
- `scripts/ui/PurchaseOrderDialog.gd`

---

## Public API Changes
List any new or modified public methods, signals, or resources.  
If none, write “None”.

- `GameState.purchase_market_goods(commodity_id: String, qty: int) -> Dictionary`
  - Returns `{ ok: bool, error: String }` and may include `{ total_cost: float }` on success.
- `PurchaseOrderDialog` signals (example):
  - `confirmed(commodity_id: String, qty: int)`
  - `cancelled()`

---

## Data Model & Persistence
Required if this job adds or modifies saved state.

- New or changed saved fields:
  - None required for MVP (purchase affects existing runtime fields: player_money, cargo state, existing docs if already present).
- Migration / backward-compat expectations:
  - None.
- Save/load verification requirements:
  - None (persistence out of scope).

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] With a market row selected, pressing “Create Purchase Order” opens a popup showing commodity, unit price, quantity input, and computed total cost.
- [ ] Confirming the popup executes a purchase via GameState: credits decrease by total cost and cargo increases by quantity (respecting existing cargo capacity rules).
- [ ] Invalid purchases (no selection, insufficient credits, insufficient cargo capacity, unknown commodity) fail gracefully: no state changes occur and exactly one clear failure log entry is emitted.
- [ ] Successful purchases emit exactly one clear success log entry and refresh the MarketPanel display (credits/cargo labels and inventory grid).

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Launch the game, dock at a location with a market, and open the Market tab.
2. Select a commodity in the Market Goods grid and press “Create Purchase Order”.
3. Enter a quantity and confirm. Verify credits decrease and inventory grid shows the purchased commodity with increased qty.
4. Attempt to buy with quantity so large that credits are insufficient; confirm purchase is rejected, credits/cargo unchanged, and a single failure log appears.
5. Attempt to buy with quantity so large that cargo capacity would be exceeded; confirm purchase is rejected, credits/cargo unchanged, and a single failure log appears.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- “Create Purchase Order” pressed with no market selection (popup should not proceed, or should show a clear message; no crash).
- Commodity metadata missing/invalid on the selected TreeItem (fail safely; no state changes).
- Qty input is 0 or negative (clamp or reject with clear UI; no state changes).
- Economy returns no price for commodity (fail safely; no state changes).

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Ensure that MarketPanel remains “read-only” in the sense that it does not mutate state directly; only GameState may mutate credits/cargo.
- Avoid reintroducing per-frame logging or debug prints while wiring signals/dialog flow.
- Keep the purchase API result-based (ok/error) so future enforcement, tariffs, and market quantity limits can be added without changing UI flow.
- Markets are infinite for now: do not introduce any market-side stock depletion in this job.

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
- [x] All explicit player actions that succeed or fail emit a clear log entry
- [ ] All time advancement paths log a reason and tick delta (N/A)
- [x] No UI-only interactions produce log entries
- [x] No per-frame or loop-driven spam was introduced
- [x] Log messages are human-readable
- [x] `print()` usage is debug-only or removed in favor of `Log.add_entry()`
- [x] Log volume feels appropriate for a capped, recent-history log
