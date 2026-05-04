# Results

## Summary
- Planned Level 3 reconciliation data primitives as an advisory milestone, not executable implementation scope.
- Confirmed the safe starting point is inert data/schema support before read-only reconciliation helpers, UI surfacing, pressure effects, physical inspections, or enforcement.
- Identified existing commodity, cargo, freight document, container metadata, and customs audit structures that future jobs must account for.
- Preserved Level 2 purity: `L2INV-001` remains policy-disabled until Level 3 and must not be reintroduced into Level 2 paths.

## Evidence Reviewed
- Preflight:
  - branch `master`
  - clean working tree before scaffolding
  - `HEAD...origin/master` was `0 0` after `git fetch origin`
- Governance:
  - `codex/jobs/planning/rules.md`
  - `codex/jobs/planning/config.md`
  - `codex/CONTEXT.md`
- Recent runs:
  - `issue-0111-l2-purity-disable-cargo-snapshot`
  - `issue-0119-reconcile-inspections-smuggling-customs-roadmap`
  - `issue-0120-validate-pressure-only-customs-consequence-matrix`
  - `issue-0122-retry-pressure-only-customs-runtime-validation`
  - `issue-0123-surface-level-2-audit-details-in-inspection-ui`
- Read-only source surfaces:
  - `data/CommodityDB.gd`
  - `singletons/GameState.gd`
  - `singletons/Customs.gd`
  - `scripts/freight/FreightDocRules.gd`
  - `scripts/customs/CustomsInvariants.gd`

## Capability Definition
Level 3 reconciliation data primitives means the minimum inert data and deterministic helper foundation needed to compare documentary declarations against physical or runtime cargo facts later.

Minimum primitive set:
- commodity mass-per-unit source of truth
  - Existing shape: `CommodityDB.COMMODITIES[*].weight_per_unit`.
  - Planning note: this already exists but should be audited for naming, units, defaults, and completeness before being treated as customs evidence.
- cargo quantity snapshot shape
  - Existing shape: `GameState.cargo` as `{ commodity_id: quantity }`.
  - Planning note: future read-only helpers may duplicate this as input, but must not mutate it.
- declared cargo line shape
  - Existing shapes: freight docs and document-like records use `cargo_lines[]` with `commodity_id`, `declared_qty`, `cargo_space`, `sold_qty`, and/or `sources` depending on document type.
  - Planning note: future helpers need normalization rules before comparing document totals to runtime cargo.
- container metadata baseline
  - Existing shape: `container_meta` includes `container_id`, `seal_id`, `seal_state`, `packed_tick`, and provenance.
  - Missing primitive: no tare weight or container class/source-of-truth was found.
- ship/hull/cargo baseline capacity primitive
  - Existing shape: `cargo_capacity_weight`, `cargo_hold_level`, and `cargo_hold_capacity_bonus_per_level`.
  - Missing primitive: no explicit empty hull mass or measured gross/net mass was found.
- tolerance rules
  - Missing primitive: no reconciliation tolerance policy or rounding/unit rule was found.
  - Recommended shape: deterministic constants or data records for allowable absolute/relative variance, unit names, and unknown-data behavior.

What Level 3 primitives do not mean:
- no fines, holds, seizure, denial, forced offload, reputation effects, cargo mutation, credit mutation, document mutation, or travel blocking
- no physical inspection gameplay
- no Port Authority simulation
- no Level 2 cargo reconciliation
- no UI warnings until separate surfacing scope exists

## Dependencies and Blockers
- `CommodityDB.gd` already carries `weight_per_unit`, but the project needs a governed decision on whether that field is gameplay cargo-space weight, customs mass, or both.
- `GameState.cargo` is quantity-only and not containerized; it does not identify which freight doc, source, or container a runtime unit belongs to.
- Freight docs preserve declared cargo lines and container metadata, but not container tare weight, gross mass, net mass, or measured mass.
- `Customs.run_level_2_audit()` currently passes `GameState.cargo.duplicate(true)` into the audit context, but `CustomsInvariants.gd` policy-disables Level 2 quantity consistency until Level 3.
- Existing validation remains partly manual: startup is fixed, but there is still no deterministic non-interactive customs scenario harness.
- Data ownership is uncertain for tare weights and tolerance rules. Do not guess by spreading constants across `GameState`, `Customs`, and `data/**`.

## Candidate Job Sequence

### 1. Audit Existing Commodity Weight Semantics
- Target job type: `planning`
- Risk level: low
- Likely whitelist:
  - active run folder only, or a narrow documentation target if explicitly authorized
- Narrow goal:
  - decide whether existing `weight_per_unit` is sufficient for customs mass semantics or whether a separate customs mass field is required.
- Verification approach:
  - read `CommodityDB.gd`, cargo capacity usage, economy usage, and document cargo-line usage; record a field-ownership decision without runtime changes.
- Explicit non-goals:
  - no data edits, no reconciliation logic, no UI, no enforcement.

### 2. Add Inert Level 3 Data Primitives
- Target job type: `feature`
- Risk level: medium-high
- Likely whitelist:
  - `data/CommodityDB.gd`
  - possibly one narrow new data/helper file under `data/**` if the job explicitly permits it
  - active run files
- Narrow goal:
  - add or formalize inert primitive fields for commodity customs mass, container tare/class defaults, and tolerance policy without wiring them into customs outcomes.
- Verification approach:
  - static inspection confirms every commodity has required fields, defaults are deterministic, and no runtime inspection path reads the new primitives yet unless the job explicitly allows a read-only schema check.
