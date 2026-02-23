## Summary of Changes and Rationale
Fixed `codex/tools/git_gates.ps1` so it parses and runs in PowerShell, restoring wrapper-driven preflight/postflight gate execution. Added deterministic Review Gate output helpers so staged diffs are shown consistently.

## Files Changed
- `codex/tools/git_gates.ps1`
  - Fixed `ValidateSet` quoting (`'Preflight'`, `'Postflight'`) to remove parser error.
  - Added `Invoke-GitOptional` helper for non-fatal optional checks.
  - Added `Invoke-ReviewGateDiffs` helper to print staged file list, staged diff stat, and full staged diff.
  - Updated Preflight to show staged review-gate output when staged content exists (or explicit no-staged message).
  - Updated Postflight to always emit Review Gate staged diff output before proof commands.
- `codex/runs/ACTIVE_RUN.txt`
  - Set active run to `issue-0113-fix-git-gates-script`.
- `codex/runs/issue-0113-fix-git-gates-script/job.md`
  - Added job record.
- `codex/runs/issue-0113-fix-git-gates-script/results.md`
  - Added this summary.

## Assumptions Made
- Gate policy expects staged diff visibility during review; script output additions are policy-aligned.
- Existing git commands used by the wrapper remain valid and read-only in this context.

## Known Limitations / TODOs
- None identified for this script-scoped fix.