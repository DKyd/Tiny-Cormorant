# Feature Job

## Metadata (Required)
- Issue/Task ID: ISSUE-0070
- Short Title: Level-1 Action Compliance — Required FreightDoc Types per Action
- Run Folder Name: issue-0070-action-surface-compliance
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-24

---

## Goal
Implement Level-1 action-based surface compliance checks that validate the **presence of required freight document types** for specific player actions (e.g., entering a system, selling cargo).  
This enables explainable inspections that fail when mandatory paperwork is missing, without evaluating cargo truth, quantities, or intent.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Authorities detect **missing or malformed paperwork**, not cargo plausibility or player intent.
- Action-based compliance checks occur **only at player-action boundaries** that already trigger inspections.
- Level-1 action compliance performs **no cross-document reconciliation**, quantity matching, per-commodity checks, or plausibility inference.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- This job must not implement Level 2+ inspection logic (audits, reconciliation, plausibility checks).
- This job must not introduce enforcement actions (fines, seizures, holds, penalties).
- This job must not modify smuggling mechanics or quantity-misrepresentation behavior.

---

## Context
The game already supports Level-1 surface compliance for **document structure** via required-field validation (`SURFACE_COMPLIANCE_RULES` and `validate_freight_doc_surface()` in `GameState.gd`).  
However, there is currently no validation that the **correct types of documents exist** for a given player action (e.g., border entry or cargo sale).  
The North Star explicitly defines “missing required document types for the action” as a Level-1 detection category.  
This job adds that missing primitive in a declarative, deterministic way.

---

## Declarative Action Requirements (Authoritative For This Job)
These requirements MUST be implemented exactly as written.  
They are Level-1 “paperwork existence” rules only and do not imply truth, matching, reconciliation, or plausibility.

### Actions Covered (Phase A scope)
- `ENTRY_CLEARANCE`: triggered when the player crosses into a system/jurisdiction (e.g., after travel, for high-security/core scrutiny).
- `SELL_CARGO`: triggered when the player sells cargo and submits paperwork (manifest sale).

### Rule: Minimal Paper Trail Exists
For actions that require a paper trail, at least one of the required doc types must exist in `freight_docs`:
- `purchase_order` OR `contract`

### Explicit Notes
- `bill_of_sale` is NOT required as an input document for either action; it is generated as an output of a sale.
- No per-commodity requirements are introduced by this job (no “each commodity must have a source doc”).
- No quantity checks are introduced by this job (no reconciliation or plausibility).

### Canonical Registry Shape (for implementation)
Codex MUST implement an equivalent declarative registry in `GameState.gd`:

```gdscript
const SURFACE_ACTION_REQUIREMENTS := {
  "ENTRY_CLEARANCE": {
    "required_any_of_doc_types": ["purchase_order", "contract"],
    "requires_cargo_present": true,
  },
  "SELL_CARGO": {
    "required_any_of_doc_types": ["purchase_order", "contract"],
    "requires_cargo_present": true,
  },
}
```
Proposed Approach
A short, high-level plan (3–6 bullets).
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements.

Add a declarative SURFACE_ACTION_REQUIREMENTS registry to GameState.gd (exact semantics above).

Implement validate_action_surface_compliance(action: String, context: Dictionary) -> Dictionary returning structured findings (ok, issues[]).

Integrate action compliance findings into run_customs_inspection() report payload (alongside existing surface_findings for doc schema).

Ensure the log summary remains concise (reasons array) while detailed findings remain in the report payload for future UI surfacing.

Ensure no doc mutation, no randomness, and no Level 2+ logic.

Files: Allowed to Modify (Whitelist)
Only these files may be edited.

res://singletons/GameState.gd

Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

