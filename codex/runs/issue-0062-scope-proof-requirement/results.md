# Results: Issue-0062 — Scope Proof Requirement

## Summary of changes and rationale
- Clarified Gate B approvals as invalid when scope proof is missing or incomplete, reinforcing the mandatory scope proof requirement and reducing ambiguity during review.

## Files changed
- `codex/AGENTS.md`: added explicit invalidation language under the Gate B scope proof requirement.
- `codex/runs/ACTIVE_RUN.txt`: updated active run pointer / run metadata (includes line-ending normalization warning in git output).

## Assumptions made
- The existing Gate B section already required `git status`, `git diff --stat`, and full `git diff` as scope proof artifacts.

## Known limitations / TODOs
- None.
