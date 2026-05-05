# Results

## Summary
- Planned the first read-only Level 3 reconciliation integration as report attachment only.
- Recommended report key: `level3_reconciliation`.
- Recommended depth gate: attach only when `max_depth >= 3`.
- Recommended attachment seam: `GameState.run_customs_inspection(context)` after the existing Level 2 block and after the existing customs log entry is built, but before `customs_inspection_completed` is emitted and before returning the report.
- Recommended context ownership split:
  - `GameState.gd` owns deciding whether the inspection report gets a Level 3 payload.
  - `Customs.gd` should own the narrow wrapper/context normalization that calls `CustomsLevel3Reconciliation`.
  - `CustomsLevel3Reconciliation.gd` should remain the pure helper and should not learn about live inspection flow.
- Preserved boundaries: no UI surfacing, no log formatting, no pressure effects, no enforcement, no Level 2 policy change, and no runtime code changes in this planning job.

## Preflight Evidence
- branch: `master`
- `git status --short`: clean before scaffolding
- HEAD before this job: `a6830b7 issue-0134: Run Level 3 helper validation harness`
- `git show HEAD:codex/runs/ACTIVE_RUN.txt`: `issue-0134-run-level-3-helper-validation-harness`
- `git fetch origin`: completed
- `git status -sb`: `## master...origin/master`

## Workspace Path Evidence
- `C:\Users\akaph\Desktop\Ozark Interactive\Games\Tiny Cormorant` does not exist on this machine.
- `C:\Users\akaph\OneDrive\Desktop\Ozark Interactive\Games\Tiny Cormorant` exists and is the current working tree.
- This matches the prior OneDrive Desktop redirect clarification. No governance files were modified.

## Evidence Reviewed
- Prior results:
  - `issue-0130-plan-level-3-read-only-reconciliation-helper`
  - `issue-0131-implement-level-3-read-only-reconciliation-helper`
  - `issue-0133-add-deterministic-level-3-helper-validation-harness`
  - `issue-0134-run-level-3-helper-validation-harness`
- Source surfaces read-only:
  - `singletons/GameState.gd`
  - `singletons/Customs.gd`
  - `scripts/customs/CustomsLevel3Reconciliation.gd`
  - `scripts/customs/CustomsLevel1Audit.gd`
  - `scripts/customs/CustomsLevel2Audit.gd`
  - `scripts/customs/CustomsInvariants.gd`
  - `scripts/customs/CustomsReportFormatter.gd`
  - `scripts/Port.gd`
  - `scripts/freight/FreightDocRules.gd`

## Capability Definition
“Level 3 read-only inspection integration” means:
- When an inspection explicitly reaches Level 3 depth, attach the existing helper report to the inspection report payload.
- The attached payload is advisory/report-only and should be the exact dictionary returned by `CustomsLevel3Reconciliation.build_level3_reconciliation_report(ctx)`.
- The integration may compare declaration-like documents to the runtime cargo snapshot using existing inert mass/tolerance primitives.
- The integration may report `not_evaluable` container/tare checks where container class metadata is missing.

It does not mean:
- no changes to top-level inspection `classification`
- no new `reasons`
- no `recommended_penalty` changes
- no pressure/scrutiny changes
- no log output changes
- no UI surfacing
- no cargo, docs, credits, time, travel, save/load, Galaxy, or market mutation
- no Level 2 behavior changes
- no physical inspection simulation or enforcement

## Recommended Integration Seam
Recommended future seam:
- `singletons/GameState.gd`
- function: `run_customs_inspection(context: Dictionary = {})`
- report key: `level3_reconciliation`
- gate: `if max_depth >= 3:`

Recommended placement:
- Build/attach the Level 3 report after the existing Level 2 block.
- Attach after the existing `Log.add_entry(CustomsReportFormatter.format_customs_log_entry(...))` call if the implementation wants to guarantee zero log text changes.
- Attach before `emit_signal("customs_inspection_completed", report)` and before `return report`.

Rationale:
- `GameState.run_customs_inspection()` already owns the core inspection report payload, `inspection_id`, `classification`, `doc_summary`, `surface_findings`, `action_surface`, Level 2 attachment, signal emission, and return value.
- Attaching in `Customs.gd` would miss direct callers such as the Port customs button, which calls `GameState.run_customs_inspection()` directly.
- Attaching before the signal/return makes the report available to consumers while leaving current log formatting unchanged.
- Keeping the attachment behind `max_depth >= 3` means current live resolved inspection depth does not trigger Level 3 today, because `resolve_customs_inspection_depth()` currently clamps resolved depth to `0..2`.

