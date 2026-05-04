# Results

## Summary
- Planned the remaining inert Level 3 primitives: container class/tare data and deterministic reconciliation tolerance policy.
- Recommendation: create a future dedicated data surface for customs reconciliation primitives rather than expanding `CommodityDB.gd` beyond commodity-owned mass data.
- Kept all findings advisory; no runtime, data, scene, documentation, project setting, or governance files were modified.
- Preserved Level 2 quantity/cargo policy-disabled behavior and the no-enforcement/no-physical-inspection boundary.

## Evidence Reviewed
- Recent planning and implementation runs:
  - `issue-0124-plan-level-3-reconciliation-data-primitives`
  - `issue-0125-audit-existing-commodity-weight-semantics`
  - `issue-0126-add-inert-customs-mass-primitive`
- Read-only source surfaces:
  - `data/CommodityDB.gd`
  - `singletons/GameState.gd`
  - `scripts/freight/FreightDocRules.gd`
  - `scripts/customs/CustomsInvariants.gd`
  - relevant UI references only to understand existing container metadata shape

## Current Structures
- `CommodityDB.gd` now contains inert `customs_mass_per_unit` for all commodities.
- `GameState._build_container_meta(...)` creates document container metadata with:
  - `container_id`
  - `seal_id`
  - `seal_state`
  - `notes`
  - `packed_tick`
  - `provenance.source/system_id/location_id`
- `FreightDocRules.gd` requires only `container_id` and `seal_state` for container metadata, plus `seal_id` when sealed for contract docs.
- `CustomsInvariants.gd` Level 2 container consistency checks only cross-document identity/seal consistency.
- Cargo/document quantities remain quantity based: `declared_qty`, `quantity`, `sold_qty`, `cargo_space`, and `sources`.
- No source of truth was found for:
  - container class
  - tare mass
  - max recommended cargo mass
  - gross/net/measured mass
  - rounding rules
  - absolute/relative tolerance policy
  - unknown-data behavior for Level 3 reconciliation

## Primitive Semantics

### Container Class
Container class should be an inert data key describing a reusable container archetype, not the runtime container instance itself.

Recommended minimum fields:
- `class_id`: stable identifier such as `standard_freight_crate`
- `display_name`: human-readable label
- `tare_mass`: numeric, non-negative customs mass for empty container
- `max_cargo_mass`: optional numeric, non-negative planning/validation cap
- `notes`: optional design/debug text

Runtime `container_meta.container_id` should remain an instance identifier. A future job may add `container_class_id` to generated `container_meta`, but that should be separate from defining the inert class table.

### Tolerance Policy
Tolerance policy should define deterministic comparison rules for future read-only reconciliation, not pressure or enforcement.

Recommended minimum fields:
- `policy_id`: stable identifier such as `level3_default`
- `absolute_mass_tolerance`: numeric, non-negative
- `relative_mass_tolerance`: numeric, non-negative fraction
- `rounding_decimals`: non-negative integer
- `missing_data_result`: explicit value such as `not_evaluable`
- `unknown_container_class_result`: explicit value such as `not_evaluable`
- `unknown_commodity_mass_result`: explicit value such as `not_evaluable`

Planning recommendation:
- A future helper should calculate an allowed variance as the greater of absolute tolerance and relative tolerance times expected mass.
- Missing data should produce `not_evaluable`, not suspicious/invalid, until a later complete job explicitly changes that policy.

## Data Ownership Recommendation
Use a new dedicated future data file rather than `CommodityDB.gd`.

Recommended future path:
- `data/CustomsReconciliationDB.gd`

Rationale:
- `CommodityDB.gd` should remain commodity-owned. It now owns `customs_mass_per_unit`, but container classes and tolerance policy are customs reconciliation concepts, not commodity properties.
- `GameState.gd` should not own static primitive definitions.
- `scripts/customs/**` should not hide static data constants inside reconciliation logic.
- A dedicated data surface makes future static verification and whitelist review cleaner.

Recommended future top-level constants:
- `CONTAINER_CLASSES`
- `RECONCILIATION_TOLERANCE_POLICIES`
- `DEFAULT_CONTAINER_CLASS_ID`
- `DEFAULT_TOLERANCE_POLICY_ID`

## Missing-Data Behavior
- Missing container class table entry: `not_evaluable`.
- Missing `container_class_id` on runtime container metadata: `not_evaluable` until a future job adds defaulting explicitly.
- Missing `customs_mass_per_unit`: `not_evaluable`.
- Missing tolerance policy: hard validation failure for the helper, but no gameplay consequence.
- Negative or non-numeric primitive data: static validation failure; do not coerce silently.
- Unknown runtime cargo or document quantity shape: `not_evaluable`.

## Candidate Job Sequence

### 1. Add Inert Customs Reconciliation Data Surface
- Target job type: `feature`
- Risk level: medium-high
- Likely whitelist:
  - `data/CustomsReconciliationDB.gd` (new file)
  - `codex/runs/ACTIVE_RUN.txt`
  - future active run folder files
- New Files Allowed requirement:
  - `data/CustomsReconciliationDB.gd`
- Narrow goal:
  - define inert container class/tare table and default tolerance policy table.
