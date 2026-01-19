# Feature Job

## Metadata (Required)
- Issue/Task ID: Issue-0047
- Short Title: Purchase Order FreightDoc on Market Purchase
- Run Folder Name: issue-0047-feature-purchase-order-freightdoc
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-19

---

## Goal
When the player successfully purchases cargo from a market, the game creates a Purchase Order freight document that records the acquisition and initializes container metadata and provenance.  
This establishes the authoritative origin of cargo without altering existing purchase behavior.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- All game state mutations (credits, cargo, documents) occur only via GameState.
- UI remains read-only; no UI element directly creates or mutates freight documents.
- Logging remains explicit, deterministic, and non-spammy.
- Existing purchase mechanics (credits and cargo changes) continue to function exactly as before.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- No Bill of Sale documents are created as part of purchasing cargo.
- No selling or disposal of cargo.
- No enforcement, legality, customs, fines, or reputation changes.
- No market snapshot or CSV export functionality.
- No contract fulfillment or delivery mechanics.

---

## Context
Describe relevant existing systems, scenes, or scripts.  
Include what already exists and what is missing.  
Do not propose solutions here.

- Market purchases are currently executed via `GameState.purchase_market_goods`, which mutates credits and cargo.
- FreightDocs already exist as a generalized document system, including container metadata, provenance, and authenticity handling.
- Earlier versions of market purchasing initialized container metadata and provenance implicitly; this behavior should be restored explicitly.
- Purchase Orders and Bills of Sale have been conceptually distinguished, but only Purchase Orders are relevant for acquisition.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries, not specific code structure.

- Introduce an explicit Purchase Order freight document type.
- On successful market purchase, create exactly one Purchase Order document.
- Populate the document with transaction details (commodity, qty, price, location, tick).
- Initialize container_meta as part of Purchase Order creation:
  - assign container id
  - set packed_tick
  - leave seal empty / unsealed
  - populate provenance
- Preserve existing credit and cargo mutation logic.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `singletons/GameState.gd`
- `scripts/docs/FreightDoc.gd` (or equivalent base document script)
- `scripts/ui/CaptainsQuartersPanel.gd`
- `scenes/ui/CaptainsQuartersPanel.tscn`

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

- `scripts/docs/PurchaseOrderDoc.gd`

---

## Public API Changes
List any new or modified public methods, signals, or resources.  
If none, write “None”.

- `GameState.create_purchase_order(...) -> String`
- `GameState.purchase_market_goods(...)` updated to call `create_purchase_order` on success

---

## Data Model & Persistence
Required if this job adds or modifies saved state.

- New or changed saved fields:
  - FreightDoc type identifier for Purchase Order.
  - Document payload fields:
    - commodity_id
    - qty
    - unit_price
    - total_cost
    - system_id
    - location_id
    - tick
  - container_meta fields:
    - id
    - packed_tick
    - seal (empty / unsealed)
    - provenance
- Migration / backward-compat expectations:
  - Existing FreightDocs remain valid and unchanged.
- Save/load verification requirements:
  - Purchase Order documents must serialize and deserialize correctly once persistence exists.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] Confirming a market purchase creates exactly one Purchase Order freight document.
- [ ] The Purchase Order includes initialized container_meta with packed_tick set, seal empty/unsealed, and provenance populated.
- [ ] Credits and cargo changes remain identical to current behavior.
- [ ] No Bill of Sale document is created during purchase.
- [ ] Purchase Order documents appear in the Captain’s Quarters document list.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Dock at a location with a market and open the Market panel.
2. Purchase cargo via the Purchase Order dialog.
3. Open the Captain’s Quarters and inspect the document list.
4. Verify a Purchase Order document exists with correct transaction data and container metadata.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Purchase fails due to insufficient credits or cargo capacity (no documents created).
- Invalid commodity or missing market (no documents created).
- Rapid repeated purchases do not corrupt document data or ordering.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Purchase Order schemas should be considered stable, as provenance and enforcement systems will depend on them.
- Containers created by purchase remain unsealed by design.
- Bill of Sale documents are intentionally deferred until selling mechanics are implemented.

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