Recommended future code shape, conceptually:

```gdscript
if max_depth >= 3:
	var level3_context: Dictionary = Customs.build_level3_reconciliation_context({
		"docs": get_freightdoc_chain_snapshot().get("docs", {}),
		"cargo": cargo.duplicate(true),
		"tick": time_tick,
		"action": action,
		"system_id": system_id,
		"location_id": location_id,
	})
	report["level3_reconciliation"] = Customs.run_level_3_reconciliation(level3_context)
```

This is illustrative only; this planning job does not authorize implementation.

## Depth / Trigger Boundary
Recommended rule:
- Level 3 reconciliation should attach only when `max_depth >= 3`.

Do not attach when:
- `max_depth < 3`
- only Level 1 surface checks run
- only Level 2 documentary audit runs
- the outer `Customs.run_sale_check`, `run_departure_check`, or `run_entry_check` resolved depth is `1` or `2`

Important current behavior:
- `GameState.resolve_customs_inspection_depth(...)` currently returns `max_depth` clamped to `0..2`.
- Therefore a future Level 3 attachment behind `max_depth >= 3` should not change ordinary live sale/departure/entry checks until a separate future depth-policy job explicitly allows Level 3 depth.
- Direct/manual validation can still call `GameState.run_customs_inspection({"max_depth": 3, ...})` in a governed test/validation job.

Recommendation:
- Do not change depth resolution in the first integration job.
- Plan Level 3 depth policy separately if and when the game should ever naturally reach Level 3.

## Context Construction Responsibility
Recommended split:
- `GameState.gd`
  - decides whether the report gets Level 3 based on `max_depth >= 3`
  - supplies live snapshots, duplicated at the boundary:
    - `docs` from `get_freightdoc_chain_snapshot().docs`
    - `cargo` from `cargo.duplicate(true)`
    - `tick`
    - `action`
    - `system_id`
    - `location_id`
- `Customs.gd`
  - owns a small wrapper such as `run_level_3_reconciliation(context: Dictionary = {}) -> Dictionary`
  - normalizes docs consistently with Level 2 by reusing `_normalize_level2_docs_for_audit(...)`
  - fills missing diagnostic fields if needed
  - calls `CustomsLevel3Reconciliation.build_level3_reconciliation_report(normalized_context)`
- `CustomsLevel3Reconciliation.gd`
  - remains pure helper logic
  - should not call `GameState`, `Customs`, `Log`, UI, travel, save/load, pressure, or mutation APIs

Available inputs:
- docs snapshot from `get_freightdoc_chain_snapshot()`
- runtime cargo snapshot from `GameState.cargo`
- action/system/location/tick diagnostics from inspection context/current state
- commodity mass and tolerance primitives from existing helper dependencies

Missing/limited inputs:
- runtime `container_meta` does not include `container_class_id`
- no physical measured mass source exists
- no gross/net scanner or physical inspection system exists
- current natural max depth never reaches 3

Missing-data behavior:
- Attach the helper payload even if parts are `not_evaluable`.
- Do not convert `not_evaluable` into top-level suspicious/invalid classification.
- Do not apply pressure, logs, fines, holds, cargo denial, travel blocking, or UI changes based on Level 3 output in the first integration.

## Output Attachment Contract
Recommended report key:
- `level3_reconciliation`

Recommended payload:
- exact helper report dictionary, including:
  - `schema_version`
  - `level`
  - `kind`
  - `classification`
  - `status`
  - `policy_id`
  - `summary`
  - `checks`
  - `findings`
  - `totals`
  - `not_evaluable`
  - `context_echo`

Do not add in the first integration:
- `level3_evidence_flags`
- `level3_invariant_summary`
- `level3_pressure_delta`
- `level3_penalty`
- top-level `reasons` entries from Level 3
- top-level classification changes from Level 3
- formatter/log snippets from Level 3

Reason:
- Extra derivative keys create integration pressure and review ambiguity. The first job should prove payload attachment only.

## Level 2 Purity Boundary
Must preserve:
- `scripts/customs/CustomsInvariants.gd` `L2INV-001` remains `policy_disabled_until_level3`.
- `Customs.run_level_2_audit(...)` remains documentary/Level 2 scoped.
- No Level 3 helper call should be added inside `CustomsLevel2Audit.gd` or `CustomsInvariants.gd`.
- No Level 2 finding should be reclassified because of Level 3 reconciliation.

