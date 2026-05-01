# Planning Job Rules - Tiny Cormorant

Planning jobs modify planning artifacts and governance-facing sequencing output, not runtime behavior.

## Allowed Intent
- Reconcile roadmap state, milestone boundaries, or sequencing strategy.
- Define candidate executable jobs, dependencies, risks, and verification approach.
- Evaluate safe implementation boundaries without authorizing runtime changes.
- Translate governance, roadmap, or external-audit inputs into non-executable planning output.

## Forbidden Intent
- Any runtime game changes: no modifications to gameplay logic, UI behavior, world generation, economy, saves, tests, or scenes.
- No direct implementation of feature, bugfix, refactor, or governance changes unless a separate active job explicitly authorizes them.
- No treating planning notes, candidate jobs, or roadmap entries as executable scope by themselves.

## Advisory Output Rule
- Planning outputs are advisory until converted into complete future `job.md` templates or explicit active-run instructions.
- Candidate jobs must be written as proposals, not executable authorization.
- If a planning prompt drifts into implementation, Codex must stop and ask or require a separate executable job.

## Safe Job Sizing
- Planned executable work should default to the smallest reviewable unit that can pass preflight, staged diff review, and closeout cleanly.
- Split work when it crosses job type boundaries, touches unrelated systems, mixes refactor with feature delivery, or requires a broad whitelist.
- Prefer one capability slice per executable job.
- High-risk work should be decomposed into validation or plumbing jobs before behavior-changing jobs when practical.

## Required Planning Dimensions
Where practical, planning jobs should define:
- capability or milestone target
- dependencies and blockers
- candidate job sequence
- risk level
- likely whitelist sketch
- verification strategy
- explicit non-goals

## Files and New Files
- Modifications are restricted to the whitelist in the active `job.md`.
- New files are only permitted when explicitly listed, typically in the active run folder or other planning surfaces allowed by the job.

## Outputs
- Codex must write final results only to `codex/runs/<active-job>/results.md`.
- Results should capture the planning decisions made, candidate jobs proposed, assumptions, and unresolved risks.
