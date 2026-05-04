# Results

## Summary
- Audited `CommodityDB.COMMODITIES[*].weight_per_unit` definition and usage read-only.
- Recommendation: `weight_per_unit` is currently a gameplay cargo-capacity weight field and is ambiguous as a Level 3 customs mass source of truth.
- Future Level 3 work should not directly treat `weight_per_unit` as customs mass without either adding a separate inert customs mass primitive or formally adding a customs-owned accessor/schema layer that makes the semantics explicit.
- No runtime, data, scene, documentation, project setting, or protected governance files were modified.

## Evidence Reviewed
- Preflight:
  - branch `master`
  - working tree clean before issue-0125 scaffolding
  - `HEAD...origin/master` was `0 0` after `git fetch origin`
- Prior planning:
  - `codex/runs/issue-0124-plan-level-3-reconciliation-data-primitives/results.md`
- Read-only source surfaces:
  - `data/CommodityDB.gd`
  - `singletons/GameState.gd`
  - `singletons/Economy.gd`
  - `scripts/ShipPanel.gd`
  - `scripts/MarketPanel.gd`
  - `scripts/ui/BlackMarketPanel.gd`
  - `scripts/customs/CustomsInvariants.gd`

## Definition and Usage Map

### Definition
- `data/CommodityDB.gd` defines `weight_per_unit` for every commodity.
- Values are coarse gameplay-friendly numbers: mostly `0.5`, `1.0`, or `2.0`.
- No explicit unit label, customs meaning, tolerance policy, physical mass scale, or source/measurement provenance was found in the commodity data.

### Runtime Cargo Capacity
- `singletons/GameState.gd` defines the cargo model as `{ commodity_id: quantity }`.
- `GameState.get_total_cargo_weight()` multiplies cargo quantity by `CommodityDB.get_commodity(commodity_id).weight_per_unit`.
- `GameState.get_free_cargo_space()` subtracts that total from `cargo_capacity_weight`.
- `GameState.record_market_purchase(...)` checks `current_weight + added_weight > cargo_capacity_weight` before adding purchased cargo.
- `scripts/ui/BlackMarketPanel.gd` performs the same capacity check before black-market purchases.
- `scripts/ShipPanel.gd`, `scripts/MarketPanel.gd`, and `scripts/ui/BlackMarketPanel.gd` display cargo used/capacity based on this same weight calculation.

### Economy
- `singletons/Economy.gd` reads `CommodityDB` for `base_price`, `producer_types`, and `consumer_types`; no `weight_per_unit` usage was found in price calculation.

### Freight Documents and Cargo Lines
- Freight documents and purchase/bill/contract cargo lines use quantity-oriented fields such as `commodity_id`, `declared_qty`, `quantity`, `sold_qty`, `cargo_space`, and `sources`.
- Contract freight-doc creation copies `cargo_space` from the contract line or falls back to declared quantity.
- Market purchase docs set `cargo_space = quantity`.
- No document field records calculated commodity mass, customs mass, gross mass, net mass, or units.

### Customs
- `scripts/customs/CustomsInvariants.gd` explicitly policy-disables Level 2 quantity consistency until Level 3 cargo reconciliation.
- No customs code currently uses `weight_per_unit` as evidence.
- `Customs.run_level_2_audit()` may pass a cargo snapshot into the audit context, but Level 2 quantity reconciliation remains not evaluable by policy.

## Field-Ownership Recommendation
`weight_per_unit` should be treated as **ambiguous for Level 3 customs mass**.

It is sufficient for its current gameplay owner:
- ship cargo usage
- cargo capacity checks
- cargo usage display

It is not yet sufficient as customs mass source of truth because:
- no unit is defined
- values are coarse and likely tuned for gameplay capacity rather than documentary/physical reconciliation
- no customs-owned accessor or schema contract exists
- no tolerance policy exists
- document cargo lines preserve quantities and cargo-space abstractions, not mass
- using the field directly in customs would silently couple Level 3 evidence to current cargo-capacity tuning

Recommended ownership:
- Keep `weight_per_unit` as the existing gameplay cargo-capacity primitive.
- Add a future inert customs-owned primitive or schema layer before Level 3 reconciliation uses mass.
- If the team wants to avoid duplicate commodity fields, a future job may add a customs accessor that explicitly aliases `weight_per_unit` only after naming the unit and proving all commodity rows are complete.

## Unresolved Uncertainty
- The project does not currently document whether `weight_per_unit` represents tons, cargo slots, abstract hold units, or physical mass.
- Existing values may be good enough for a stylized customs system, but that should be an explicit design decision rather than an implication from the field name.
- Tare weights, container classes, gross/net mass, and tolerance rules remain undefined.

