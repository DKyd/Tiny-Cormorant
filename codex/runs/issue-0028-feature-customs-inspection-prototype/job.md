# Feature Job

## Metadata (Required)
- Issue/Task ID: Issue-0028
- Short Title: Customs Inspection Prototype (Read-Only, Report-Only)
- Run Folder Name: issue-0028-feature-customs-inspection-prototype
- Job Type: feature
- Author (human): Douglass
- Date: 2026-01-16

---

## Goal
Add a **Customs Inspection** interaction that produces a **structured, read-only inspection report** by consuming existing FreightDoc authenticity/evidence/container metadata and current cargo/doc availability. The inspection produces **no gameplay consequences** (no fees, no seizures, no rep changes), but is **future-proofed** by including penalty recommendation fields in the report payload.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- UI remains read-only with respect to game state; all mutations occur via GameState (this job must introduce no new mutation paths).
- FreightDoc authenticity and evidence flags remain **runtime-derived** only (no persistence added; no save/load changes).
- Customs inspection actions (manual or random entry checks) must not modify: player money, cargo, FreightDocs, reputation, contracts, or time.
- Panels do not self-close or manage lifecycle; navigation remains via TopBar and `_show_view()`.

---

## Non-Goals
Explicitly list what this job must NOT do.
These are hard scope boundaries.

- No processing fees, no immediate money deduction, no fines created, no confiscation, no holds, no forced routing, no reputation impacts.
- No customs / port authority enforcement logic or escalation (that belongs in future Issue-0030+).
- No save/load changes, migrations, or persistence of inspection reports.
- No changes to FreightDoc creation, container_meta creation, authenticity scoring, or evidence flag derivation.

---

## Context
Relevant existing systems:

- FreightDocs include `container_meta` (container_id, seal_id, seal_state, packed_tick, provenance, notes), `edit_events`, and `is_destroyed`.
- Authenticity and evidence flags are derived at runtime via:
  - `GameState.get_doc_evidence_flags(doc_id)`
  - `GameState.get_doc_authenticity(doc_id)`
- Captain’s Quarters has a read-only FreightDoc inspector that live-updates from `GameState.freight_doc_changed`.
- There is existing Customs logic (already in repo) that:
  - rolls a chance to inspect based on a system security level
  - currently levies a per-doc processing fee by mutating `GameState.player_money`

What is missing:

- A consistent, report-producing Customs inspection that consumes the above evidence model.
- A Port-facing inspection action and UI report display.
- Removal of the current fee/money mutation from Customs while consequences are out of scope.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).
Describe intent and boundaries, not specific code structure.

- Introduce a report builder that evaluates the player’s current freight documentation state and yields a structured inspection report dictionary.
- Add a Port UI action to run an inspection manually while docked and display the report in a read-only panel.
- Update existing random-entry customs checks (if present) to generate the same report and log a summary, but produce no consequences.
- Classification rules must use only existing derived signals:
  - authenticity score
  - evidence flags
  - destroyed/missing docs
  - seal state (sealed/unsealed) and provenance fields when present
- Future-proof the report payload by including optional `recommended_penalty` fields, but do not act on them.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `singletons/GameState.gd`
- `scripts/Port.gd`
- `scripts/ui/*.gd`
- `scenes/ui/*.tscn`
- `singletons/Customs.gd`                # or the exact file path where `run_entry_check(system_id)` currently lives

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

- `scripts/ui/CustomsInspectionPanel.gd`
- `scenes/ui/CustomsInspectionPanel.tscn`

---

## Public API Changes
List any new or modified public methods, signals, or resources.
If none, write “None”.

- `GameState.run_customs_inspection(context: Dictionary = {}) -> Dictionary`
  - Returns a structured report dictionary (see below).
  - Must be read-only: no state mutation.
- `signal GameState.customs_inspection_completed(report: Dictionary)`
  - Emitted after `run_customs_inspection()` returns a report.

(If existing Customs code needs an entrypoint, it must call `GameState.run_customs_inspection()` and must not mutate state.)

---

## Data Model & Persistence
Required if this job adds or modifies saved state.