- Verification approach:
  - static inspection confirms deterministic numeric non-negative tare/tolerance values, stable IDs, and no references from runtime systems.
- Explicit non-goals:
  - no helper methods unless purely local/static, no `GameState`, no customs audit integration, no UI, no pressure, no enforcement.

### 2. Add Read-Only Primitive Validation/Lookup
- Target job type: `feature`
- Risk level: medium
- Likely whitelist:
  - `data/CustomsReconciliationDB.gd`
  - possibly one narrow `scripts/customs/**` helper if explicitly separated from audit outcomes
  - active run files
- Narrow goal:
  - expose deterministic lookup and missing-data reports for container class/tare and tolerance policy.
- Verification approach:
  - call lookup/validation against known IDs and unknown IDs; confirm report-only results and no mutation of cargo, docs, credits, time, pressure, or saves.
- Explicit non-goals:
  - no reconciliation comparison, no UI surfacing, no Level 2 changes.

### 3. Add Runtime Container Class Attachment
- Target job type: `feature`
- Risk level: medium-high
- Likely whitelist:
  - `singletons/GameState.gd`
  - possibly `scripts/freight/FreightDocRules.gd`
  - active run files
- Narrow goal:
  - add inert `container_class_id` to newly generated `container_meta` and validate it as optional/required according to the future data policy.
- Verification approach:
  - generated freight docs include deterministic class IDs; existing document behavior and Level 2 outcomes remain unchanged except surface validation if explicitly scoped.
- Explicit non-goals:
  - no mass comparison, no pressure, no enforcement.

### 4. Add Level 3 Read-Only Reconciliation Helper
- Target job type: `feature`
- Risk level: high
- Likely whitelist:
  - `scripts/customs/**`
  - `data/CustomsReconciliationDB.gd`
  - possibly `data/CommodityDB.gd`
  - possibly `singletons/Customs.gd`
  - active run files
- Narrow goal:
  - calculate expected documentary mass from quantities, `customs_mass_per_unit`, container tare, and tolerance policy as report-only Level 3 findings.
- Verification approach:
  - deterministic match, mismatch, and missing-data cases return reports only; prove no cargo, credits, docs, pressure, travel, reputation, or enforcement mutation.
- Explicit non-goals:
  - no UI, no pressure, no physical inspection, no enforcement.

### 5. Surface Read-Only Level 3 Findings
- Target job type: `feature`
- Risk level: medium-high
- Likely whitelist:
  - narrow inspection UI/report formatting files
  - active run files
- Narrow goal:
  - display already-computed Level 3 read-only report output.
- Verification approach:
  - UI renders existing payload only and does not invoke reconciliation or mutate state.
- Explicit non-goals:
  - no new audit rules, no pressure, no enforcement.

## Recommended Next Job
Recommended next executable job:
- Target job type: `feature`
- Risk level: medium-high
- Likely whitelist:
  - `data/CustomsReconciliationDB.gd`
  - `codex/runs/ACTIVE_RUN.txt`
  - future active run folder files
- New files allowed:
  - `data/CustomsReconciliationDB.gd`
- Narrow goal:
  - add inert `CONTAINER_CLASSES` and `RECONCILIATION_TOLERANCE_POLICIES` data only.
- Verification approach:
  - static checks confirm the file exists, IDs are stable, numeric values are non-negative, default IDs resolve, and `rg` finds no runtime consumers outside the new data file and active run records.

No additional planning job is required before that narrow data job, unless the human wants to choose exact names/values before implementation.

## Godot Signal 11 Note
- `issue-0126` reported a Godot 4.6.1 headless engine signal 11 during smoke verification.
- This does not affect the current data-ownership planning conclusions because this job is read-only planning and does not depend on runtime execution.
- Future executable jobs should continue to record whether Godot smoke checks are possible, but should not broaden scope to debug the engine crash unless explicitly authorized.

## Verification Strategy for Future Jobs
- Data-only jobs:
  - prove completeness with static count/schema checks
  - prove inertness with `rg` showing no runtime consumers
- Lookup/validation jobs:
  - prove deterministic output for known, unknown, missing, malformed, and negative data cases
  - prove no mutation by source review and targeted calls
- Reconciliation helper jobs:
  - prove no Level 2 behavior changes
  - prove all mismatch/missing cases are report-only
  - explicitly check absence of fines, holds, seizures, cargo denial, travel blocking, reputation effects, forced offloads, cargo mutation, credit mutation, document mutation, and pressure mutation

## Follow-Up Governance Note
- On this machine, the confirmed canonical clone path is `C:\Users\akaph\OneDrive\Desktop\Ozark Interactive\Games\Tiny Cormorant`, which appears to be the Desktop path as resolved through OneDrive.
- This remains a governance clarification follow-up only; no governance files were modified in this planning job.

## Non-Goals Preserved
- No runtime game behavior changed.
- `data/**` was not modified.
- No container tare data, tolerance data, helper, validator, reconciliation logic, UI surfacing, pressure effect, or enforcement was implemented.
- Existing `customs_mass_per_unit` remains inert and unwired.
- Level 2 quantity/cargo reconciliation remains policy-disabled.
- This output is advisory only until converted into a complete future `job.md` or explicit active-run instructions.