Recommended verification:
- `rg "policy_disabled_until_level3|L2INV-001" scripts/customs/CustomsInvariants.gd`
- `rg "CustomsLevel3Reconciliation|build_level3_reconciliation_report" scripts/customs/CustomsLevel2Audit.gd scripts/customs/CustomsInvariants.gd`
- `git diff` review confirms no Level 2 logic changed except possibly no changes at all.

## Dependencies And Blockers
Ready:
- Level 3 helper exists and is pure/static.
- Validation harness exists.
- Harness ran twice through Godot 4.6.1 with exit code `0`.
- `GameState.run_customs_inspection()` already has report assembly and depth gating for Level 2.
- `Customs.gd` already has doc normalization and Level 2 audit wrapper patterns.

Blockers/limitations:
- Current natural resolved inspection depth is capped at `2`.
- Container/tare checks will often be `not_evaluable` because `container_class_id` is not generated in `_build_container_meta(...)`.
- The provided non-console Godot executable did not expose stdout for JSON output in issue-0134, though the harness exit code passed.
- Adding to `GameState.run_customs_inspection()` is high risk because that path logs, emits signals, applies pressure for existing invalid outcomes, and returns UI-consumed reports.

## Candidate Job Sequence
### 1. Implement Level 3 Read-Only Report Attachment
- Target job type: feature
- Risk level: high
- Likely whitelist:
  - `singletons/GameState.gd`
  - `singletons/Customs.gd`
  - `codex/runs/ACTIVE_RUN.txt`
  - future active run folder files
- Narrow goal:
  - attach `report["level3_reconciliation"]` inside `GameState.run_customs_inspection()` only when `max_depth >= 3`.
  - add a narrow `Customs.run_level_3_reconciliation(...)` wrapper if needed for normalization/context construction.
- Verification approach:
  - direct `run_customs_inspection({"max_depth": 3, ...})` validation shows `level3_reconciliation` attached.
  - `max_depth` 0, 1, and 2 reports do not contain `level3_reconciliation`.
  - before/after snapshots prove no mutation of cargo, freight docs, credits, time, pressure/scrutiny dictionaries, travel state, save data, or UI state.
  - log output remains byte-for-byte or string-equal for comparable pre/post cases if attachment is after log formatting.
  - Level 2 policy-disabled marker remains present.
- Explicit non-goals:
  - no UI surfacing
  - no log formatter changes
  - no pressure/scrutiny effects
  - no enforcement
  - no depth policy change
  - no container-class generation

### 2. Add Focused Integration Validation
- Target job type: test or feature-validation
- Risk level: medium
- Likely whitelist:
  - a narrow validation script or future active run files
  - possibly `scripts/customs/CustomsLevel3ReconciliationValidation.gd` only if explicitly scoped
- Narrow goal:
  - validate the live inspection attachment boundary without changing gameplay.
- Verification approach:
  - use direct calls with literal or setup/teardown snapshots.
  - prove deterministic output for `max_depth >= 3`.
  - prove no attachment for `max_depth < 3`.
  - prove no state mutation.
- Explicit non-goals:
  - no UI, no pressure, no logs, no enforcement, no broad test framework.

### 3. Plan Level 3 Depth Policy
- Target job type: planning
- Risk level: high
- Likely whitelist:
  - future active planning run folder only
- Narrow goal:
  - decide whether normal customs depth can ever resolve to `3`, under what conditions, and how that interacts with scrutiny.
- Verification approach:
  - planning/source review only.
- Explicit non-goals:
  - no code changes, no pressure effects, no enforcement, no UI.

### 4. Add Inert Runtime Container Class Attachment
- Target job type: feature
- Risk level: medium-high
- Likely whitelist:
  - `singletons/GameState.gd`
  - possibly `scripts/freight/FreightDocRules.gd`
  - future active run folder files
- Narrow goal:
  - add deterministic `container_class_id` to generated `container_meta` so Level 3 container/tare checks can evaluate.
- Verification approach:
  - generated freight docs include stable class IDs.
  - existing surface validation remains valid.
  - Level 1/Level 2 behavior remains unchanged unless explicitly scoped.
- Explicit non-goals:
  - no Level 3 report integration, no UI, no pressure, no enforcement.

### 5. Surface Existing Level 3 Payload In UI
- Target job type: feature
- Risk level: medium-high
- Likely whitelist:
  - `scripts/ui/CustomsInspectionPanel.gd`
  - `scenes/ui/CustomsInspectionPanel.tscn`
  - possibly a new narrow UI panel scene/script
  - future active run folder files
