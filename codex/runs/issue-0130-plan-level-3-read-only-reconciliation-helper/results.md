# Results

## Summary
- Planned the first Level 3 read-only reconciliation helper as an advisory contract only.
- Recommended a new future helper file, `scripts/customs/CustomsLevel3Reconciliation.gd`, owned separately from existing Level 1 and Level 2 audit code.
- Defined a stable input context, report payload shape, statuses, missing-data behavior, deterministic ordering, and tolerance semantics for a future executable job.
- Preserved all boundaries: no enforcement, no physical inspection gameplay, no pressure effects, no UI surfacing, and no Level 2 quantity/cargo reconciliation.
- Recorded the confirmed OneDrive Desktop path discrepancy as a governance clarification follow-up only.

## Evidence Reviewed
- Preflight:
  - branch: `master`
  - `git status --short`: clean before scaffolding
  - HEAD before this job: `eea34e7 issue-0129: Add read-only reconciliation primitive accessors`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`: `issue-0129-add-read-only-reconciliation-primitive-accessors`
  - `git fetch origin`: completed
  - `git status -sb`: `## master...origin/master`
- Prior run results:
  - `issue-0124-plan-level-3-reconciliation-data-primitives`
  - `issue-0125-audit-existing-commodity-weight-semantics`
  - `issue-0126-add-inert-customs-mass-primitive`
  - `issue-0127-plan-container-tare-and-tolerance-primitives`
  - `issue-0128-add-inert-customs-reconciliation-data-surface`
  - `issue-0129-add-read-only-reconciliation-primitive-accessors`
- Read-only source surfaces:
  - `data/CommodityDB.gd`
  - `data/CustomsReconciliationDB.gd`
  - `singletons/Customs.gd`
  - `singletons/GameState.gd`
  - `scripts/customs/CustomsLevel1Audit.gd`
  - `scripts/customs/CustomsLevel2Audit.gd`
  - `scripts/customs/CustomsInvariants.gd`
  - `scripts/customs/CustomsReportFormatter.gd`
  - `scripts/freight/FreightDocRules.gd`

## Capability Definition
The first Level 3 read-only reconciliation helper should calculate a deterministic report comparing declaration-like documentary cargo totals against a runtime cargo quantity snapshot, with optional expected customs mass calculations using inert Level 3 primitives.

It should do:
- normalize declaration-like docs into per-commodity declared quantities
- normalize runtime cargo snapshot into per-commodity actual quantities
- look up `customs_mass_per_unit` for each comparable commodity
- resolve tolerance policy from `CustomsReconciliationDB`
- optionally resolve container class/tare if the input context contains usable container class data
- compare declared quantity/mass against runtime quantity/mass and return report-only checks/findings
- return explicit `not_evaluable` checks when required data is missing or malformed
- duplicate all dictionary/array inputs before reading them
- sort all output deterministically

It should not do:
- no mutation of `GameState`, freight docs, cargo, credits, time, pressure, logs, save data, UI, or travel state
- no fines, seizures, holds, cargo denial, reputation effects, forced offloads, physical inspections, or Port Authority simulation
- no calls from `run_customs_inspection()` or any live gameplay path in the first helper implementation
- no Level 2 policy change; `L2INV-001` must remain `policy_disabled_until_level3`
- no UI formatting or pressure consequence logic

## Helper Ownership Recommendation
Recommended future owner:
- new file: `scripts/customs/CustomsLevel3Reconciliation.gd`
- recommended class name: `CustomsLevel3Reconciliation`
- recommended public entry point: `static func build_level3_reconciliation_report(ctx: Dictionary) -> Dictionary`

Reason:
- Level 3 behavior is behavior-adjacent and should not be hidden inside `CustomsInvariants.gd`, which currently owns Level 2 invariants and intentionally policy-disables runtime cargo reconciliation.
- `Customs.gd` should remain orchestration/integration, not the first owner of comparison semantics.
- `GameState.gd` should not own reconciliation math or static primitive policy.
- `data/**` should keep inert data/accessors, not report-building logic.

