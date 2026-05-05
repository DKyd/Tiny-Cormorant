# Results

## Summary of Changes and Rationale
- Attached the existing Level 3 reconciliation helper output to customs inspection reports under the key `level3_reconciliation`.
- Attachment is gated strictly by `max_depth >= 3` inside `GameState.run_customs_inspection(context)`.
- Added a narrow read-only `Customs.run_level_3_reconciliation(context)` wrapper that normalizes docs and delegates to `CustomsLevel3Reconciliation.build_level3_reconciliation_report(ctx)`.
- Placed attachment after existing log formatting and before `customs_inspection_completed` / return, preserving current log text and signal payload availability.
- Did not modify UI, logs, pressure/scrutiny, inspection depth/chance/trigger rules, save/load, data, scenes, helper logic, harness logic, or Level 2 semantics.

## Files Changed
- `singletons/Customs.gd`
  - Added preload for `CustomsLevel3Reconciliation`.
  - Added `run_level_3_reconciliation(context: Dictionary = {}) -> Dictionary`.
  - The wrapper duplicates input, fills diagnostic defaults, normalizes docs with the existing customs doc normalization path, duplicates cargo when needed, and calls the pure Level 3 helper.
- `singletons/GameState.gd`
  - In `run_customs_inspection`, attaches `report["level3_reconciliation"]` only when `max_depth >= 3`.
  - Uses duplicated freight doc and cargo snapshots.
  - Attachment happens after current customs log formatting and before signal/return.
- `codex/runs/ACTIVE_RUN.txt`
  - Updated active run marker to `issue-0136-attach-level-3-reconciliation-report-to-inspections`.
- `codex/runs/issue-0136-attach-level-3-reconciliation-report-to-inspections/job.md`
  - Recorded the provided issue-0136 job instructions.
- `codex/runs/issue-0136-attach-level-3-reconciliation-report-to-inspections/results.md`
  - Recorded implementation summary, verification, assumptions, and limitations.

## Preflight Evidence
- branch: `master`
- `git status --short`: clean before scaffolding
- HEAD before this job: `08699de issue-0135: Plan Level 3 read-only inspection integration`
- `git show HEAD:codex/runs/ACTIVE_RUN.txt`: `issue-0135-plan-level-3-read-only-inspection-integration`
- `git fetch origin`: completed
- `git status -sb`: `## master...origin/master`

## Attachment Contract
- Report key: `level3_reconciliation`
- Gate: `max_depth >= 3`
- No attachment for absent default `max_depth`, negative depth, or depths `0`, `1`, or `2`.
- Existing natural depth resolution remains unchanged and currently resolves only up to `2`, so ordinary live inspection paths do not naturally attach Level 3 yet.
- Direct callers can receive Level 3 output only by explicitly calling `GameState.run_customs_inspection(...)` with `max_depth >= 3`.

## Verification Performed
- Godot launch/parse smoke check:
  - Command: `& "C:\Users\akaph\OneDrive\Desktop\Godot_v4.6.1-stable_win64.exe" --headless --path . --quit`
  - Exit code: `0`
  - Output: empty stdout from the non-console executable.
- Level 3 validation harness still passes by exit code:
  - Command: `& "C:\Users\akaph\OneDrive\Desktop\Godot_v4.6.1-stable_win64.exe" --headless --path . --script res://scripts/customs/CustomsLevel3ReconciliationValidation.gd`
  - Exit code: `0`
  - Output: empty stdout from the non-console executable.
- Whitespace:
  - `git diff --check`: passed.
- Level 3 attachment search:
  - `rg "level3_reconciliation|run_level_3_reconciliation|CustomsLevel3Reconciliation" data scripts singletons scenes project.godot`
  - Matches were limited to:
    - `singletons/GameState.gd`
    - `singletons/Customs.gd`
    - existing Level 3 helper and validation harness files
- UI non-surfacing check:
  - `rg "level3_reconciliation|CustomsLevel3Reconciliation" scripts/ui scenes/ui`
  - Result: no matches.
- Level 2 policy check:
  - `rg "policy_disabled_until_level3|L2INV-001" scripts/customs/CustomsInvariants.gd`
  - Result: `L2INV-001` and `policy_disabled_until_level3` remain present.
- Targeted new-side-effect diff scan:
  - `git diff -U0 -- singletons/Customs.gd singletons/GameState.gd | Select-String -Pattern "Log\\.add_entry|apply_customs_pressure_increase|_record_customs_level2_invariant_violation|emit_signal|add_cargo|remove_cargo|player_money|save_game|load_game|level3_reconciliation|run_level_3_reconciliation"`
  - Added-line matches were only:
    - `run_level_3_reconciliation`
    - `CustomsLevel3Reconciliation.build_level3_reconciliation_report(...)`
    - `report["level3_reconciliation"] = Customs.run_level_3_reconciliation(...)`
  - No new log, pressure, scrutiny, signal, cargo, credit, save/load, or enforcement calls were added.
- Working tree after Godot runs:
  - No `.godot/**` files appeared in `git status --short`.

## Assumptions Made
- `max_depth` inside `GameState.run_customs_inspection(context)` is the correct resolved depth boundary for direct report attachment.
- Keeping natural depth resolution capped at `2` is intentional for this job, so Level 3 remains inert for normal sale/departure/entry checks until a future depth-policy job.
- Reusing the existing customs doc normalization path in `Customs.gd` is the safest first wrapper behavior because it matches the existing Level 2 audit context style.
- The existing helper owns all missing-data behavior; the integration should attach the payload even when helper checks are `not_evaluable`.

## Known Limitations or TODOs
- No UI displays Level 3 yet by design.
- No pressure/scrutiny behavior responds to Level 3 findings by design.
- Container/tare checks may remain `not_evaluable` until a future job adds deterministic `container_class_id` metadata.
- The non-console Godot executable still returns empty stdout, so validation evidence is by exit code and static review.
- This job did not add a live integration scenario harness; focused integration validation can be a separate future job if desired.

## Logging Checklist
- No explicit player actions were added.
- No time advancement paths were changed.
- No UI-only interactions were added.
- No per-frame or loop-driven log spam was introduced.
- No new log messages were added.
- No `print()` usage was added.
- No `Log.add_entry()` usage was added.
