# Feature Job

## Metadata (Required)
- Issue/Task ID: ISSUE-0071
- Short Title: Legal Sale Trigger — Customs Surface Check (Exclude Black Market)
- Run Folder Name: issue-0071-legal-sale-customs-trigger
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-24

---

## Goal
When the player sells cargo through the **legal market**, trigger a Level-1 Customs surface compliance inspection using the declarative action requirements model.  
Black market sales must remain invisible to Customs and must not trigger Customs checks.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Customs detects **paperwork inconsistencies**, not player intent or cargo truth/plausibility.
- Checks occur only at **player-action boundaries** (in this job: legal SELL action only).
- **Customs is not aware of the black market**: black market sales do not trigger Customs inspections.
- Level-1 checks do **not** perform cross-document reconciliation, plausibility checks, or enforcement actions.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- This job must not add any new inspection depth logic (Level 2+), including audits, reconciliation, or plausibility checks.
- This job must not add enforcement outcomes (fines, seizures, holds) or reputation systems.
- This job must not modify BlackMarketPanel behavior beyond ensuring it does **not** trigger Customs.
- This job must not change pricing, economy, or smuggling mechanics.

---

## Context
`GameState.run_customs_inspection(context)` now supports an optional `action` string, and `GameState.validate_action_surface_compliance(action, context)` evaluates declarative requirements in `SURFACE_ACTION_REQUIREMENTS`.

Currently, legal and black market selling both ultimately call `GameState.sell_manifest_goods(...)`, but they represent different “institutional visibility”:
- Legal sales are a paperwork submission lane and should be eligible for Customs checks.
- Black market sales are off-books; Customs should never run because of them.

This job introduces explicit action keys for legal vs black market sales and wires the legal market sell flow to pass the legal action context into Customs inspection triggering.

---

## Declarative Action Requirements (Must Be Implemented Exactly)
This job formalizes two distinct sell actions:

- `SELL_CARGO_LEGAL`
  - Requires documentation presence when cargo exists.
  - Requirement rule:
    - `required_any_of_doc_types`: `["purchase_order", "contract"]`
    - `requires_cargo_present`: `true`

- `SELL_CARGO_BLACK_MARKET`
  - Must not trigger Customs inspections.
  - No document requirements are evaluated by Customs for this action.
  - If represented in `SURFACE_ACTION_REQUIREMENTS`, it must be explicitly non-enforcing (empty requirements) OR omitted entirely.

Notes:
- `ENTRY_CLEARANCE` remains unchanged in this job.
- This job’s main concern is the **trigger + action plumbing**, not redesigning required fields.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements.

- Update `SURFACE_ACTION_REQUIREMENTS` to replace the generic `SELL_CARGO` with `SELL_CARGO_LEGAL` and (optionally) `SELL_CARGO_BLACK_MARKET` as described above.
- Wire the legal market sell flow (MarketPanel ? GameState sale call path) to trigger `GameState.run_customs_inspection({ action = "SELL_CARGO_LEGAL", ... })` at the player-action boundary.
- Ensure the black market sell flow does not call any Customs-triggering logic and does not pass a Customs action context.
- Ensure logging remains clear and non-spammy: one Customs log entry per triggered inspection.
- Keep all logic deterministic (no new randomness in this job).

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `res://singletons/GameState.gd`
- `res://scripts/ui/MarketPanel.gd`

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

- Modified constant: `SURFACE_ACTION_REQUIREMENTS` (replace `SELL_CARGO` with `SELL_CARGO_LEGAL`, and optionally add `SELL_CARGO_BLACK_MARKET` as non-enforcing/ignored by Customs)

---

## Data Model & Persistence
Required if this job adds or modifies saved state **or introduces new required in-memory fields**.

- New or changed saved fields:
  - None
- Migration / backward-compat expectations:
  - Not required (legacy compatibility out of scope)
- Save/load verification requirements:
  - None beyond “game runs and sells still function”

---

## Determinism & Stability (If Applicable)
- No new randomness is introduced.
- Inspection triggering from legal sell is deterministic relative to the existing inspection system behavior (if any randomness already exists, it must remain unchanged).
- Action requirement evaluation must be deterministic given the same docs and cargo state.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] Selling cargo through the **legal market** triggers a Customs inspection with context `action="SELL_CARGO_LEGAL"` (verify in log and inspection report fields).
- [ ] Selling cargo through the **black market** does **not** trigger Customs inspections and does not create Customs log entries.
- [ ] If the player has cargo but lacks any `purchase_order` or `contract` docs, a legal-sell-triggered inspection classifies as `INVALID` with a reason indicating missing required doc types for `SELL_CARGO_LEGAL`.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Start a new game, dock at a location with a legal market, buy any commodity, then sell it via the legal MarketPanel.
2. Verify a Customs inspection occurs (log entry) and the inspection report includes `doc_summary.action == "SELL_CARGO_LEGAL"` and `action_surface` data.
3. Travel to a location with a black market (cantina back room), buy and sell via BlackMarketPanel.
4. Verify no Customs inspection occurs and no Customs log entry is emitted from the black market sale.
5. (Negative test) In a debug session, wipe/modify freight docs to remove all `purchase_order` and `contract` docs while keeping cargo present, then sell via legal market and confirm inspection becomes `INVALID` with missing required doc types.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Player sells 0 cargo (should not trigger sell flow / should be blocked earlier; no Customs spam).
- Player has cargo present but no qualifying docs: inspection must be `INVALID` with explainable reason.
- Unknown action key: must not crash; report unsupported action only if used.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Ensure the legal vs black market distinction is enforced at the trigger source (MarketPanel), not by “guessing” market_kind inside Customs.
- Do not accidentally route BlackMarketPanel through the same trigger path.
- If assumptions prove false, Codex must stop and report rather than inventing solutions.

---

## Governance & Review Gates (Mandatory)
- Codex must not make code changes until required preflight/review steps are complete.
- Codex must present diffs for review before declaring results final.
- If scope, whitelist, or non-goals are violated, Codex must stop and report the issue.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0071-legal-sale-customs-trigger/`
2) Write this job verbatim to `codex/runs/issue-0071-legal-sale-customs-trigger/job.md`
3) Create `codex/runs/issue-0071-legal-sale-customs-trigger/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0071-legal-sale-customs-trigger`

Codex must write final results only to:
- `codex/runs/issue-0071-legal-sale-customs-trigger/results.md`

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
