# Results

## Summary of Changes and Rationale
- Added a read-only customs mass accessor to `data/CommodityDB.gd`:
  - `get_customs_mass_per_unit(id, fallback)`
- Added read-only primitive accessors to `data/CustomsReconciliationDB.gd`:
  - `get_all_container_class_ids()`
  - `get_container_class(class_id)`
  - `get_default_container_class()`
  - `get_container_tare_mass(class_id, fallback)`
  - `get_container_max_cargo_mass(class_id, fallback)`
  - `get_all_tolerance_policy_ids()`
  - `get_tolerance_policy(policy_id)`
  - `get_default_tolerance_policy()`
- Accessors return primitive values or duplicated dictionaries and use deterministic empty/fallback behavior for unknown or malformed IDs.
- No gameplay, customs audit, inspection, pressure, UI, cargo, market, contract, document, save/load, autoload, or enforcement path was wired to use these accessors.

## Files Changed
- `data/CommodityDB.gd`
  - Added `get_customs_mass_per_unit(...)` with blank/unknown/missing/malformed/negative fallback handling.
- `data/CustomsReconciliationDB.gd`
  - Added read-only container class and tolerance policy accessors.
  - Dictionary accessors return `duplicate(true)` to prevent callers from mutating source constants.
- `codex/runs/ACTIVE_RUN.txt`
  - Set active run to `issue-0129-add-read-only-reconciliation-primitive-accessors`.
- `codex/runs/issue-0129-add-read-only-reconciliation-primitive-accessors/job.md`
  - Recorded the provided feature job.
- `codex/runs/issue-0129-add-read-only-reconciliation-primitive-accessors/results.md`
  - Recorded closeout notes and verification.

## Verification Performed
- Preflight passed:
  - branch `master`
  - working tree clean before scaffolding
  - `HEAD...origin/master` was `0 0` after `git fetch origin`
- Static accessor wiring check:
  - New accessor names appear only in `data/CommodityDB.gd` and `data/CustomsReconciliationDB.gd` when searching `data`, `scripts`, `singletons`, `scenes`, and `project.godot`.
- Static data/accessor count check:
  - `customs_mass_per_unit` fields: 24
  - commodity accessor refs: 1
  - container class records: 3
  - tolerance policy records: 1
  - duplicate dictionary returns: 2
  - negative numeric literals in `CustomsReconciliationDB.gd`: 0
- Autoload check:
  - `project.godot` has no `CustomsReconciliationDB` reference.
- Level 2 purity check:
  - `scripts/customs/CustomsInvariants.gd` still contains `policy_disabled_until_level3` and the policy-disabled Level 2 quantity consistency path.

## Assumptions Made
- Returning `-1.0` as the default primitive fallback is acceptable because it is explicit, deterministic, and distinguishable from valid non-negative mass/tolerance primitives.
- Returning `{}` for unknown or malformed container class and tolerance policy records is the safest fail-closed dictionary behavior for future callers.
- Static source inspection is sufficient for this job because accessors are not wired into runtime behavior.

## Known Limitations or TODOs
- These accessors are not yet consumed by any Level 3 reconciliation helper.
- No runtime Godot smoke check was run; `issue-0126` recorded a Godot headless engine signal 11, and this job did not need to chase it for static verification.
- Future jobs still need schema validation tests or a read-only reconciliation helper before any gameplay-facing Level 3 behavior exists.

## Logging Checklist
- No explicit player actions were added.
- No time advancement paths were changed.
- No UI-only interactions were added.
- No per-frame or loop-driven log spam was introduced.
- No `print()` usage was added.
