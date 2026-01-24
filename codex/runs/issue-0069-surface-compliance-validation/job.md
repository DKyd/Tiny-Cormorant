# Feature Job

## Metadata (Required)
- Issue/Task ID: ISSUE-0069
- Short Title: Surface Compliance – Required FreightDoc Fields & Validation
- Run Folder Name: issue-0069-surface-compliance-validation
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-24

---

## Goal
Introduce a formal, enforceable definition of required freight document fields and a Level-1 surface compliance validator.  
This enables explainable inspections that detect missing or malformed paperwork without evaluating cargo truth, intent, or plausibility.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Authorities detect **inconsistencies in paperwork**, not player intent or cargo truth.
- Inspections occur **only at player-action boundaries**.
- Level-1 checks do **not** perform cross-document reconciliation, plausibility checks, or enforcement actions.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- This job must not implement Level 2+ inspection logic (audits, reconciliation, plausibility).
- This job must not introduce enforcement actions (fines, seizures, holds, penalties).
- This job must not modify smuggling mechanics or quantity-misrepresentation behavior.

---

## Context
Freight documents are currently stored and managed in `GameState.gd` as dictionaries within `freight_docs`.  
The game already generates Contract, Purchase Order, and Bill of Sale documents and tracks edit events as evidence.  

However, there is no centralized definition of which fields are required for a document to be considered minimally valid at inspection time, allowing malformed or incomplete docs to exist undetected.  

This job introduces the formal primitives required to support **Level-1 Surface Compliance checks** described in the North Star.

---

## Required FreightDoc Fields (Level 1 — Declarative, Normative)

This section defines the **authoritative required fields** for Level-1 Surface Compliance.  
Only presence, basic structure, and obvious malformed values are validated here.

No cross-document checks, reconciliation, plausibility, or truth inference is permitted.

### General Rules (Apply to All FreightDocs)

- `doc_id` must exist and be a non-empty string.
- `doc_type` must exist and be a supported value.
- `status` must exist.
- Arrays listed as required must be present and non-empty.
- Numeric quantities must be non-negative unless otherwise specified.
- Validation must not mutate document data.

---

### FreightDoc: `contract`

**Required top-level fields**
- `doc_id`
- `doc_type` = `"contract"`
- `contract_id`
- `status`
- `origin_system_id`
- `destination_system_id`
- `cargo_lines`
- `container_meta`

**Required `cargo_lines[]` fields**
- `commodity_id`
- `declared_qty`

**Required `container_meta` fields**
- `container_id`
- `seal_state`
- If `seal_state == "sealed"` ? `seal_id` is required

---

### FreightDoc: `purchase_order`

**Required top-level fields**
- `doc_id`
- `doc_type` = `"purchase_order"`
- `status`
- `commodity_id`
- `quantity`
- `unit_price`
- `total_cost`
- `purchase_tick`
- `purchase_system_id`
- `purchase_location_id`
- `container_meta`
- `cargo_lines`

**Required `cargo_lines[]` fields**
- `commodity_id`
- `declared_qty`

**Required `container_meta` fields**
- `container_id`
- `seal_state`

---

### FreightDoc: `bill_of_sale`

**Required top-level fields**
- `doc_id`
- `doc_type` = `"bill_of_sale"`
- `status`
- `market_kind`
- `system_id`
- `location_id`
- `tick`
- `cargo_lines`
- `container_meta`

**Required `cargo_lines[]` fields**
- `commodity_id`
- `sold_qty`
- `unit_price`
- `total_price`
- `sources`

**Required `sources[]` fields**
- `doc_id`
- `qty`

**Required `container_meta` fields**
- `container_id`
- `seal_state`

---

### Unsupported or Unknown `doc_type`

- Any FreightDoc with an unknown or unsupported `doc_type` must be reported as **surface invalid**.
- Validation must fail gracefully and produce explainable findings.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements.

- Define a canonical registry of required fields per FreightDoc `doc_type`, matching the declarative rules above.
- Implement a surface-compliance validator that checks only for missing or obviously malformed required fields.
- Return structured, explainable findings rather than scores or pass/fail booleans.
- Invoke validation during inspection flows and (in debug contexts) immediately after document creation.
- Ensure validation logic performs **no cross-doc comparisons** and **no plausibility inference**.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `res://singletons/GameState.gd`

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/MainGame.tscn`

---

## New Files Allowed?
- [ ] Yes (must list exact paths below)
- [x] No

If Yes, list exact new file paths:

- N/A

---

## Public API Changes
List any new or modified public methods, signals, or resources.  
If none, write “None”.

- New helper: `validate_freight_doc_surface(doc: Dictionary) -> Dictionary`
- New helper: `validate_freight_docs_for_action(context: Dictionary) -> Array`

---

## Data Model & Persistence
Required if this job adds or modifies saved state **or introduces new required in-memory fields**.

- New or changed saved fields:
  - None
- Migration / backward-compat expectations:
  - Not required (legacy compatibility explicitly out of scope)
- Save/load verification requirements:
  - Save/load must continue to round-trip existing

---

## Determinism & Stability (If Applicable) ?? NEW
- What must be deterministic?
- What inputs must remain stable?
- What must not introduce randomness or time-based variance?

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ]
- [ ]
- [ ]

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1.
2.
3.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- 
- 

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- 
- 
- If assumptions prove false, Codex must stop and report rather than inventing solutions. ?? NEW

---

## Governance & Review Gates (Mandatory) ?? NEW
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