data/**

scenes/MainGame.tscn

New Files Allowed?
 Yes (must list exact paths below)

 No

If Yes, list exact new file paths:

N/A

Public API Changes
List any new or modified public methods, signals, or resources.
If none, write “None”.

New helper: validate_action_surface_compliance(action: String, context: Dictionary) -> Dictionary

Modified/extended: run_customs_inspection(context: Dictionary = {}) must accept optional action in context and include action findings in the report payload

Data Model & Persistence
Required if this job adds or modifies saved state or introduces new required in-memory fields.

New or changed saved fields:

None

Migration / backward-compat expectations:

Not required

Save/load verification requirements:

Save/load must continue to round-trip existing freight_docs without mutation

Determinism & Stability (If Applicable)
Action compliance results must be deterministic given the same action string, cargo presence, and freight_docs.

No randomness, timing variance, or pressure logic is introduced by this job.

Inspection frequency and depth remain unchanged.

Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

 When run_customs_inspection({ "action": "ENTRY_CLEARANCE" }) runs while the ship has cargo and there are no purchase_order or contract docs, the report classifies as INVALID and includes a missing-doc-type finding.

 When selling cargo (or when run_customs_inspection({ "action": "SELL_CARGO" }) is invoked) while the ship has cargo and there are no purchase_order or contract docs, the report classifies as INVALID and includes a missing-doc-type finding.

 If ship has no cargo, actions with requires_cargo_present: true do not fail solely due to missing paperwork.

 Action compliance introduces no per-commodity requirements, no quantity checks, and no cross-document reconciliation logic.

Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

Start a new game and acquire cargo (market purchase or contract).

Using debug tools or Captain’s Quarters, destroy (or otherwise remove) all purchase_order and contract FreightDocs while leaving cargo in hold.

Trigger an inspection at an action boundary:

Option A: Travel into a system that triggers scrutiny and ensure inspection runs with action ENTRY_CLEARANCE.

Option B: Attempt to sell cargo and ensure inspection runs with action SELL_CARGO.

Verify the log shows CUSTOMS: INVALID — ... missing required document types ... (or equivalent reason), and the report payload includes structured action findings.

Confirm no enforcement actions occur.

Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

If action is missing, action compliance must not run and must not invent requirements.

If action is unknown, action compliance must return a structured finding indicating unsupported action without crashing.

If freight_docs contains non-dictionary entries, validation must skip them safely.

If cargo contains keys with non-int quantities, action compliance must treat non-positive quantities as not-cargo (fail safe).

Risks / Notes
Anything that could cause regressions, merge conflicts,
architectural concerns, or future refactors.

Care must be taken not to introduce per-commodity or quantity-based checks (Level 2+ scope creep).

Action identifiers must remain stable and explicit; do not infer action types from unrelated context.

Integrations that call run_customs_inspection() must pass action explicitly where required; do not add new triggers in this job.

If assumptions prove false, Codex must stop and report rather than inventing solutions.

Governance & Review Gates (Mandatory)
Codex must not make code changes until required preflight/review steps are complete.

Codex must present diffs for review before declaring results final.

If scope, whitelist, or non-goals are violated, Codex must stop and report the issue.

Codex Scaffolding & Output Requirements (Mandatory)
Codex must perform the following before any code changes:

Create codex/runs/issue-0070-action-surface-compliance/

Write this job verbatim to codex/runs/issue-0070-action-surface-compliance/job.md

Create codex/runs/issue-0070-action-surface-compliance/results.md if missing

Write codex/runs/ACTIVE_RUN.txt = issue-0070-action-surface-compliance

Codex must write final results only to:

codex/runs/issue-0070-action-surface-compliance/results.md

Results must include:

Summary of changes and rationale

Files changed (with brief explanation per file)

Assumptions made

Known limitations or TODOs

Logging Checklist
 All explicit player actions that succeed or fail emit a clear log entry

 All time advancement paths log a reason and tick delta

 No UI-only interactions produce log entries

 No per-frame or loop-driven spam was introduced

 Log messages are human-readable

 print() usage is debug-only or removed in favor of Log.add_entry()

 Log volume feels appropriate for a capped, recent-history log