The first executable helper job should allow this new helper file and should avoid touching `singletons/Customs.gd` unless the job explicitly scopes a read-only wrapper later.

## Proposed Input Context
Future helper input should be a plain dictionary, duplicated at entry:

```gdscript
{
	"docs": Dictionary,                  # docs keyed by doc_id, ideally already normalized like Level 2
	"cargo": Dictionary,                 # runtime cargo snapshot: { commodity_id: quantity }
	"action": String,                    # optional diagnostic only
	"system_id": String,                 # optional diagnostic only
	"location_id": String,               # optional diagnostic only
	"tick": int,                         # optional diagnostic only
	"tolerance_policy_id": String,        # optional; default may be CustomsReconciliationDB.DEFAULT_TOLERANCE_POLICY_ID
	"default_container_class_id": String, # optional; default may be CustomsReconciliationDB.DEFAULT_CONTAINER_CLASS_ID
	"container_class_by_doc_id": Dictionary, # optional explicit override: { doc_id: class_id }
}
```

Required source data for an evaluable quantity/mass comparison:
- declaration-like cargo lines from `purchase_order`, `contract`, `declaration`, `freightdoc`, `freight_doc`, or `freight_docs`
- runtime cargo snapshot `{ commodity_id: quantity }`
- `CommodityDB.get_customs_mass_per_unit(commodity_id, -1.0)`
- tolerance policy from `CustomsReconciliationDB.get_tolerance_policy(...)` or default policy

Required source data for an evaluable container/tare check:
- usable container metadata with stable `container_id`
- resolvable container class ID, from `container_meta.container_class_id`, `container_class_by_doc_id`, or an explicitly allowed default policy
- container class/tare data from `CustomsReconciliationDB`

Current blocker:
- `GameState._build_container_meta(...)` does not currently add `container_class_id`, so container/tare comparison should be `not_evaluable` unless a future job either supplies an explicit context override or adds inert runtime container class attachment.

## Proposed Output Payload
The helper should return a report dictionary and nothing else:

```gdscript
{
	"schema_version": 1,
	"level": 3,
	"kind": "read_only_reconciliation",
	"classification": "clean|suspicious|not_evaluable",
	"status": "pass|fail|not_evaluable",
	"policy_id": "level3_default",
	"summary": String,
	"checks": Array[Dictionary],
	"findings": Array[Dictionary],
	"totals": {
		"declared_qty_by_commodity": Dictionary,
		"runtime_qty_by_commodity": Dictionary,
		"declared_mass_by_commodity": Dictionary,
		"runtime_mass_by_commodity": Dictionary,
		"declared_mass_total": float,
		"runtime_mass_total": float,
		"delta_mass_total": float,
		"allowed_delta_mass": float,
	},
	"not_evaluable": Array[Dictionary],
	"context_echo": {
		"action": String,
		"system_id": String,
		"location_id": String,
		"tick": int,
	},
}
```

Recommended check fields:
- `check_id`: stable ID such as `L3REC-001`
- `status`: `pass`, `fail`, or `not_evaluable`
- `severity`: `none` or `suspicious`; do not use `invalid` in the first helper unless a future job explicitly authorizes it
- `message`: deterministic human-readable summary
- `details`: duplicated dictionary with reason, missing inputs, doc IDs, commodity IDs, quantities, masses, tolerance, and deltas

Recommended finding fields:
- `code`: stable ID such as `L3F-001`
- `status`: `fail` or `not_evaluable`
- `severity`: `suspicious` or `none`
- `reason`: stable machine-readable reason
- `message`: deterministic human-readable summary
- `details`: duplicated dictionary

## Statuses and Classification
Recommended statuses:
- `pass`: all required comparable inputs exist and all compared deltas are within tolerance
- `fail`: comparable inputs exist and one or more deltas exceed tolerance
- `not_evaluable`: required inputs are missing, malformed, unknown, or explicitly policy-disabled