- Narrow goal:
  - display an already-attached `level3_reconciliation` payload.
- Verification approach:
  - UI handles missing payload and `not_evaluable` cleanly.
  - no helper invocation from UI.
  - no pressure/log/enforcement changes.
- Explicit non-goals:
  - no new reconciliation semantics, no depth-policy change, no pressure, no enforcement.

### 6. Plan Pressure/Scrutiny Consequences, If Any
- Target job type: planning
- Risk level: high
- Likely whitelist:
  - future active planning run folder only
- Narrow goal:
  - decide whether Level 3 suspicious findings should ever affect scrutiny, and define strict no-enforcement boundaries first.
- Verification approach:
  - planning only.
- Explicit non-goals:
  - no runtime changes, no physical inspections, no fines, no holds, no seizures, no forced offloads, no cargo denial, no travel blocking.

## Likely Whitelist For First Implementation
Recommended first implementation whitelist:
- `singletons/GameState.gd`
- `singletons/Customs.gd`
- `codex/runs/ACTIVE_RUN.txt`
- future active run folder files

Avoid in first implementation:
- `scripts/customs/CustomsLevel3Reconciliation.gd` unless a tiny integration-support issue is discovered and explicitly scoped
- `scripts/customs/CustomsLevel2Audit.gd`
- `scripts/customs/CustomsInvariants.gd`
- `scripts/customs/CustomsReportFormatter.gd`
- `scripts/ui/**`
- `scenes/**`
- `data/**`
- `project.godot`
- save/load code

Reason:
- `GameState.gd` is needed because it owns the report and direct callers.
- `Customs.gd` is the safest place for orchestration/context normalization.
- Formatter/UI/data/helper changes should be separate to keep review confidence.

## Verification Strategy For First Implementation
Required static checks:
- `rg "level3_reconciliation" data scripts singletons scenes project.godot`
- `rg "CustomsLevel3Reconciliation|build_level3_reconciliation_report" data scripts singletons scenes project.godot`
- `rg "policy_disabled_until_level3|L2INV-001" scripts/customs/CustomsInvariants.gd`
- `rg "apply_customs_pressure_increase|_record_customs_level2_invariant_violation|Log.add_entry|emit_signal|add_cargo|remove_cargo|player_money|save_game|load_game" singletons/GameState.gd singletons/Customs.gd`

Required behavioral checks:
- `max_depth = 0`: no `level3_reconciliation`
- `max_depth = 1`: no `level3_reconciliation`
- `max_depth = 2`: no `level3_reconciliation`, existing `level2_audit` behavior unchanged
- `max_depth = 3`: `level3_reconciliation` attached
- Level 3 suspicious/mismatch payload does not change top-level `classification`
- Level 3 `not_evaluable` payload does not change top-level `classification`
- repeated identical direct calls produce deterministic `level3_reconciliation`

Required no-mutation snapshots:
- `cargo`
- `freight_docs`
- `cargo_lines`
- `player_money`
- `time_tick`
- `current_system_id`
- `current_location_id`
- `customs_recent_level2_violation_tick_by_location`
- customs scrutiny deltas by location if accessible
- save/load fields unchanged except the already-existing inspection ID increment caused by running inspection

Known allowed existing side effects of `run_customs_inspection()`:
- inspection ID increments
- customs log entry is written
- signal is emitted
- existing pressure increase can still happen for existing Level 1/Level 2 invalid classifications

The implementation must prove Level 3 does not add new side effects beyond these existing inspection behaviors.

## Final Recommendation
Proceed with one narrow feature job: attach `level3_reconciliation` behind `max_depth >= 3` in the inspection report, using `Customs.gd` for context normalization/wrapper logic and `GameState.gd` only for report attachment.

Do not change natural depth resolution yet. Because current resolved depth is capped at `2`, the first implementation can be present but inert for normal live checks until a later governed depth-policy job.

Do not combine the first integration with UI, logs, pressure, enforcement, container-class metadata, or Level 2 changes.

## Non-Goals Preserved
- No runtime game behavior changed in this planning job.
- No helper, harness, runtime code, scenes, project settings, data files, UI, documentation roadmap files, or governance files were modified.
- No Level 3 integration was implemented.
- No UI surfacing was authorized.
- No pressure/scrutiny effect was authorized.
- No enforcement was authorized.
- Level 2 quantity/cargo reconciliation remains policy-disabled.
