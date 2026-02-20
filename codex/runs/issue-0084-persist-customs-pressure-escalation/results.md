## Summary
Implemented save/load continuity for Customs scrutiny escalation using a dedicated per-location field, without changing audit semantics or adding enforcement.

- Added a dedicated scrutiny state field on locations: `customs_scrutiny_delta`.
- Updated escalation writes to increment this dedicated field exactly once per escalation event.
- Mirrored the dedicated field into a tagged `delta_influences` government entry (`source: "customs_scrutiny"`) only when `Galaxy.ORG_ID_GOVERNMENT` is available.
- Persisted only dedicated scrutiny deltas by location in saves via `customs_scrutiny_deltas_by_location`.
- Restored persisted scrutiny deltas on load with backward compatibility (`missing field => {}` / no restored deltas).
- Added bounded load logging: one concise Customs restore line only when at least one location delta is restored.

## Files Changed
- `singletons/GameState.gd`
  - Added dedicated scrutiny constants and helpers:
    - `_get_customs_scrutiny_delta_from_location()` (field-only source of truth)
    - `_set_customs_scrutiny_delta_for_location()` (always sets field; conditionally mirrors tagged influence)
    - `_get_customs_scrutiny_deltas_by_location()`
    - `_restore_customs_scrutiny_deltas_by_location()`
  - Updated `apply_customs_pressure_increase()` to increment dedicated scrutiny and keep mirror deterministic.
  - Extended `save_game()` / `load_game()` with `customs_scrutiny_deltas_by_location` persistence/restore.
  - Added one bounded restore log line when restored count > 0.
- `codex/runs/ACTIVE_RUN.txt`
  - Set active run to `issue-0084-persist-customs-pressure-escalation`.

## New Public APIs
None.

## Manual Test Steps
1. Trigger a Level-2 INVALID escalation at a known jurisdiction and confirm scrutiny increase log appears.
2. Inspect preview at that jurisdiction and note pressure bucket/max depth.
3. Save, quit/reload, then inspect preview at the same jurisdiction.
4. Verify preview continuity matches post-escalation state from step 2.
5. Load a pre-change/older save with no `customs_scrutiny_deltas_by_location` field.
6. Verify load succeeds with baseline behavior and no restore log spam.

## Assumptions Made
- `location_id` keys remain stable for restore targeting.
- `delta_influences` is consumed by existing pressure logic; tagged mirror entries are valid additive influence carriers.
- Scrutiny deltas are bounded to `[0.0, 1.0]` for deterministic, safe restore behavior.

## Known Limitations / Follow-ups
- If jurisdiction IDs from a save are absent in current runtime locations, those entries are ignored.
- Restore currently logs only a count, not per-location detail, to keep log volume bounded.