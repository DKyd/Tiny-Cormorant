Codex — follow-up patch for Port header inspection preview line (minimal, formatting-only)

Scope: Keep the new Port header “Inspection preview …” line, but make it robust and clearly advisory. Do NOT change inspection logic or add new UI elements beyond the single line already introduced.

Whitelist (only files allowed):
- res://scripts/Port.gd

Required changes:

1) Fail-closed rendering:
- If `preview.get("ok", false)` is not true, render:
  "Inspection preview: Unknown"
  (no max depth text in this failure case)
- Otherwise render the current format (Likelihood + Max depth).

2) Normalize likelihood string:
- `preview_likelihood` must be `String(...).strip_edges()`, and if it becomes empty, use "Unknown".

3) Make it explicitly advisory:
- Prefix the line with "Inspection preview (advisory):" instead of "Inspection preview:"
- Keep the rest of the wording as close as possible.

Do NOT:
- Add tooltips, new labels, or multi-line UI.
- Change any other Port header content.
- Add logs.

Process / governance:
- Create run folder: codex/runs/issue-0078b-port-header-inspection-preview-line/
- Write this prompt into job.md, set ACTIVE_RUN.txt accordingly.
- Show `git diff --stat` and full `git diff` for approval.
- Record results in results.md only.
