# Feature Job

## Metadata (Required)
- Issue/Task ID: Issue-0020
- Short Title: Captain�s Quarters � FreightDoc Modification & Evidence Logging
- Run Folder Name: issue-0020-feature-captains-quarters-doc-mod
- Job Type: feature
- Author (human): Douglass
- Date: 2026-01-15

---

## Scaffolding Permission (Read This First)
Codex is explicitly permitted to create and write ONLY the following governance paths as part of run scaffolding:

- `codex/runs/issue-0020-feature-captains-quarters-doc-mod/`
- `codex/runs/issue-0020-feature-captains-quarters-doc-mod/job.md` (verbatim from this document)
- `codex/runs/issue-0020-feature-captains-quarters-doc-mod/results.md` (stub allowed)
- `codex/runs/ACTIVE_RUN.txt` (must equal `issue-0020-feature-captains-quarters-doc-mod`)

Codex must complete this scaffolding before any code changes.
No other files under `codex/` may be modified.

---

## Goal
Allow the player to illegally modify or destroy FreightDocs from Captain�s Quarters, a private ship space accessible at any time via the existing Quarters button. These actions must mutate state only via GameState, leave immutable evidence for future inspections, and emit clear logs for success or failure.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- UI remains read-only with respect to game state; all mutations occur via GameState.
- Captain�s Quarters is a ship-private space accessed via the global Quarters button, not a location or facility.
- FreightDoc provenance fields (system, location, tick, market_kind, issuer, etc.) are never erased or rewritten.
- FreightDocs accumulate immutable edit evidence rather than inspection verdicts or scores.
- `back_room` remains a data artifact only and is never displayed as a standalone facility.
- Every attempted illegal action emits exactly one human-readable log entry.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- Implement customs inspections, port authority checks, or enforcement outcomes.
- Implement contract acceptance logic, issuer policies, or reputation effects.
- Implement smuggling contracts or laundering mechanics.
- Implement randomness or skill rolls for inspections.
- Implement save/load or file IO infrastructure.
- Add new global navigation buttons or UI entry points.

---

## Context
FreightDocs exist in `GameState.freight_docs` and include both `contract` and `bill_of_sale` docs (Issue-0018). Market purchases create cargo lines and Bills of Sale via `GameState.record_market_purchase(...)`. FreightDocs can be inspected read-only from Port and Bridge. Cantina and Black Market access exists (Issue-0019).

The game already includes a Captain�s Quarters button at:
`MainGame.tscn ? VBoxContainer/TopBar/QuartersButton`.

What does not exist yet:
- Any way to tamper with or destroy FreightDocs
- Any notion of undocumented cargo
- Any customs or port authority inspection systems
- Any save/load infrastructure

This job introduces only the illegal document manipulation substrate and evidence surfaces for future systems.

---

## Proposed Approach
A short, high-level plan (3�6 bullets).  
Describe intent and boundaries, not specific code structure.

