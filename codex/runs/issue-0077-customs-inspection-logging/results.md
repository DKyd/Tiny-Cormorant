# Results

Summary of changes and rationale:
- Added consistent player-facing Customs inspection logs for entry, legal sale, and departure inspections, using safe fallbacks for system/location names and classification.

Files changed (with brief explanation per file):
- `res://singletons/Customs.gd`: added helpers to format location labels and emit standardized inspection logs, and used them for entry/sale/departure inspections.

Assumptions made:
- Using `CUSTOMS:` log prefixes avoids the existing log skip filters while keeping category inference intact.

Known limitations or TODOs:
- None.