Recommended report classification:
- `clean`: all evaluable checks pass and no suspicious findings exist
- `suspicious`: one or more evaluable Level 3 checks fail
- `not_evaluable`: no required comparison can be evaluated

Do not return `invalid` from the first helper. Existing Level 2 audit code can classify invalid documents, but the first Level 3 helper should stay report-only and avoid importing enforcement-like severity until a later governed job explicitly changes that policy.

## Missing-Data Behavior
Missing or malformed data must become explicit report output, not implicit failure and not a gameplay consequence.

Recommended `not_evaluable` reasons:
- `missing_docs_snapshot`
- `missing_runtime_cargo_snapshot`
- `missing_declaration_docs`
- `missing_declaration_quantities`
- `unknown_commodity_id`
- `unknown_commodity_mass`
- `missing_tolerance_policy`
- `malformed_tolerance_policy`
- `missing_container_meta`
- `missing_container_class_id`
- `unknown_container_class`
- `missing_container_tare`
- `container_tare_not_supported_without_container_class`

Policy:
- Unknown commodity mass returns `not_evaluable`, not suspicious.
- Missing runtime cargo snapshot returns `not_evaluable`, not suspicious.
- Missing container class/tare returns `not_evaluable` for container/tare checks, while commodity quantity/mass checks may still evaluate if their own inputs are complete.
- Negative or non-numeric primitive values should be treated as malformed and reported as `not_evaluable`.
- Empty helper output must be impossible; even total missing context should return a structured report with `not_evaluable` checks.

## Deterministic Comparison Rules
Normalization:
- Duplicate `ctx` deeply at entry.
- Extract docs only from `ctx.docs` if it is a dictionary.
- Normalize doc IDs as non-empty strings.
- Sort doc IDs lexicographically before processing.
- Include declaration-like doc types: `declaration`, `purchase_order`, `contract`, `freightdoc`, `freight_doc`, `freight_docs`.
- Prefer `cargo_lines[]` when present.
- For declaration-like lines, use `declared_qty`, falling back to `quantity`.
- Ignore non-positive quantities for totals, but report malformed or non-positive lines in `not_evaluable` details when they prevent evaluation.
- Normalize cargo snapshot keys lexicographically and quantities to non-negative ints.

Quantity comparison:
- Build `declared_qty_by_commodity`.
- Build `runtime_qty_by_commodity`.
- Compare the union of commodity IDs from both maps.
- A positive declared quantity with missing/zero runtime quantity is an evaluable mismatch if runtime cargo snapshot exists.
- A positive runtime quantity with no declaration is an evaluable mismatch if declaration docs exist.

Mass comparison:
- For each comparable commodity, multiply quantity by `customs_mass_per_unit`.
- If any commodity in the comparison union lacks a valid customs mass, mark that commodity check `not_evaluable`.
- Compute total declared/runtime mass only from fully evaluable commodity rows.
- Do not silently drop unknown commodity rows from aggregate status; include them in `not_evaluable`.

Tolerance:
- Resolve policy from `tolerance_policy_id` or default policy.
- Allowed mass delta should be `max(absolute_mass_tolerance, expected_mass * relative_mass_tolerance)`.
- Expected mass should be declared mass for documentary-vs-runtime comparison.
- Apply `rounding_decimals` only after calculating raw values; include raw and rounded values in details if useful.
- Compare using `abs(runtime_mass - declared_mass) <= allowed_delta_mass`.

Ordering:
- Sort checks by `check_id`.
- Sort findings by `severity`, then `code`, then `commodity_id`, then `doc_id`, then `reason`.
- Sort `not_evaluable` entries by `reason`, then `commodity_id`, then `doc_id`, then `path`.
- Sort dictionary-derived output keys before converting to arrays.

## Dependencies and Blockers
Ready dependencies:
- `data/CommodityDB.gd` has inert `customs_mass_per_unit` for all commodities.
- `data/CommodityDB.gd` has `get_customs_mass_per_unit(...)`.
- `data/CustomsReconciliationDB.gd` has inert container classes, tolerance policy, default IDs, and read-only accessors.
- `Customs.run_level_2_audit(...)` already builds normalized docs and duplicates cargo when needed, but the future Level 3 helper should not be wired there in its first job.
- `GameState.cargo` is the runtime quantity snapshot shape.

