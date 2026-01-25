# Results

Summary of changes and rationale:
- Added a deterministic, read-only inspection preview helper in GameState and surfaced it in the Port header to show likelihood and max depth without rolling or mutating state.

Files changed (with brief explanation per file):
- `res://singletons/GameState.gd`: added `get_inspection_preview` to compute bucket-based likelihood and max depth with safe fallbacks.
- `res://scripts/Port.gd`: appended an “Inspection preview” line in the Port header using the preview helper.

Assumptions made:
- Preview max depth is Level 1 until deeper mappings exist.
- Using the pressure bucket label as the qualitative likelihood is acceptable for now.

Known limitations or TODOs:
- Preview reasons are computed but not yet displayed in UI.
