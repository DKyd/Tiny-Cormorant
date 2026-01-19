# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0049
- Short Title: Sell Manifest Cargo & Generate Bills of Sale
- Run Folder Name: issue-0049-feature-sell-manifest-cargo
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-19

---

## Goal
Enable the player to sell cargo from their ship�s manifest at a market, generating Bill of Sale FreightDocs that record disposition events with explicit lineage back to source documents, while mutating ship cargo and credits via GameState.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- UI remains read-only with respect to game state; all mutations occur via GameState.
- Selling cargo generates new FreightDocs (Bills of Sale) and does not mutate existing acquisition documents.
- Pricing logic is centralized and future-proofed for duties/taxes via a single quote interface.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- Implement customs inspections, enforcement, seizures, fines, or reputation effects.
- Implement organization, faction, tariff, or legality systems.

---

## Context
The game currently supports purchasing cargo via markets, generating Purchase Order FreightDocs that represent acquisition events. Ship cargo is stored in GameState, and FreightDocs are dictionaries with container metadata and provenance. There is no selling flow yet.

Future systems (customs, enforcement, organizations) will inspect manifests and FreightDocs to reconcile cargo lineage and apply duties or penalties. This job must prepare for those systems without implementing them.

---

## Proposed Approach
A short, high-level plan (3�6 bullets).

- Add a sell-manifest flow that allows selling selected cargo quantities at a market.
- Route all sale pricing through a centralized Economy quote function.
- On successful sale, mutate ship cargo and credits via GameState.
- Generate a Bill of Sale FreightDoc representing the disposition event.
- Record explicit source document lineage per sold cargo line (Option A).
- Emit appropriate log entries for successful sales.
- Implement a programmatic Sell modal in MarketPanel mirroring Purchase Order dialog UX (qty picker, inline errors, confirm/cancel).

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `singletons/GameState.gd`
- `singletons/Economy.gd`
- `scripts/ui/MarketPanel.gd`
- `scripts/ui/FreightDocsPanel.gd`

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

- `GameState.sell_manifest_goods(commodity_id, qty, system_id, location_id, market_kind)`
- `Economy.quote_sale_price(commodity_id, qty, system_id, location_id, market_kind)`

---

## Data Model & Persistence
Required if this job adds or modifies saved state.

- New or changed saved fields:
  - New FreightDoc type: `bill_of_sale`
  - Bill of Sale cargo lines include:
    - `commodity_id`
    - `sold_qty`
    - `unit_price`
    - `total_price`
    - `sources: Array[{ doc_id, qty }]`
- Migration / backward-compat expectations:
  - Existing saves without Bills of Sale continue to function unchanged.
- Save/load verification requirements:
  - Sold cargo quantities and generated FreightDocs persist correctly across save/load.

---

## Acceptance Criteria (Must Be Testable)
These define �done� and must be objectively verifiable.

- [ ] Selling cargo reduces ship cargo and increases credits by the quoted amount.
- [ ] A Bill of Sale FreightDoc is generated for each sale.
- [ ] Bill of Sale cargo lines reference source Purchase Orders or Contracts with explicit quantities.
- [ ] Sale pricing flows through `Economy.quote_sale_price`.
- [ ] Logs correctly label sales as Bills of Sale with appropriate category.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Dock at a location with a market and purchase cargo to generate a Purchase Order.
2. Open the market UI and sell a portion of the purchased cargo.
3. Verify credits increase and ship cargo decreases accordingly.
4. Open Captain�s Quarters ? Docs and confirm a Bill of Sale is listed.
5. Inspect the Bill of Sale to verify source document references and quantities.
6. Check the log panel for a clear, non-spammy sale entry.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Attempting to sell more cargo than exists in the manifest.
- Attempting to sell cargo when no market is present at the location.
- Selling cargo sourced from multiple Purchase Orders in a single transaction.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Incorrect lineage tracking could complicate future customs reconciliation.
- Pricing logic must remain centralized to avoid future refactors when duties/taxes are added.
- Care must be taken not to mutate or �close out� source documents implicitly.

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