- Explicit non-goals:
  - no `GameState` mutation, no customs classification changes, no Level 2 behavior changes.

### 3. Add Read-Only Primitive Accessors or Schema Validators
- Target job type: `feature`
- Risk level: medium
- Likely whitelist:
  - `data/CommodityDB.gd`
  - possibly a narrow `scripts/customs/**` helper if separated from audit classification
  - active run files
- Narrow goal:
  - expose deterministic read-only helpers for primitive lookup, missing-data reporting, and unit/tolerance normalization.
- Verification approach:
  - call helpers against known commodity/container/tolerance inputs and confirm they return dictionaries or reports only; no cargo, credits, docs, time, or pressure state changes.
- Explicit non-goals:
  - no inspection outcome integration, no pressure, no UI.

### 4. Plan or Add a Deterministic Customs Scenario Harness
- Target job type: `planning` first, then `feature` or `bugfix` only if authorized
- Risk level: medium
- Likely whitelist:
  - to be defined by a future job; likely narrow debug/test/runtime-validation files plus active run files
- Narrow goal:
  - create a reproducible way to exercise clean, suspicious, invalid, not-evaluable, and future Level 3 read-only mismatch cases.
- Verification approach:
  - run a command or manual recipe that produces known reports without production gameplay side effects.
- Explicit non-goals:
  - no production enforcement and no broad debug framework.

### 5. Add Level 3 Read-Only Reconciliation Helper
- Target job type: `feature`
- Risk level: high
- Likely whitelist:
  - `scripts/customs/**`
  - possibly `singletons/Customs.gd`
  - active run files
- Narrow goal:
  - compare normalized document totals, commodity mass, container tare/defaults, and runtime cargo snapshot as a read-only report.
- Verification approach:
  - deterministic mismatch and match scenarios produce report-only classifications or findings; confirm no fines, holds, seizure, denial, travel blocking, cargo mutation, credit mutation, document mutation, or pressure mutation.
- Explicit non-goals:
  - no UI surfacing, no pressure effect, no enforcement, no physical inspection.

### 6. Surface Level 3 Read-Only Findings
- Target job type: `feature`
- Risk level: medium-high
- Likely whitelist:
  - narrow inspection UI files
  - possibly one customs report formatter file
  - active run files
- Narrow goal:
  - display existing Level 3 read-only report details after helper behavior is already verified.
- Verification approach:
  - manual Godot UI inspection confirms display-only rendering and no state mutation.
- Explicit non-goals:
  - no new audit logic, no pressure, no enforcement.

### 7. Consider Pressure-Only Consequences From Level 3 Findings
- Target job type: `planning` before any executable job
- Risk level: high
- Likely whitelist:
  - planning run folder only at first
- Narrow goal:
  - decide whether Level 3 findings should ever influence scrutiny, and under what strict no-enforcement boundary.
- Verification approach:
  - future executable scope must separately prove pressure-only behavior and absence of enforcement.
- Explicit non-goals:
  - no physical inspection, no Port Authority simulation, no punitive actions.

## Recommended Next Job
Recommended next job: `planning` or narrow `feature`, depending on how much confidence the human wants before touching `data/**`.

Safest immediate next job:
- `planning`: Audit existing commodity weight semantics and decide whether `weight_per_unit` can serve as Level 3 customs mass.

First executable job after that:
- `feature`: Add inert Level 3 data primitives only, likely limited to commodity/customs data shape and static verification.

Reason:
- `data/**` is protected and conceptually high-risk.
- Existing weight data may already satisfy part of the primitive need, but its semantics are not yet formally owned by customs.
- Adding reconciliation helpers before resolving units, tare, and tolerance policy would force guesswork into high-risk customs code.

## Verification Strategy
- Data primitive jobs prove completeness by static table/schema inspection and deterministic missing-field reports.
- Read-only helper jobs prove no side effects by comparing `git diff`, source review, and targeted calls that return reports without mutating `GameState`.
- UI jobs prove display-only behavior by rendering existing report payloads and confirming no calls to cargo, credit, document, travel, or pressure mutation methods.
- Any future pressure-only job must explicitly test absence of fines, holds, seizure, denial, travel blocking, reputation effects, cargo mutation, credit mutation, document mutation, and forced offloads.
- Level 2 regression checks must confirm `policy_disabled_until_level3` remains the Level 2 quantity-consistency behavior until a separate Level 3 job changes only Level 3 paths.

## Assumptions
- The current `weight_per_unit` field is probably the closest existing primitive for commodity mass, but its customs semantics are not yet confirmed.
- Container tare and tolerance policy should be data-owned or helper-owned, not hidden as scattered constants.
- Runtime cargo remains quantity-based for now; introducing per-container runtime cargo identity would be a separate high-risk design decision.

## Follow-Up Governance Clarification
- On this machine, the confirmed canonical clone path is `C:\Users\akaph\OneDrive\Desktop\Ozark Interactive\Games\Tiny Cormorant`, which appears to be the Desktop path as resolved through OneDrive.
- Future governance should clarify that this OneDrive Desktop path is canonical for this machine and must not be confused with the old non-canonical `Documents\GitHub\Tiny-Cormorant` scratch clone.

## Non-Goals Preserved
- No runtime game behavior was changed.
- No runtime code, scenes, data files, documentation roadmap files, project settings, or protected governance files were modified.
- No future executable run folders were created.
- This output is advisory only until converted into a complete future `job.md` or explicit active-run instructions.
