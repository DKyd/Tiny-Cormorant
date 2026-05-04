# Results

## Summary of Changes and Rationale
- Added an explicit inert customs-owned commodity mass primitive, `customs_mass_per_unit`, to every commodity in `data/CommodityDB.gd`.
- Seeded `customs_mass_per_unit` by mirroring each commodity's existing `weight_per_unit` value.
- Preserved existing `weight_per_unit` values and their current cargo-capacity semantics.
- Did not wire the new field into gameplay, inspections, pressure, UI, save/load, market, cargo, contracts, documents, or enforcement.

## Files Changed
- `data/CommodityDB.gd`
  - Added `customs_mass_per_unit` to all 24 commodity definitions.
  - No helper methods or runtime readers were added.
- `codex/runs/ACTIVE_RUN.txt`
  - Set active run to `issue-0126-add-inert-customs-mass-primitive`.
- `codex/runs/issue-0126-add-inert-customs-mass-primitive/job.md`
  - Recorded the provided feature job.
- `codex/runs/issue-0126-add-inert-customs-mass-primitive/results.md`
  - Recorded closeout notes and verification.

## Verification Performed
- Preflight passed:
  - branch `master`
  - working tree clean before scaffolding
  - `HEAD...origin/master` was `0 0` after `git fetch origin`
- Static field-count check:
  - commodity IDs: 24
  - `weight_per_unit` fields: 24
  - `customs_mass_per_unit` fields: 24
- Static value check:
  - `customs_mass_per_unit` count: 24
  - negative customs mass values: 0
- Runtime wiring check:
  - `rg "customs_mass_per_unit" data scripts singletons scenes project.godot` found references only in `data/CommodityDB.gd`.
- Level 2 purity check:
  - `scripts/customs/CustomsInvariants.gd` still contains `policy_disabled_until_level3` and the policy-disabled Level 2 quantity consistency path.
- Scope check after attempted Godot smoke test:
  - no `.godot/**` churn or other forbidden file changes appeared.

## Godot Smoke Check
- Attempted:
  - Godot 4.6.1 console, headless project launch with `--quit-after 5`
- Observed:
  - the Godot executable crashed with signal 11 before producing useful project-level parse feedback.
- Result:
  - runtime smoke check is inconclusive because the engine process crashed.
  - static checks and scope checks passed.

## Assumptions Made
- Mirroring `weight_per_unit` is acceptable as inert seed data because issue-0126 explicitly permits conservative initialization and future jobs may tune customs mass separately.
- `customs_mass_per_unit` is the clearest local field name for a customs-owned mass-per-unit primitive.
- Adding only table data, with no accessor or validation helper, is safer for this job because it prevents accidental gameplay coupling.

## Known Limitations or TODOs
- Future Level 3 jobs still need container tare weights, tolerance rules, hull/gross/net/measured mass policy, and read-only reconciliation helpers.
- `customs_mass_per_unit` is not yet validated by a runtime helper; this job relied on static inspection.
- The Godot headless smoke check crashed in the engine process and should be retried manually or in a later validation job if runtime confirmation is required.

## Logging Checklist
- No new explicit player actions were added.
- No time advancement paths were changed.
- No UI-only interactions were added.
- No per-frame or loop-driven log spam was introduced.
- No `print()` usage was added.
