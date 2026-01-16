# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0019
- Short Title: Cantina access and back room black market purchases
- Run Folder Name: issue-0019-feature-cantina-black-market
- Job Type: feature
- Author (human): Douglass
- Date: 2026-01-15

---

## Goal
Allow the player to enter a Cantina space from docked locations that advertise a cantina,
and from there open a Back Room interface that functions as a black market panel.

Each successful black market purchase must add cargo and create a Bill of Sale
freight document tagged as black market, consistent with the existing freight doc system.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Every successful black market purchase records a Bill of Sale via
  `GameState.record_market_purchase(..., MARKET_KIND_BLACK_MARKET)` exactly once.
- FreightDocs remain read-only from Port and Bridge; no document mutation is introduced.
- Save/load remains backward-compatible; existing saves continue to load without error.
- Opening or closing UI does not advance time.

---

## Non-Goals
Explicitly list what this job must NOT do.
These are hard scope boundaries.

- No forging, editing, or destroying freight documents.
- No customs inspections, searches, or punishments.
- No smuggling contracts or contract laundering.
- No political legality shift simulation.
- No cantina NPC dialogue, missions, or quests.

---

## Context
Describe relevant existing systems, scenes, or scripts.
Include what already exists and what is missing.
Do not propose solutions here.

- Locations can advertise available spaces (e.g. market, cantina).
- The Port UI owns facility navigation (Market, Contracts, Ship, Docs).
- There is currently no Cantina scene or UI access path.
- The legal market UI exists and supports cargo purchases.
- Market purchases generate Bill of Sale freight docs via
  `GameState.record_market_purchase`.
- FreightDocsPanel exists and is accessible from Port and Bridge for inspection.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).
Describe intent and boundaries, not specific code structure.

- Add a Cantina button to the Port facility UI when the docked location has a cantina.
- Implement a minimal Cantina panel with a Back Room button.
- Open a Black Market panel from the Back Room.
- Present a distinct list of black market offerings.
- On successful purchase, add cargo and call
  `GameState.record_market_purchase` with `MARKET_KIND_BLACK_MARKET`.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `singletons/GameState.gd`
- `singletons/Economy.gd`
- `scripts/MarketPanel.gd`
- `scripts/MapPanel.gd`
- `scripts/Bridge.gd`
- `scripts/Log.gd`
- `scripts/FreightDocsPanel.gd`
- `scripts/Port.gd`
- `scenes/Port.tscn`

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/MainGame.tscn`

---

## New Files Allowed?
- [x] Yes
- [ ] No

If Yes, list exact new file paths:

- `scenes/ui/CantinaPanel.tscn`
- `scripts/ui/CantinaPanel.gd`
- `scenes/ui/BlackMarketPanel.tscn`
- `scripts/ui/BlackMarketPanel.gd`

---

## Public API Changes
List any new or modified public methods, signals, or resources.

- Economy: add a read-only method to retrieve black market offerings for a location or system.
- No other public API changes.

---

## Data Model & Persistence
Required if this job adds or modifies saved state.

- New or changed saved fields:
  - None (reuses cargo lines and Bill of Sale persistence from issue-0018).
- Migration / backward-compat expectations:
  - Not applicable.
- Save/load verification requirements:
  - Black market purchases persist correctly across save/load.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] If the docked location has a cantina, the Port UI shows a Cantina button.
- [ ] The Cantina panel includes a Back Room button that opens the Black Market panel.
- [ ] Purchasing from the black market adds cargo and creates exactly one Bill of Sale
      FreightDoc with `market_kind = MARKET_KIND_BLACK_MARKET`.
- [ ] The Bill of Sale is visible in FreightDocsPanel and logs readable details.
- [ ] Save and reload preserves the purchased cargo and its Bill of Sale.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Dock at a location that advertises a cantina.
2. Open the Cantina from the Port UI.
3. Enter the Back Room and open the Black Market panel.
4. Buy an illicit commodity.
5. Open FreightDocsPanel from Port or Bridge and verify the Bill of Sale.
6. Save, reload, and verify cargo and docs persist.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Location has no cantina: Cantina button is hidden or disabled.
- Black market has no offerings: panel shows an empty state.
- Insufficient credits or cargo space: purchase fails gracefully with no side effects.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts, or architectural concerns.

- Port UI owns facility navigation; Cantina access must be implemented there.
- Avoid duplicating legal market purchase logic.
- Ensure `record_market_purchase` is called exactly once per successful purchase.
- Captain’s Quarters and document mutation are intentionally deferred.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0019-feature-cantina-black-market/`
2) Write this job verbatim to `codex/runs/issue-0019-feature-cantina-black-market/job.md`
3) Create `codex/runs/issue-0019-feature-cantina-black-market/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0019-feature-cantina-black-market`

Codex must write final results only to:
- `codex/runs/issue-0019-feature-cantina-black-market/results.md`

Results must include:
- Summary of changes and rationale
- Files changed (with brief explanation per file)
- Assumptions made
- Known limitations or TODOs

---

## Logging Checklist
- [ ] All explicit player actions that succeed or fail emit a clear log entry
- [ ] No UI-only interactions produce log entries
- [ ] No per-frame or loop-driven spam was introduced
- [ ] Log messages are human-readable
- [ ] `print()` usage is debug-only or removed in favor of `Log.add_entry()`
- [ ] Log volume feels appropriate for a capped, recent-history log
