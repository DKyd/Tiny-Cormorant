# Results

## Summary of Changes and Rationale
- Added the first standalone Level 3 read-only reconciliation helper at `scripts/customs/CustomsLevel3Reconciliation.gd`.
- Implemented `class_name CustomsLevel3Reconciliation` and `static func build_level3_reconciliation_report(ctx: Dictionary) -> Dictionary`.
- The helper deep-duplicates input context, normalizes docs/cargo deterministically, reads existing inert Level 3 primitive accessors, and returns a structured report payload.
- The helper remains unwired: no live gameplay, inspection, UI, pressure, logging, save/load, cargo, market, contract, or document path calls it.
- The helper uses only `clean`, `suspicious`, and `not_evaluable` classifications; it does not define or return `invalid`.

## Files Changed
- `scripts/customs/CustomsLevel3Reconciliation.gd`
  - New static helper for Level 3 report-only reconciliation.
  - Provides deterministic docs/cargo normalization, quantity comparison, mass/tolerance comparison, container/tare not-evaluable reporting, sorted checks/findings/not-evaluable entries, and context echo.
  - Uses only existing read-only accessors from `CommodityDB` and `CustomsReconciliationDB`.
- `codex/runs/ACTIVE_RUN.txt`
  - Set active run to `issue-0131-implement-level-3-read-only-reconciliation-helper`.
- `codex/runs/issue-0131-implement-level-3-read-only-reconciliation-helper/job.md`
  - Recorded the provided feature job.
- `codex/runs/issue-0131-implement-level-3-read-only-reconciliation-helper/results.md`
  - Recorded closeout notes and verification.

## Report Shape Implemented
`build_level3_reconciliation_report(ctx)` returns:
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

Implemented report-only cases include:
- clean quantity/mass match
- declared/runtime quantity mismatch
- mass delta beyond tolerance
- missing docs
- missing cargo
- missing declaration docs or quantities
- unknown commodity/customs mass
- missing or malformed tolerance policy
- missing container metadata, container class ID, or unknown container class

## Verification Performed
- Preflight passed:
  - branch: `master`
  - working tree clean before scaffolding
  - HEAD before this job: `483af5a issue-0130: Plan Level 3 read-only reconciliation helper`
  - `HEAD...origin/master` was current after `git fetch origin`
- Static API checks:
  - `scripts/customs/CustomsLevel3Reconciliation.gd` contains `class_name CustomsLevel3Reconciliation`.
  - It exposes `static func build_level3_reconciliation_report(ctx: Dictionary) -> Dictionary`.
- Static runtime-wiring check:
  - `rg "CustomsLevel3Reconciliation|build_level3_reconciliation_report" data scripts singletons scenes project.godot`
  - Matches were only in `scripts/customs/CustomsLevel3Reconciliation.gd`.
- Static side-effect check:
  - Searched the new helper for logging, signal, cargo mutation, pressure mutation, Level 2 pressure recording, credit mutation, travel, save/load, RNG, time, and OS calls.
  - No forbidden side-effect calls were found.
- Level 2 policy check:
  - `scripts/customs/CustomsInvariants.gd` still contains `policy_disabled_until_level3`.
- Scope/checksum checks:
  - `git diff --check` passed.
  - `git status --short` showed only the new helper, active run files, and `ACTIVE_RUN.txt`.
- Godot runtime/parse attempt:
  - Attempted Godot 4.6.1 console headless execution with the known local binary.
  - The engine crashed with signal 11 before producing useful parse or direct-call validation.
  - No `.godot/**`, `.uid`, or other forbidden repo churn appeared after the crash.

## Assumptions Made
- A standalone static helper can read inert data/accessor scripts directly with `preload(...)` without making those primitives live gameplay dependencies, because no runtime caller was added.
- Missing runtime `container_meta.container_class_id` should make container/tare checks `not_evaluable`; the helper does not silently default runtime containers to a class.
- Unknown requested tolerance policy IDs are treated as malformed/not evaluable instead of suspicious or invalid.
- Aggregate report status may remain `pass` when quantity/mass checks pass but optional container/tare checks are `not_evaluable`; the not-evaluable details remain explicit in the payload.

## Known Limitations or TODOs
- Direct helper-call validation could not be completed in this shell because the Godot 4.6.1 console binary crashed with signal 11.
- No scenario harness was added by design; a future validation job should add deterministic direct-call coverage before live inspection integration.
- Runtime freight container metadata still lacks `container_class_id`, so container/tare checks will usually report `not_evaluable` unless the caller supplies `container_class_by_doc_id`.
- The helper is intentionally not integrated into `Customs.gd`, `GameState.gd`, UI, logs, pressure, or gameplay.

## Logging Checklist
- No explicit player actions were added.
- No time advancement paths were changed.
- No UI-only interactions were added.
- No per-frame or loop-driven log spam was introduced.
- No `print()` usage was added.
- No `Log.add_entry()` usage was added.