Blockers or limitations:
- No deterministic non-interactive customs scenario harness exists yet.
- Runtime `container_meta` lacks `container_class_id`.
- No measured gross/net/physical mass source exists; the first helper can compare documentary expected mass to runtime quantity-derived expected mass, not actual scanned mass.
- Current live inspection paths mutate pressure and logs. The first helper should be tested by direct static/helper calls, not by wiring into `run_customs_inspection()`.

Scenario harness recommendation:
- A harness is not required before implementing the helper as a pure static read-only function if the implementation job includes small deterministic direct-call validation.
- A harness should be planned or implemented before any integration into live inspection, UI, logs, or pressure-adjacent flows.

## Candidate Follow-Up Jobs

### 1. Implement Level 3 Read-Only Reconciliation Helper
- Target job type: `feature`
- Risk level: medium-high
- Likely whitelist:
  - `scripts/customs/CustomsLevel3Reconciliation.gd` (new file)
  - possibly `codex/runs/ACTIVE_RUN.txt`
  - future active run folder files
- Narrow goal:
  - add a pure static helper that accepts a context dictionary and returns the Level 3 report payload defined above.
- Verification approach:
  - direct deterministic calls for clean, mismatch, missing docs, missing cargo, unknown commodity mass, missing tolerance policy, and missing container class cases
  - static search confirms no callers from live runtime paths
  - source review confirms no calls to mutation/log/travel/pressure APIs
- Explicit non-goals:
  - no `singletons/Customs.gd`, no `singletons/GameState.gd`, no UI, no logs, no pressure, no enforcement, no Level 2 behavior changes

### 2. Add Deterministic Level 3 Helper Validation Harness
- Target job type: `feature` or `test`
- Risk level: medium
- Likely whitelist:
  - a narrow test/scenario/debug file chosen by the future job
  - `scripts/customs/CustomsLevel3Reconciliation.gd` only if small test-support adjustments are needed
  - future active run folder files
- Narrow goal:
  - provide repeatable validation for clean, suspicious, and not-evaluable reports without live inspection side effects.
- Verification approach:
  - one command or clearly documented Godot/headless recipe emits deterministic reports
  - repeated runs produce identical sorted payloads
- Explicit non-goals:
  - no production inspection integration, UI, pressure, enforcement, or broad test framework rewrite

### 3. Add Inert Runtime Container Class Attachment
- Target job type: `feature`
- Risk level: medium-high
- Likely whitelist:
  - `singletons/GameState.gd`
  - possibly `scripts/freight/FreightDocRules.gd`
  - future active run folder files
- Narrow goal:
  - add `container_class_id` to newly generated `container_meta` so future tare checks can evaluate deterministically.
- Verification approach:
  - generated docs include stable class IDs
  - existing freight doc validation still passes
  - Level 1/Level 2 classifications are unchanged except for explicitly scoped inert surface validation if allowed
- Explicit non-goals:
  - no Level 3 comparison, no UI, no pressure, no enforcement

### 4. Integrate Level 3 Helper Behind Explicit Read-Only Audit Context
- Target job type: `feature`
- Risk level: high
- Likely whitelist:
  - `singletons/Customs.gd`
  - `scripts/customs/CustomsLevel3Reconciliation.gd`
  - possibly `singletons/GameState.gd`
  - future active run folder files
- Narrow goal:
  - call the already-verified helper from a non-enforcing path and attach the returned report to an inspection/audit payload.
- Verification approach:
  - compare before/after snapshots of cargo, docs, credits, pressure state, travel state, and logs if the job scopes log behavior
  - prove Level 2 `L2INV-001` remains policy-disabled
- Explicit non-goals:
  - no UI surfacing, no pressure-only consequences, no enforcement, no physical inspections

