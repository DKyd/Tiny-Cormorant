# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0082
- Short Title: Formalize Level-2 Cross-Document Invariants
- Run Folder Name: issue-0082-formalize-level-2-cross-document-invariants
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-25

---

## Goal
Define and lock the authoritative set of Level-2 Customs audit invariants (cross-document coherence rules) and their severity semantics (CLEAN vs SUSPICIOUS vs INVALID), so Level-2 outcomes are deterministic, explainable, and stable for future phases.

---

## Invariants (Must Hold After This Job)
- Level-2 audits evaluate documentary coherence only and must not mutate cargo, credits, freight docs, or block player actions.
- Level-2 outcome classification semantics are stable and deterministic: the same document set yields the same classification and findings regardless of call site.
- Partial sales and multi-system sales from a single acquisition source remain valid as long as source quantities are not oversold and source doc integrity constraints are satisfied.

---

## Non-Goals
- Do NOT add Level-3 (mass/capacity) or any physical inspection/reconciliation logic.
- Do NOT introduce new enforcement mechanics (seizure, holds, fines), new UI panels, or new document types.

---

## Context
- `GameState.run_customs_inspection()` currently supports Level-1 surface compliance and optionally runs a Level-2 audit when `max_depth >= 2`.
- Level-2 audit (`GameState.run_level2_customs_audit`) currently checks bill-of-sale sources against purchase_order/contract documents and flags missing/invalid sources, destroyed sources, temporal contradictions, mismatched totals, and oversold sources.
- The project needs an explicit, named list of “cross-doc invariants” that define what constitutes CLEAN/SUSPICIOUS/INVALID at Level 2, including clarifying behavior for partial sales and selling the same acquired cargo across multiple systems over time.

---

## Proposed Approach
- Write an explicit invariant list (IDs + descriptions) covering Level-2 coherence rules already enforced or implied (e.g., source existence, source type validity, source not destroyed, source has commodity, sale tick ordering where applicable, source totals match sold qty, no overselling).
- Map each invariant to severity semantics:
  - INVALID: impossible or contradictory chain
  - SUSPICIOUS: incomplete/ambiguous metadata that does not contradict but reduces confidence
  - CLEAN: no invariant violations
- Update `run_level2_customs_audit` to report findings with stable invariant codes (or IDs) and ensure classification is derived solely from those findings.
- Ensure the invariant set explicitly supports partial sales and multi-system sales (source consumption accounting), without requiring new data fields.
- Keep changes minimal and localized; if any assumption is false, stop and report.

---

## Files: Allowed to Modify (Whitelist)
- `res://singletons/GameState.gd`

---

## Files: Forbidden to Modify (Blacklist)
- `data/**`
- `scenes/MainGame.tscn`

---

## New Files Allowed?
- [ ] Yes (must list exact paths below)
- [x] No

If Yes, list exact new file paths:

- 

---

## Public API Changes
If none, write “None”.

- None.

---

## Data Model & Persistence
- New or changed saved fields:
  - None.
- Migration / backward-compat expectations:
  - Existing saves must continue to load; existing freight docs must remain readable and auditable.
- Save/load verification requirements:
  - Load an existing save and confirm inspections and Level-2 audit still function and logs remain coherent.

---

## Determinism & Stability (If Applicable)
- What must be deterministic?
  - Level-2 audit findings and classification for a given set of documents.
  - Invariant evaluation ordering must not affect outcomes (only presentation order may be sorted).
- What inputs must remain stable?
  - Freight document fields already in use: doc_id, doc_type, is_destroyed/status, purchase_tick/tick, cargo_lines, sources, declared_qty/sold_qty.
- What must not introduce randomness or time-based variance?
  - No RNG; no dependence on current wall-clock time; only `time_tick` already stored in docs may be used for ordering checks.

---

## Acceptance Criteria (Must Be Testable)
- [ ] Results include `## Level-2 Cross-Doc Invariants (Phase 4.0 Locked)` with a paste-ready invariant list including: ID, rule, rationale (1 sentence), failure classification (INVALID vs SUSPICIOUS), and evidence/log reason string (exact text).
- [ ] `run_level2_customs_audit` findings contain stable, named codes corresponding to the invariant list, and classification is derived solely from those findings (no ad-hoc counting rules that bypass invariant mapping).
- [ ] A gameplay scenario where the player buys legal goods and sells them in multiple partial sales across different systems remains CLEAN at Level 2 (assuming sources are valid and not oversold).

---

## Manual Test Plan
1. Start a new game, dock at a market, buy a commodity to generate a purchase_order.
2. Travel to another system and sell half legally; then travel again and sell the remainder legally. Trigger inspections where max depth can reach 2 and confirm Level-2 remains CLEAN with no invariant violations.
3. Create an INVALID chain (e.g., destroy a source purchase_order referenced by an existing bill_of_sale, or oversell beyond source quantity if achievable) and trigger a max-depth-2 inspection; confirm Level-2 becomes INVALID and reports the expected invariant code(s).

---

## Edge Cases / Failure Modes
- Bills of sale that reference sources but have missing/empty sources arrays must be INVALID with a clear invariant code.
- Contracts without explicit tick fields must not cause INVALID solely due to missing tick metadata; at most SUSPICIOUS if the invariant list calls for it.

---

## Risks / Notes
- Risk: Tightening invariant semantics could change some existing saves from CLEAN to INVALID; the invariant list must be conservative and aligned with current gameplay rules.
- Risk: Mixed legacy fields (e.g., older docs missing tick or cargo_lines structure) may require careful classification to avoid false INVALID.
- If assumptions prove false, Codex must stop and report rather than inventing solutions.

---

## Governance & Review Gates (Mandatory)
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
