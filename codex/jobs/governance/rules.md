# Governance Job Rules - Tiny Cormorant

Governance jobs modify process and policy, not gameplay.

## Canonical Workspace
- The canonical local Tiny Cormorant clone is `C:\Users\akaph\Desktop\Ozark Interactive\Games\Tiny Cormorant`.
- Governance work must default to that clone unless the human explicitly confirms another path for the current task.
- If Codex detects a non-canonical Tiny Cormorant clone, it must warn and stop.
- Older scratch clones, including `Documents/Codex`, must not be treated as the default working copy.

## Allowed Intent
- Amend governance documents (AGENTS, Codex rules or configs, job templates, README, CONTEXT).
- Add or update job types under `codex/jobs/**`.
- Clarify review gates, scope proof, whitelisting norms, safe-ops procedures, and clone-selection rules.

## Forbidden Intent
- Any runtime game changes: no modifications to gameplay logic, UI behavior, world generation, economy, saves, or scenes unless explicitly a separate, non-governance job.
- No drive-by refactors or cleanup.

## Scope Discipline
- All changes must be explicitly justified by the governance objective.
- Any new governance rules must be auditable and testable by reading files and or running `git` commands.
- Rules must be phrased as MUST or MUST NOT where appropriate.
- Governance must keep run-folder bootstrap authority consistent across the active governance surfaces.

## Files and New Files
- Modifications are restricted to the whitelist in the active `job.md`.
- New files are only permitted when explicitly listed and limited to governance surfaces or the active run folder, never runtime code.

## Outputs
- Codex must write final results only to `codex/runs/<active-job>/results.md`.
- Results must include: summary, files changed, assumptions, and known limitations.

## Review Gate Expectations
- Governance jobs must include clear before and after policy statements.
- Gate B approvals must include scope proof (`git status`, `git diff --stat`, full `git diff`).
- Git gate stop conditions must be auditable and machine-detectable where practical.
