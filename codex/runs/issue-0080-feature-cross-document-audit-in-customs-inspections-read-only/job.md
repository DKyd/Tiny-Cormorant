# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0080
- Short Title: Level-2 cross-document audit in Customs inspections (read-only)
- Run Folder Name: issue-0080-feature-cross-document-audit-in-customs-inspections-read-only
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-01-25

---

## Goal
Add a Level-2 “document chain coherence” audit that can run during Customs inspections when max inspection depth permits it. The audit must evaluate cross-document consistency (purchase orders/contracts ↔ bills of sale) and emit clear inspection logs and pressure escalation on INVALID outcomes, without blocking actions or mutating cargo/credits/freight docs.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- No inspection outcome (Level 1 or Level 2) may mutate cargo, player credits, or freight documents, and no inspection may block player actions.
- Randomness may affect whether an inspection occurs, but must never affect audit/detection logic; audit results are deterministic from current state.
- Level-2 audits must not reclassify or override Level-1 outcomes; Level 1 remains the surface compliance classification, Level 2 is an additional audit section.

---

## Non-Goals
Explicitly list what this job must NOT do.
These are hard scope boundaries.

- No new enforcement mechanics: no fines, holds, seizures, denial of sale/travel, or reputation effects.
- No Level-3 reconciliation (mass/capacity/tare), no Port Authority simulation, no container opening/physical checks, and no new inspection triggers or UI panels.

---

## Context
Describe relevant existing systems, scenes, or scripts.
Include what already exists and what is missing.
Do not propose solutions here.

- `GameState.run_customs_inspection(context)` currently performs Level-1 “surface compliance” evaluation and emits an inspection report with `classification` and `reasons`, logs a formatted entry, and emits `customs_inspection_completed`.
- Phase 3 introduced a runtime-only pressure escalation helper: `GameState.apply_customs_pressure_increase(location_id, reason)` which mutates the location’s `delta_influences` for government influence and logs increased scrutiny.
- The freight docs model includes doc types such as `purchase_order`, `contract`, and `bill_of_sale`, with required fields defined in `SURFACE_COMPLIANCE_RULES` and action-scoped requirements in `SURFACE_ACTION_REQUIREMENTS`.
- Bills of Sale include `cargo_lines[*].sources[*]` pointing at source document ids and quantities (doc chain lineage). Sales already fail early if there are insufficient sources when constructing a sale.
- What is missing: a Level-2 audit pass that inspects the document chain across multiple docs (including aggregate behaviors like overselling a source doc) and reports coherence findings without changing gameplay outcomes.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements.

- Add a pure, deterministic Level-2 audit helper that evaluates cross-document coherence using existing `freight_docs` state and returns a structured result `{ ok, classification, reasons, findings }`.
- Integrate Level-2 audit into `run_customs_inspection` as an additional section in the returned `report`, executed only when the inspection context allows depth ≥ 2 (for now: use a context flag or computed max depth provided by the caller; fail closed when not provided).
- Ensure the audit checks core invariants (e.g., sources exist and are valid, sold quantities do not exceed sourced/acquired quantities per source doc per commodity, temporal ordering where applicable, and destroyed lifecycle contradictions).
- Emit richer logs by including a short Level-2 summary line in the inspection log entry when Level-2 audit was run (without creating additional spam logs).
- Apply pressure escalation on Level-2 INVALID outcomes using the existing `apply_customs_pressure_increase(location_id, "level2_invalid")`.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `res://singletons/GameState.gd`
- `res://singletons/Customs.gd`

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

- (none)

---

## Public API Changes
List any new or modified public methods, signals, or resources.
If none, write “None”.

- Add: `GameState.run_level2_customs_audit(context: Dictionary = {}) -> Dictionary` (name may vary but must be explicit “level2” and “audit”)
- Modify: `GameState.run_customs_inspection(context: Dictionary = {}) -> Dictionary` (adds `level2_audit` section to the returned report dictionary)
- Modify (if needed): `Customs.gd` to pass a stable “max_depth” into inspection contexts for Level-2-capable jurisdictions (no new triggers)

---

## Data Model & Persistence
Required if this job adds or modifies saved state **or introduces new required in-memory fields**. ⬅️ NEW

- New or changed saved fields:
  - None (Level-2 audit is computed at runtime; no new persistent fields)
- Migration / backward-compat expectations:
  - Must tolerate older saves where docs lack some optional fields (e.g., missing `tick` on older doc variants); audit should fail gracefully and classify as SUSPICIOUS or INVALID with explainable reasons as appropriate.
- Save/load verification requirements:
  - Verify load → run inspection → audit still functions without requiring new saved keys; no crashes on older docs.

---

## Determinism & Stability (If Applicable) ⬅️ NEW
- What must be deterministic?
  - The Level-2 audit classification and findings must be deterministic given current `freight_docs` and `cargo` state; no RNG usage inside audit.
- What inputs must remain stable?
  - `freight_docs` contents (doc ids, doc types, cargo_lines, sources, lifecycle flags) and `time_tick` when used for ordering checks.
- What must not introduce randomness or time-based variance?
  - No dependence on wall-clock time, OS time, or global RNG. Any ordering over arrays must be stable (e.g., sort by doc_id or stable iteration).

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] When a Customs inspection runs with max depth < 2 (or missing depth context), the report contains no `level2_audit` (or contains it in a fail-closed “skipped” state), and existing Level-1 behavior/logs remain unchanged.
- [ ] When a Customs inspection runs with max depth ≥ 2, the report includes a `level2_audit` dictionary with `classification` in {`clean`, `suspicious`, `invalid`} and a non-empty `reasons` array when classification != `clean`.
- [ ] A Level-2 INVALID result increases customs pressure via `apply_customs_pressure_increase(location_id, "level2_invalid")`, and no inspection outcome mutates cargo, credits, or freight docs.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Load an existing save or start a new game, dock at a location with a market, buy legal goods to generate purchase orders.
2. Sell some of the goods legally to generate a bill of sale with sources; trigger a legal sale inspection. Confirm logs and that cargo/credits behave normally.
3. Force a Level-2-capable inspection context (per Customs.gd gating added in this job) and repeat a sale/entry/departure inspection; confirm `level2_audit` appears in the inspection report (use existing debug/log output) and the formatted Customs log includes a Level-2 summary line.
4. Create a deliberate paper trail contradiction (e.g., destroy a source purchase order that is referenced by an existing bill of sale; or craft an oversell scenario if achievable via gameplay/tools) and trigger a Level-2 inspection; confirm Level-2 becomes INVALID, pressure increases, and no action is blocked.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Missing or malformed `sources` entries in a bill of sale (audit should classify invalid with a clear reason, not crash).
- Older/legacy docs missing optional fields like `tick` or missing `cargo_lines` subfields; audit must handle defensively and remain deterministic.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,
architectural concerns, or future refactors.

- Current game flow may make it difficult to naturally create “oversell” contradictions because sale construction already requires sufficient sources; Level-2 INVALID cases may primarily come from document destruction or tampering paths.
- `Customs.gd` may not currently compute or pass “max depth” by jurisdiction; if that information is not derivable within whitelist, Codex must stop and report with options rather than inventing a depth system.
- If assumptions prove false, Codex must stop and report rather than inventing solutions.

---

## Governance & Review Gates (Mandatory) ⬅️ NEW
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