- Reuse the existing Quarters button to open the Captain�s Quarters panel.
- Implement a Captain�s Quarters panel that allows FreightDoc modification and destruction.
- Route all actions through explicit GameState APIs gated by `source == "captains_quarters"`.
- Append exactly one immutable edit event per attempted action (success or failure).
- Detach destroyed FreightDocs from cargo lines deterministically.
- Do not implement inspections, scoring, legality checks, or persistence.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `singletons/GameState.gd`
- `scripts/Bridge.gd`
- `scripts/MainGame.gd`
- `scripts/ui/CaptainsQuartersPanel.gd`
- `scenes/ui/CaptainsQuartersPanel.tscn`
- `scripts/MainGame.gd`

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/MainGame.tscn`
- `scripts/Port.gd`
- `scenes/Port.tscn`

---

## New Files Allowed?
- [x] Yes
- [ ] No

If Yes, list exact new file paths:

- `scripts/ui/CaptainsQuartersPanel.gd`
- `scenes/ui/CaptainsQuartersPanel.tscn`

---

## Public API Changes
List any new or modified public methods, signals, or resources.

- `GameState.modify_freight_doc(doc_id: String, changes: Dictionary, source: String) -> Dictionary`
  - Validates `source == "captains_quarters"`.
  - Applies allowed changes (declared quantity, container metadata).
  - Appends exactly one immutable edit event.
  - Returns `{ "ok": bool, "error": String? }`.

- `GameState.destroy_freight_doc(doc_id: String, reason: String, source: String) -> Dictionary`
  - Validates `source == "captains_quarters"`.
  - Marks doc destroyed and detaches it from cargo lines.
  - Appends exactly one immutable edit event.
  - Returns `{ "ok": bool, "error": String? }`.

- `GameState.get_freight_doc(doc_id: String) -> Dictionary`
  - Read-only helper (unchanged if already present).

---

## Data Model & Persistence
Required if this job adds or modifies saved state.

> Note: No save/load exists yet. This defines runtime state shape only.

- New or changed saved fields:
  - `freight_docs[*].declared_quantity: int`
    - Default: initialize from existing quantity semantics if present.
  - `freight_docs[*].container_meta: Dictionary`
    - Example keys: `container_id`, `seal_id`, `seal_state`, `notes`
    - Default: `{}`.
  - `freight_docs[*].is_destroyed: bool`
    - Default: `false`.
  - `freight_docs[*].edit_events: Array[Dictionary]`
    - Immutable evidence records:
      ```gdscript
      {
        "event_id": String,
        "event_type": "edit_declared_qty" | "edit_meta" | "destroy_doc",
        "tick": int,
        "source": "captains_quarters",
        "before": Dictionary,
        "after": Dictionary,
        "tool_used": String,
        "quality": int,
      }
      ```

- Migration / backward-compat expectations:
  - Existing FreightDocs must function without requiring new fields.
  - New fields must be optional and defaultable at runtime.

- Save/load verification requirements:
  - None (save/load is explicitly out of scope).

---

## Acceptance Criteria (Must Be Testable)
These define �done� and must be objectively verifiable.

- [ ] Clicking the Quarters button opens the Captain�s Quarters panel from any game state.
- [ ] From Captain�s Quarters, the player can edit declared quantity, edit container/seal metadata, or destroy a FreightDoc.
- [ ] Each attempted modification (success or failure) appends exactly one immutable edit event.
- [ ] Destroyed FreightDocs are marked destroyed and detached from cargo lines without crashes.
- [ ] Attempts to modify or destroy FreightDocs without `source == "captains_quarters"` do not mutate state and emit a denial log entry.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Start the game and acquire cargo that generates a Bill of Sale.
2. Click the Quarters button in the top bar to open Captain�s Quarters.
3. Modify declared quantity on a FreightDoc and verify it appears in inspection UI.
4. Modify container/seal metadata and verify it appears in inspection UI.
5. Destroy the FreightDoc and verify it is marked destroyed and detached from cargo lines.
6. Attempt the same actions via a non-Quarters code path and verify failure + log entry.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Nonexistent `doc_id` ? graceful failure with log entry.
- Destroying an already destroyed doc ? safe failure or no-op with log entry.
- Invalid declared quantities (negative, nonsensical) ? rejected with clear error.
- Contract FreightDocs may be modified or destroyed without issuer checks.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Captain�s Quarters must remain a global ship UI, not a location-based facility.
- Inspection logic is intentionally deferred; this job only establishes evidence surfaces.
- Future customs, port authority, and contract systems will derive risk from `edit_events`.
- No save/load assumptions are permitted in implementation.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0020-feature-captains-quarters-doc-mod/`
2) Write this job verbatim to `codex/runs/issue-0020-feature-captains-quarters-doc-mod/job.md`
3) Create `codex/runs/issue-0020-feature-captains-quarters-doc-mod/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0020-feature-captains-quarters-doc-mod`

Codex must write final results only to:
- `codex/runs/issue-0020-feature-captains-quarters-doc-mod/results.md`

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
