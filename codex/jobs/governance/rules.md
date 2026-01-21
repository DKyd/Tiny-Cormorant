# Governance Job Rules — Tiny Cormorant

Governance jobs modify **process and policy**, not gameplay.

## Allowed Intent
- Amend governance documents (AGENTS, Codex rules/configs, job templates, README/CONTEXT).
- Add or update job types under `codex/jobs/**`.
- Clarify review gates, scope proof, whitelisting norms, and safe-ops procedures.

## Forbidden Intent
- Any runtime game changes: no modifications to gameplay logic, UI behavior, worldgen, economy, saves, or scenes unless explicitly a separate, non-governance job.
- No “drive-by” refactors or cleanup.

## Scope Discipline
- All changes must be explicitly justified by the governance objective.
- Any new governance rules must be **auditable** and **testable** (i.e., verifiable by reading files and/or running `git` commands).
- Rules must be phrased as MUST / MUST NOT where appropriate.

## Files and New Files
- Modifications are restricted to the whitelist in the active `job.md`.
- New files are only permitted when explicitly listed and limited to governance surfaces (typically `codex/jobs/**` or `docs/**`), never runtime code.

## Outputs
- Codex must write final results only to `codex/runs/<active-job>/results.md`.
- Results must include: summary, files changed, assumptions, and known limitations.

## Review Gate Expectations
- Governance jobs must include clear “before/after” policy statements.
- Gate B approvals must include scope proof (`git status`, `git diff --stat`, full `git diff`).
