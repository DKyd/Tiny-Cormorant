# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0027
- Short Title: Captain’s Quarters Inspector Shows Packed Tick & Provenance
- Run Folder Name: issue-0027-captains-quarters-inspector-packed-tick-provenance
- Job Type: feature
- Author (human): Douglass
- Date: 2026-01-16

---

## Goal
Extend the Captain’s Quarters Selected FreightDoc inspector to display container packing time (packed_tick) and structured provenance for the selected FreightDoc. These fields must update live when the selected FreightDoc changes.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- UI remains read-only with respect to game state; all mutations still occur via GameState.
- No inspections, penalties, seizures, reputation changes, or legality checks are introduced.
- No persistence changes or migrations are added; the inspector only surfaces existing runtime fields.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- Do not change how container_meta is generated (creation-time defaults remain owned by Issue-0026).
- Do not modify authenticity/evidence derivation logic or add any enforcement mechanics.

---

## Context
Issue-0023 introduced a read-only Selected FreightDoc inspector with live updates. Issue-0025 extended it to show derived authenticity and evidence. Issue-0026 standardized container_meta initialization for contract and market-created FreightDocs, including:
- container_meta.packed_tick (from GameState time_tick)
- container_meta.provenance (structured Dictionary with source/system_id/location_id)

What is missing is UI visibility: the inspector currently does not display packed_tick or provenance.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries, not specific code structure.

- Add two read-only inspector rows under InspectorGrid: Packed Tick and Provenance.
- Populate Packed Tick from container_meta.packed_tick (show “-” if missing).
- Populate Provenance from container_meta.provenance with simple formatting (show “None” if missing/empty).
- Ensure the new fields clear correctly in the inspector empty state.
- Ensure values update live via the existing freight_doc_changed refresh/render flow.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `scripts/ui/CaptainsQuartersPanel.gd`
- `scenes/ui/CaptainsQuartersPanel.tscn`

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/MainGame.tscn`

---

## New Files Allowed?
- [ ] Yes
- [x] No

If Yes, list exact new file paths:

- (none)

---

## Public API Changes
List any new or modified public methods, signals, or resources.  
If none, write “None”.

- None

---

## Data Model & Persistence
Required if this job adds or modifies saved state.

- New or changed saved fields:
  - None
- Migration / backward-compat expectations:
  - Not applicable
- Save/load verification requirements:
  - Not applicable

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] The Selected FreightDoc inspector displays Packed Tick for the selected FreightDoc when container_meta.packed_tick exists, and “-” when it does not.
- [ ] The Selected FreightDoc inspector displays Provenance for the selected FreightDoc when container_meta.provenance exists, and “None” when it does not.
- [ ] Packed Tick and Provenance update live when the selected FreightDoc changes (selection change, edit, or destruction) without requiring manual refresh and without wiping user edit inputs.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Open Captain’s Quarters and select a FreightDoc created from a newly accepted contract:
   - Packed Tick shows a numeric value
   - Provenance shows a contract-origin source + system/location identifiers
2. Purchase freight from a market (creating a market bill of sale FreightDoc) and select it:
   - Packed Tick shows a numeric value
   - Provenance indicates market_purchase + system/location identifiers
3. Clear selection (or select a missing doc after refresh) and verify:
   - Packed Tick shows “-”
   - Provenance shows “None”
4. Confirm editable inputs (declared qty / container fields) are not cleared by these inspector updates unless the user changes them.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- FreightDocs created before Issue-0026 that lack packed_tick/provenance display the default “-” / “None” without errors.
- Provenance is not assumed to be a string; if it’s a Dictionary, the formatter must handle it safely.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Node path mismatches between the script @onready bindings and the .tscn nodes will cause runtime errors; keep names/paths consistent.
- Provenance formatting is intentionally minimal; future UI may want richer presentation or clickable drill-down.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0027-captains-quarters-inspector-packed-tick-provenance/`
2) Write this job verbatim to `codex/runs/issue-0027-captains-quarters-inspector-packed-tick-provenance/job.md`
3) Create `codex/runs/issue-0027-captains-quarters-inspector-packed-tick-provenance/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0027-captains-quarters-inspector-packed-tick-provenance`

Codex must write final results only to:
- `codex/runs/issue-0027-captains-quarters-inspector-packed-tick-provenance/results.md`

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
