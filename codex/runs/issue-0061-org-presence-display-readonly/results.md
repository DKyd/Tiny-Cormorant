Summary of changes and rationale
- Added a read-only "Org presence" line to the Port header derived from deterministic influence data.

Files changed
- scripts/Port.gd: renders org presence summary with Trace/Present/Dominant buckets and friendly names for known org IDs.

Assumptions made
- GameState.get_location_effective_influences(location_id) exists and returns an Array of Dictionaries with keys `org_id` and `weight`.
- Galaxy.ORG_ID_GOVERNMENT and Galaxy.ORG_ID_CARTEL exist.

Known limitations / TODOs
- Presentation-only; no gameplay effects.
- Bucket thresholds may be tuned later.
- Unknown org IDs are displayed via a safe fallback (capitalized id).