- New or changed saved fields:
  - None
- Migration / backward-compat expectations:
  - None
- Save/load verification requirements:
  - None

---

## Inspection Report Schema (Runtime-Only)
The report must be a Dictionary with the following minimum shape:

- `inspection_id: String`                     # stable unique id for this report instance
- `tick: int`                                 # GameState time tick at time of inspection
- `system_id: String`
- `location_id: String`                       # docked location when manual, or best-available context when entry check
- `classification: String`                    # "clean" | "suspicious" | "invalid"
- `reasons: Array[String]`                    # human-readable reasons (no per-frame spam)
- `doc_summary: Dictionary`                   # see below
- `recommended_penalty: Dictionary`           # future-proofing; may be empty in this job

`doc_summary` minimum shape:

- `num_docs_considered: int`
- `num_missing_docs: int`                     # if applicable to your current model; otherwise 0
- `num_destroyed_docs: int`
- `min_authenticity: int`
- `evidence_flags: Dictionary`                # aggregated counts or booleans:
  - `declared_quantity_modified_count: int`
  - `container_meta_modified_count: int`
  - `document_destroyed_count: int`

`recommended_penalty` (future-proofing only; MUST NOT be enforced or persisted):

- `should_issue_fine: bool`
- `suggested_amount: float`
- `issuer_org_id: String`
- `payable_at_system_id: String`
- `payable_at_location_id: String`
- `due_tick: int`

For this job, it is acceptable for `recommended_penalty` to be present but empty/defaulted (e.g., `should_issue_fine=false`).

---

## Classification Rules (Must Be Deterministic)
Rules must be deterministic given the same inputs.

Minimum required logic:

- If any considered doc is destroyed (`is_destroyed==true` or evidence flag `document_destroyed`), classification = `invalid`.
- Else if authenticity is below a tunable threshold (default suggestion: < 80) OR there are any modification flags, classification = `suspicious`.
- Else classification = `clean`.

Notes:
- “Missing docs” must be treated as at least `suspicious` if your existing model can detect them; otherwise omit and set counts to 0.
- Seal state and provenance may contribute to `reasons`, but must not introduce enforcement.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] A Customs Inspection action is available while docked at a Port and produces a report shown in a read-only UI panel.
- [ ] The inspection report includes: classification, reasons, authenticity summary, evidence flag aggregation, and doc counts.
- [ ] Running a Customs Inspection does not modify any gameplay state (no money changes, no cargo changes, no FreightDoc edits, no reputation changes, no time changes).
- [ ] Existing random-entry customs checks (if present) no longer levy fees or modify money; they produce only a log entry and/or report.
- [ ] Legacy/older FreightDocs missing container_meta fields are handled gracefully (placeholders, no crashes).

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Load a save with at least one active FreightDoc and dock at a port.
2. Trigger Customs Inspection from the Port UI.
3. Verify the CustomsInspectionPanel shows:
   - classification (clean/suspicious/invalid)
   - reasons list
   - doc counts + authenticity/evidence summary
4. Close the panel using the Port view’s normal close/back navigation behavior (no self-close).
5. Confirm via UI/Log/known values that player money, cargo, FreightDocs, rep, and time tick did not change.
6. (If the project has an entry-check flow) travel/arrive in a system until an inspection triggers and confirm:
   - no fee is charged
   - a log entry is produced describing the inspection outcome

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- No relevant FreightDocs → classification should be `suspicious` (or `invalid` if your model defines required docs) with clear reasons, and no crashes.
- Some docs are legacy (missing container_meta or provenance keys) → show placeholders and continue evaluation.
- Multiple docs with mixed authenticity → ensure summary reflects min/aggregate and reasons remain readable (no spam).

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,
architectural concerns, or future refactors.

- Removing/neutralizing fee logic changes gameplay economics temporarily; this is intentional until Issue-0030 introduces enforcement.
- Ensure Customs report generation does not accidentally trigger any FreightDoc edits or mutations.
- UI lifecycle must follow project rules (no internal close button behavior that mutates navigation state).

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
