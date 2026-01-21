Summary of changes and rationale
- Added a read-only organization presence summary to the Port header derived from existing influence data, presented as descriptive buckets to make influence legible without introducing simulation or authority changes.

Files changed
- scripts/Port.gd: build and render a deterministic org-presence summary in the Port header using influence buckets with graceful fallback when data is missing.

Assumptions made
- Influence data exists and is deterministic.
- Ordering is non-authoritative.

Known limitations / TODOs
- Presentation-only.
- No sorting guarantees.
- No player interaction yet.
