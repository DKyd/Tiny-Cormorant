# Refactor Job

## Metadata (Required)
- Issue/Task ID: phase1-preflight-refactor-purchase-docs
- Short Title: Canonicalize purchase paperwork: use Purchase Orders for all purchases (black market included)
- Run Folder Name: issue-0065-refactor-canonicalize-purchase-orders
- Job Type: refactor
- Author (human): Douglass Kyd
- Date: 2026-01-24

---

## Goal
Unify purchase documentation so that *all* purchases (including black market) are represented by `purchase_order` FreightDocs, eliminating the legacy “bill_of_sale for purchases” path. This is a structural normalization of freight-doc emission to reduce schema drift and prepare Phase 1 required-fields work.

No behavior change: credits, cargo quantities/weight checks, and player-facing outcomes for buying items remain the same.

---

## Non-Goals
- No gameplay changes.
- No feature additions.
- No behavior changes beyond structure/readability.

---

## Invariants (Must Remain True)
- Time advances only via `GameState.advance_time(reason)`.
- Docked UI interactions do not advance time.
- GameState remains authoritative for transitions.
- UI does not mutate state directly.
- Economy determinism remains keyed by `(system_id, tick, market_kind)`.

Job-specific invariants:
- A successful black market purchase still:
  - subtracts credits,
  - adds cargo,
  - records a purchase-related FreightDoc and links it to the cargo line via `doc_ids`,
  - logs the purchase in the Log panel.
- “Black market” intent must not be written onto the purchase FreightDoc in a way that self-incriminates.
  - (Market kind may remain internal on cargo lines; Purchase Order remains minimal.)

---

## Scope

### Files Allowed to Modify (Whitelist)
- `singletons/GameState.gd`
- `scripts/ui/BlackMarketPanel.gd`

### Files Forbidden to Modify (Blacklist)
- `data/**`
- `scenes/MainGame.tscn`

---

## Approach (High Level)
1) Consolidate purchase-doc creation so `GameState.record_market_purchase(...)` produces a `purchase_order` doc (via existing `create_purchase_order(...)`) instead of a purchase-shaped `bill_of_sale`.
2) Preserve existing call sites by keeping the `record_market_purchase(...)` function signature unchanged; update its internals only.
3) Ensure the cargo-line `doc_ids` linkage remains intact by storing the returned Purchase Order doc id in the cargo line.
4) (Compatibility hardening) In `BlackMarketPanel.gd`, read offer commodity identity using `commodity_id` with fallback to legacy `id` to prevent UI breakage during schema transitions.
5) Confirm behavior equivalence by verifying the same purchase flow works and only the emitted doc type changes.

---

## Verification

### Manual Test Steps
1. Launch the game, dock at a location with a black market (cartel influence = threshold).
2. Open the Cantina ? Back Room / Black Market panel.
3. Buy 1 unit of any offered commodity.
4. Verify:
   - Credits decrease by the displayed total cost.
   - Cargo increases by the purchased quantity.
   - No time tick advances due to the purchase UI action.
   - A new FreightDoc exists for the purchase and its `doc_type` is `purchase_order` (not `bill_of_sale`).
   - The related cargo line includes the Purchase Order doc id in `doc_ids`.
5. Sell a commodity through the normal sale flow and confirm Bills of Sale are still created for sales (unchanged).

### Regression Checklist
- [ ] No UI action advances time
- [ ] No state mutation moved into UI
- [ ] Logs still reflect real player actions
- [ ] No protected paths touched

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
- Summary of refactor
- Files changed
- Manual test results
- Confirmation behavior is unchanged
- Follow-ups / known gaps (if any)

---

## Migration Notes
None.
(Existing saves containing purchase-shaped `bill_of_sale` docs remain readable; new purchases will no longer generate such docs.)

---

## Logging Checklist
- [ ] No debug spam added
- [ ] No meaningful logs removed
- [ ] `print()` removed or debug-only
- [ ] Log volume appropriate
