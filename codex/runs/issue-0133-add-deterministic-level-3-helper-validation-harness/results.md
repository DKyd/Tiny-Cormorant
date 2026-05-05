# Results

## Summary
- Added a narrow deterministic validation harness for the standalone Level 3 read-only reconciliation helper.
- The harness calls `CustomsLevel3Reconciliation.build_level3_reconciliation_report(ctx)` directly with literal fixture contexts.
- Covered clean, mismatch, missing docs, missing cargo, unknown commodity/mass, missing tolerance policy, and missing container class cases.
- Kept the harness isolated from live customs/gameplay paths: no `Customs.gd`, `GameState.gd`, UI, pressure, logs, save/load, scenes, project settings, data primitives, or autoloads were modified.
- Added a direct `SceneTree` entry so the harness can be run with Godot `--script`, plus a static `run_validation() -> Dictionary` entry point for manual/editor invocation.

## Files Changed
- `scripts/customs/CustomsLevel3ReconciliationValidation.gd`
  - New isolated validation script.
  - Builds deterministic fixture contexts and calls the Level 3 helper directly.
  - Validates check statuses, expected findings, expected not-evaluable reasons, and repeated-run determinism via canonicalized report signatures.
- `codex/runs/ACTIVE_RUN.txt`
  - Updated active run marker to `issue-0133-add-deterministic-level-3-helper-validation-harness`.
- `codex/runs/issue-0133-add-deterministic-level-3-helper-validation-harness/job.md`
  - Recorded the issue-0133 job instructions verbatim.
- `codex/runs/issue-0133-add-deterministic-level-3-helper-validation-harness/results.md`
  - Recorded implementation notes, verification, assumptions, and limitations.

## Harness Cases
- `clean`
  - Declared and runtime `ore_iron` quantities match.
  - Container class is present.
  - Expects all Level 3 checks to pass and no findings/not-evaluable reasons.
- `mismatch`
  - Declared and runtime quantities differ.
  - Expects quantity and mass checks to fail with `quantity_mismatch` and `mass_delta_exceeds_tolerance`.
- `missing_docs`
  - Omits the docs snapshot.
  - Expects docs, quantity, mass, and container checks to be `not_evaluable`.
- `missing_cargo`
  - Omits the runtime cargo snapshot.
  - Expects cargo, quantity, and mass checks to be `not_evaluable`.
- `unknown_commodity_mass`
  - Uses a fixture-only commodity ID not present in `CommodityDB`.
  - Expects quantity comparison to pass and mass comparison to be `not_evaluable` with `unknown_commodity_mass`.
- `missing_tolerance_policy`
  - Requests a nonexistent tolerance policy ID.
  - Expects tolerance and mass checks to be `not_evaluable`.
  - Current helper semantics report the requested invalid ID as `malformed_tolerance_policy` and the dependent mass check as `missing_tolerance_policy`.
- `missing_container_class`
  - Provides container metadata with a container ID but no container class.
  - Expects commodity quantity/mass checks to pass and container tare check to be `not_evaluable`.

## Verification
- Preflight:
  - branch: `master`
  - `git status --short`: clean before scaffolding
  - recent HEAD: `560f13c issue-0132: Record OneDrive hydration resolution`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`: `issue-0132-triage-godot-headless-validation-crash`
  - `git fetch origin`: completed
  - `git status -sb`: `## master...origin/master`
- Static isolation:
  - `rg "CustomsLevel3ReconciliationValidation" data scripts singletons scenes project.godot`
  - Result: only `scripts/customs/CustomsLevel3ReconciliationValidation.gd` references the validation class.
- Harness side-effect scan:
  - `rg "GameState|Customs\\.|Log\\.add_entry|emit_signal|apply_customs_pressure_increase|add_cargo|remove_cargo|credits|pressure|travel|save|load|run_customs_inspection" scripts/customs/CustomsLevel3ReconciliationValidation.gd`
  - Result: no gameplay/customs/log/save/travel calls; the only match was the helper script name/preload containing `CustomsLevel3Reconciliation`.
- Level 2 policy-disabled check:
  - `rg "policy_disabled_until_level3|L2INV-001" scripts/customs/CustomsInvariants.gd`
  - Result: `L2INV-001` remains present and intentionally `policy_disabled_until_level3`.
- Whitespace:
  - `git diff --check`: passed.
- Godot execution:
  - `where.exe godot`: no Godot executable found on PATH in this shell.
  - Common install-path search for `Godot*.exe` under Program Files and LocalAppData returned no executable.
  - Direct Godot/headless execution was therefore not run from Codex. No project settings, `.godot/**`, autoloads, or scenes were changed to work around this.

## How To Run Manually
From a shell where Godot 4.6.1 is available:

```powershell
godot --headless --path . --script res://scripts/customs/CustomsLevel3ReconciliationValidation.gd
```

The script prints a JSON validation result and exits with code `0` when all cases pass, or `1` if any assertion/determinism check fails.

## Assumptions Made
- `ore_iron` remains a stable fixture commodity with valid `customs_mass_per_unit`.
- `standard_freight_crate` remains a stable fixture container class with valid tare mass.
- A nonexistent fixture policy ID is an acceptable way to exercise the helper's missing/malformed tolerance path without modifying inert data.
- The helper's current aggregate status/classification behavior is the contract under validation. Some missing-data fixtures can still have an overall `pass`/`clean` report when other checks pass, so the harness asserts per-check statuses and not-evaluable reasons for those cases.

## Known Limitations / TODOs
- Codex could not execute Godot validation because `godot` was not available on PATH or in common searched install locations.
- The harness is intentionally narrow and is not a broad test framework.
- The harness does not integrate with live inspections, UI, pressure, logs, save/load, or gameplay.
- Future jobs can add a documented local Godot executable path or wrapper if the project wants Codex-run validation without expanding this job's whitelist.
