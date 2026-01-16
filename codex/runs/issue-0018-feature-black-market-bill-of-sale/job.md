# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0018
- Short Title: Universal bill of sale freight docs for all purchases
- Run Folder Name: issue-0018-feature-black-market-bill-of-sale
- Job Type: feature
- Author (human): Douglass
- Date: 2026-01-15

---

## Goal
Ensure that every market purchase (legal or black market) generates a persistent
Bill of Sale freight document attached to the purchased cargo line.

The player must be able to inspect freight documents from multiple ship locations
(including Port and Bridge) via a read-only UI.

Document inspection must be location-agnostic, while future illegal modification
of documents is intentionally constrained to the Captains Quarters only.

---

## Invariants (Must Hold After This Job)
- Every purchased cargo line has exactly one Bill of Sale FreightDoc attached.
- Every FreightDoc references a valid cargo line ID or is explicitly destroyed.
- No cargo line references missing or invalid FreightDoc IDs.
- UI remains read-only with respect to game state (no direct mutation).
- Declared purchase documentation is independent of commodity legality.
- Freight document inspection is allowed from multiple ship locations, but no
  location permits document mutation in this job.

---

## Non-Goals
- No customs inspections or enforcement.
- No editing, forging, or destroying freight documents.
- No smuggling contracts or contract laundering.
- No political simulation or legality shifts (docs must merely support them later).
- No punishment, fines, or reputation changes.

---

## Context
The game already contains an initial freight document system:

- Freight docs are stored in `GameState.freight_docs` as an Array of Dictionaries.
- A `FreightDocsPanel` scene exists and currently lists freight docs in the Port.
- Selecting a doc currently logs its details to the game log.
- Existing docs are primarily contract-oriented
  (origin, destination, contract_id, status, cargo_lines).

However:
- Freight docs are not generated for market purchases.
- Freight docs are not yet accessible from Bridge or Captains Quarters.
- There is no explicit Bill of Sale document type.

Future smuggling mechanics require that all cargo have declared provenance and
transaction records so that legality can change over time without retroactively
invalidating documentation.

This job extends the existing freight doc system rather than replacing it.

---

## Proposed Approach
- Reuse and extend the existing freight doc system
  (`GameState.freight_docs` and `FreightDocsPanel`).
- Add a `doc_type` field to freight docs
  (at minimum: `bill_of_sale` and legacy contract docs).
- Generate a Bill of Sale FreightDoc for every market purchase:
  - Normal market purchases.
  - Black market purchases.
- Attach the Bill of Sale doc to the purchased cargo line using an explicit reference
  (e.g., `cargo_line_id`) without breaking existing saves.
- Make `FreightDocsPanel` accessible from Port and Bridge
  for read-only inspection.

---

## Discovery & Lockdown (Mandatory)
The exact location of ship cargo / inventory mutation logic is currently unknown.

Before implementing Bill of Sale creation on purchase, Codex must:

1) Search the repository (read-only) for the code responsible for:
   - Adding purchased cargo
   - Tracking cargo space usage
   - Methods such as `get_free_cargo_space`, `cargo_space`, or similar
2) Identify the exact script file(s) where cargo is added or removed.
3) Update this job.md whitelist to include only the exact file paths that must be
   modified to attach Bill of Sale FreightDocs at the point of purchase.
4) Proceed with implementation only after the whitelist is corrected.

No functional changes may be made until this discovery step is complete.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `singletons/GameState.gd`
- `scripts/MarketPanel.gd`
- `scripts/FreightDocsPanel.gd`

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
- Extend the existing freight doc schema stored in `GameState.freight_docs`
  to include a `doc_type` field.
- Add or extend GameState helper methods for creating and querying freight docs
  related to market purchases.
- Add UI entry points to open `FreightDocsPanel` from Port and Bridge.

---

## Data Model & Persistence
- New or changed saved fields:
  - Extend existing freight docs with a `doc_type` field.
  - Bill of Sale docs include fields sufficient to identify the purchase and
    link to cargo (e.g., `cargo_line_id`, commodity id, quantity,
    purchase system/location, timestamp or tick).
- Migration / backward-compat expectations:
  - Existing saves with freight docs load without modification.
  - Docs missing `doc_type` are treated as legacy contract docs.
- Save/load verification requirements:
  - Bill of Sale docs persist across save/load cycles.
  - Cargo and doc references remain valid after reload.

---

## Acceptance Criteria (Must Be Testable)
- [ ] Buying legal cargo via a normal market creates exactly one Bill of Sale FreightDoc.
- [ ] Buying cargo via a black market creates exactly one Bill of Sale FreightDoc.
- [ ] FreightDocs are attached to the correct cargo lines.
- [ ] FreightDocs can be inspected from Port and Bridge.
- [ ] FreightDocs are inspectable via a read-only UI only.
- [ ] Save and reload preserves cargo and attached FreightDocs without corruption.

---

## Manual Test Plan
1. Load an existing save with a docked ship.
2. Buy a legal commodity from a normal market.
3. Open FreightDocsPanel from the Port and inspect the Bill of Sale.
4. Open FreightDocsPanel from the Bridge and inspect the same doc.
5. Save the game, reload, and re-verify all cargo and docs.

---

## Edge Cases / Failure Modes
- Attempting to inspect a missing or invalid FreightDoc fails gracefully.
- Save files created before this feature load correctly.
- UI does not crash if a cargo line has zero docs (legacy or corrupted saves).

---

## Risks / Notes
- Incorrect doc-to-cargo binding could corrupt save data if not validated.
- FreightDoc ownership must remain centralized in `GameState`.
- Debug `print()` statements in FreightDocsPanel should not cause log spam.
- Location-based editing restrictions must be enforced explicitly in later jobs.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0018-feature-black-market-bill-of-sale/`
2) Write this job verbatim to `codex/runs/issue-0018-feature-black-market-bill-of-sale/job.md`
3) Create `codex/runs/issue-0018-feature-black-market-bill-of-sale/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0018-feature-black-market-bill-of-sale`

Codex must write final results only to:
- `codex/runs/issue-0018-feature-black-market-bill-of-sale/results.md`

Results must include:
- Summary of changes and rationale
- Files changed (with brief explanation per file)
- Assumptions made
- Known limitations or TODOs

---

## Logging Checklist
- [ ] Market purchases emit a clear log entry
- [ ] Bill of Sale FreightDoc creation emits a log entry
- [ ] No UI-only interactions produce log entries
- [ ] No per-frame or loop-driven spam was introduced
- [ ] Log messages are human-readable
- [ ] `print()` usage is debug-only or removed in favor of `Log.add_entry()`
- [ ] Log volume feels appropriate for a capped, recent-history log
