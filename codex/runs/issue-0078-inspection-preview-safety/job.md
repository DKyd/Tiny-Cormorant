Codex — follow-up patch (format/safety only; NO behavior changes)

Scope: Apply the following minimal edits to the newly-added `GameState.get_inspection_preview(...)` helper. Do not change wording of existing reason strings, do not add new gameplay logic, and do not touch any files outside the whitelist.

Whitelist (only file allowed):
- res://singletons/GameState.gd

Changes to make in `func get_inspection_preview(context: Dictionary = {}) -> Dictionary:`:

1) Type the reasons array:
- Change `var reasons: Array = []` to `var reasons: Array[String] = []`

2) Normalize the pressure bucket so likelihood is never blank:
- After `var bucket: String = get_customs_pressure_bucket(location_id)`, wrap it with `String(...).strip_edges()` and if it ends up empty, set it to `"Unknown"`.
Example intent:
  var bucket: String = String(get_customs_pressure_bucket(location_id)).strip_edges()
  if bucket == "":
      bucket = "Unknown"

3) Keep output stable:
- Keep the existing returned dictionary keys and values exactly the same as today (including `likelihood` == bucket and `max_depth` == 1).
- Keep existing reason strings exactly as written:
  - "Using entry jurisdiction selection."
  - "Using current docked location."
  - "Pressure bucket: %s"

Do NOT:
- Add new fields to the returned dictionary (no `pressure_bucket` key, etc.)
- Add randomness, rolls, or any state mutation.
- Change any other functions.

Process / governance:
- Create run folder: codex/runs/issue-0078-inspection-preview-safety/
- Write this prompt into codex/runs/issue-0078-inspection-preview-safety/job.md
- Set codex/runs/ACTIVE_RUN.txt to: issue-0078-inspection-preview-safety
- Make the change, then present `git diff --stat` and the full `git diff` for review.
- Write final notes only to codex/runs/issue-0078-inspection-preview-safety/results.md (summary, files changed, assumptions, TODOs).
