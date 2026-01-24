# Results

Summary of changes and rationale:
- Ensured entry clearance checks use a deterministic checkpoint location when not docked, preventing pressure bucket defaults to Low.

Files changed (with brief explanation per file):
- `res://singletons/Customs.gd`: choose a deterministic location id (sorted first in system) when no current location is available, and use it for pressure bucketing and inspection context.

Assumptions made:
- Using the first sorted location id is an acceptable deterministic stand-in for a system entry checkpoint.

Known limitations or TODOs:
- Entry checks still skip systems with no locations.
