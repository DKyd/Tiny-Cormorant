# Results: issue-0056-worldgen-organization-influence-assignment-black-market-threshold

## Summary
- Added deterministic organization influence fields to generated locations (base + delta influences).
- Implemented influence aggregation queries and a black market availability check based on cartel influence threshold (>= 0.10).
- Ensured loaded games normalize missing influence arrays to fail closed.

## Files Changed
- singletons/Galaxy.gd
  - Adds ORG_ID constants.
  - Adds base_influences / delta_influences to generated locations.
  - Adds deterministic influence generation and influence maintenance helpers.
- singletons/GameState.gd
  - Adds BLACK_MARKET_CARTEL_THRESHOLD.
  - Adds influence aggregation helpers and location_has_black_market().
  - Normalizes influence arrays on load via Galaxy.ensure_location_influences().

## Assumptions Made
- Organization IDs are currently hard-coded as "government" and "cartel" (no org roster resource yet).
- OUTLAW is detected via location fields outlaw/is_outlaw or tags containing "outlaw".
- Influence weights are additive (base + delta) and not normalized.

## Known Limitations / TODOs
- No UI gating is included in this job (should be a follow-up issue, e.g. issue-0057).
- No “org roster” data model exists yet; influence uses placeholder org IDs.
- No location-level influence debugging UI exists yet.
