Summary of changes and rationale
- Added standardized customs inspection log formatting in GameState so every inspection emits a single, human-readable outcome with optional recommendation text.
- Suppressed legacy customs log lines in Log to prevent duplicate or non-standard messages from older call sites.

Files changed (with brief explanation per file)
- singletons/GameState.gd: format and emit standardized inspection log entry from run_customs_inspection.
- singletons/Log.gd: skip legacy customs log lines to keep one standardized entry per inspection.

Assumptions made
- Existing customs call sites still log legacy messages; suppressing those lines is acceptable when the standardized entry is added.
- Recommended penalty data may be absent or zero; in that case recommendations are omitted.

Known limitations or TODOs
- If future systems add new non-standard customs log messages with different prefixes, they will not be suppressed by the current filter.
- NOTE: Legacy customs log suppression. Revisit if log tagging is introduced.