### 5. Surface Existing Level 3 Read-Only Findings
- Target job type: `feature`
- Risk level: medium-high
- Likely whitelist:
  - narrow inspection UI/report formatter files
  - future active run folder files
- Narrow goal:
  - display an already-computed Level 3 report without invoking new reconciliation logic from UI.
- Verification approach:
  - UI renders report fields and handles `not_evaluable` cleanly
  - no state mutation or pressure changes
- Explicit non-goals:
  - no new helper semantics, no pressure, no enforcement, no physical inspection

### 6. Plan Any Pressure-Only Consequences From Level 3 Findings
- Target job type: `planning`
- Risk level: high
- Likely whitelist:
  - future active planning run folder only
- Narrow goal:
  - decide whether Level 3 findings should ever affect scrutiny or pressure, and define strict no-enforcement boundaries before implementation.
- Verification approach:
  - planning output only; no executable scope unless converted into a complete future `job.md`
- Explicit non-goals:
  - no runtime changes, no physical inspections, no fines, no holds, no seizures, no forced offloads, no cargo denial, no travel blocking

## Likely Whitelist Sketch
First helper implementation should be narrow:
- allow new `scripts/customs/CustomsLevel3Reconciliation.gd`
- allow active run files
- avoid `singletons/Customs.gd` for the first implementation unless the future job explicitly needs a read-only wrapper
- avoid `singletons/GameState.gd` until a separate container-class or integration job
- avoid `data/**` unless a future job discovers an accessor gap and scopes it explicitly
- avoid `scenes/**`, UI files, project settings, and governance files

## Verification Strategy for Future Helper
Future helper implementation should prove report-only determinism with:
- direct helper calls using literal context dictionaries
- clean case: declared quantity/mass equals runtime quantity/mass within tolerance
- mismatch case: declared/runtime quantity or mass exceeds tolerance and returns `suspicious` report only
- missing docs case: returns structured `not_evaluable`
- missing cargo case: returns structured `not_evaluable`
- unknown commodity/mass case: returns structured `not_evaluable`
- missing or malformed tolerance policy case: returns structured `not_evaluable`
- missing container class/tare case: container check `not_evaluable` while non-container checks can still evaluate
- repeated identical input produces identical sorted output
- source review or static search confirms no calls to:
  - `add_cargo`
  - `remove_cargo`
  - `apply_customs_pressure_increase`
  - `_record_customs_level2_invariant_violation`
  - `Log.add_entry`
  - `emit_signal`
  - save/load writers
  - credit mutation
  - travel methods
  - freight doc mutation methods

Post-implementation scope checks should include:
- `rg "CustomsLevel3Reconciliation|build_level3_reconciliation_report" data scripts singletons scenes project.godot`
- `rg "policy_disabled_until_level3" scripts/customs/CustomsInvariants.gd`
- full `git diff` review for absence of UI, pressure, enforcement, and Level 2 behavior changes

## Governance Follow-Up
- The job template named `C:\Users\akaph\Desktop\Ozark Interactive\Games\Tiny Cormorant` as canonical.
- The human confirmed that the current path, `C:\Users\akaph\OneDrive\Desktop\Ozark Interactive\Games\Tiny Cormorant`, is the intended canonical clone on this machine because Windows/OneDrive redirects Desktop.
- Future governance should clarify this machine-specific canonical path so it is not mistaken for an old scratch clone.
- No governance files were modified in this planning job.

## Non-Goals Preserved
- No runtime game behavior changed.
- No data files, runtime code, scenes, project settings, roadmap documentation, or governance files were modified.
- Existing Level 3 primitives and accessors remain inert and unwired.
- Level 2 quantity/cargo reconciliation remains policy-disabled.
- No helper output was wired into inspections, pressure, UI, logs, gameplay, or enforcement.
- No fines, seizures, holds, cargo denial, travel blocking, reputation effects, physical inspections, Port Authority simulation, or forced offloads were authorized.
- This planning output is advisory only until converted into a complete future `job.md` or explicit active-run instructions.
