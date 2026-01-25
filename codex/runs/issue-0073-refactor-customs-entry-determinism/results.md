# Results

## Summary of refactor
- Added **entry-jurisdiction selection** helper to `GameState` that deterministically chooses the **highest-pressure location** in a system (lexicographic tie-break).
- Added **deterministic inspection roll** helper to `GameState` for customs inspection attempts (no global RNG).
- Refactored `Customs` system entry checks to delegate jurisdiction selection and roll to `GameState`, removing duplicated selection logic and eliminating `randf()` usage.

## Files changed
- `res://singletons/GameState.gd`
- `res://singletons/Customs.gd`

## Manual test results
- Not run (not requested).

## Confirmation behavior is unchanged
- Inspection execution, reporting, and document evaluation remain unchanged.
- The only intentional deltas are:
  - entry jurisdiction now follows North Star: **highest-pressure location** (deterministic tie-break)
  - inspection attempt rolls are now **deterministic/seeded** (no global RNG)

## Follow-ups / known gaps
- None.