## Candidate Job Sequence

### 1. Add Inert Customs Mass Primitive
- Target job type: `feature`
- Risk level: medium-high
- Likely whitelist:
  - `data/CommodityDB.gd`
  - possibly one narrow data/schema helper if explicitly authorized
  - active run files
- Narrow goal:
  - add a customs-owned mass primitive such as `customs_mass_per_unit` or a clearly documented alias/schema field, without reading it from inspection logic.
- Verification approach:
  - static inspection confirms every commodity has the field, values are numeric and positive, and no customs/runtime behavior reads the field yet.
- Explicit non-goals:
  - no reconciliation helper, no UI, no pressure, no enforcement, no Level 2 quantity behavior.

### 2. Add Read-Only Commodity Mass Accessor or Validator
- Target job type: `feature`
- Risk level: medium
- Likely whitelist:
  - `data/CommodityDB.gd`
  - possibly `scripts/customs/**` only if the helper is read-only and not connected to audit classification
  - active run files
- Narrow goal:
  - expose deterministic lookup and missing-data reporting for customs mass without mutating cargo, documents, pressure, credits, or time.
- Verification approach:
  - call lookup/validation on known commodities and missing IDs; confirm report-only output and no gameplay side effects.
- Explicit non-goals:
  - no Level 3 reconciliation comparison, no UI, no enforcement.

### 3. Define Tolerance and Container Tare Separately
- Target job type: `planning` or `feature`, depending on whether data shape is ready
- Risk level: medium-high
- Likely whitelist:
  - active run files for planning
  - later `data/**` only if a complete executable job authorizes it
- Narrow goal:
  - define tolerance rules and container tare/class defaults separately from commodity mass.
- Verification approach:
  - static completeness checks and deterministic unknown-data behavior.
- Explicit non-goals:
  - no customs classification changes, no physical inspection, no enforcement.

### 4. Add Level 3 Read-Only Reconciliation Helper
- Target job type: `feature`
- Risk level: high
- Likely whitelist:
  - `scripts/customs/**`
  - possibly `singletons/Customs.gd`
  - active run files
- Narrow goal:
  - compare documentary quantities and future customs mass primitives against runtime cargo snapshots as report-only Level 3 findings.
- Verification approach:
  - deterministic match/mismatch cases prove no cargo, credits, documents, pressure, travel, or enforcement state changes.
- Explicit non-goals:
  - no UI surfacing, no pressure, no enforcement, no physical inspection.

## Recommended Next Job
Recommended next governed job:
- Target job type: `feature`
- Risk level: medium-high
- Likely whitelist:
  - `data/CommodityDB.gd`
  - `codex/runs/ACTIVE_RUN.txt`
  - future active run folder files
- Narrow goal:
  - add an inert customs-owned commodity mass primitive or explicit schema alias, with static verification only.
- Verification approach:
  - inspect all commodity records and confirm positive numeric customs mass values or explicit alias semantics; confirm `rg "customs_mass"` or equivalent shows no inspection outcome integration unless the job explicitly includes a read-only validator.

Alternative if the team wants one more design pause:
- Target job type: `planning`
- Risk level: low
- Likely whitelist:
  - active run folder only
- Narrow goal:
  - choose the exact field name/unit policy before `data/**` is touched.
- Verification approach:
  - record the final naming decision and expected static validation rules.

## Verification Strategy for Future Work
- Data additions prove completeness by scanning every commodity entry for a positive numeric customs mass field or explicit alias field.
- Accessor/helper work proves no side effects by returning dictionaries or reports only and avoiding calls to mutation methods such as `add_cargo`, `remove_cargo`, `apply_customs_pressure_increase`, save/load writes, credit mutation, or document mutation.
- Level 2 regression checks must confirm `policy_disabled_until_level3` remains the Level 2 quantity consistency result until a separate Level 3-only job introduces new paths.
- Any future Level 3 report must explicitly prove absence of fines, holds, seizures, cargo denial, travel blocking, reputation effects, forced offloads, cargo mutation, credit mutation, and document mutation.

## Follow-Up Governance Note
- On this machine, the confirmed canonical clone path is `C:\Users\akaph\OneDrive\Desktop\Ozark Interactive\Games\Tiny Cormorant`, which appears to be the Desktop path as resolved through OneDrive.
- This remains a governance clarification follow-up only; no governance files were modified in this planning job.

## Non-Goals Preserved
- No runtime game behavior changed.
- `data/**` was not modified.
- No Level 3 primitive, helper, reconciliation logic, UI surfacing, pressure effect, or enforcement was implemented.
- Level 2 quantity/cargo reconciliation remains policy-disabled.
- This output is advisory only until converted into a complete future `job.md` or explicit active-run instructions.
