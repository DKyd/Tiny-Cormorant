# Results

## Summary
- Added a first-class `planning/` job type under `codex/jobs/` with `template.md`, `rules.md`, and `config.md`.
- Formalized planning jobs as non-runtime and non-executable by themselves unless their outputs are converted into complete future `job.md` templates or explicit active-run instructions.
- Added safe job sizing guidance so future roadmap and milestone work defaults to smaller, reviewable, whitelist-bound executable jobs.

## Files Changed
- `codex/AGENTS.md`: recognized planning outputs as advisory and preserved executable authority boundaries.
- `codex/README.md`: registered `planning/` as a valid job type and added routing guidance for roadmap, milestone, and job-sequencing work.
- `codex/jobs/planning/template.md`: created the planning job template with milestone, dependency, candidate-job, risk, whitelist-sketch, verification, and non-goal fields.
- `codex/jobs/planning/rules.md`: created planning rules covering advisory output, forbidden runtime implementation, and safe job sizing split criteria.
- `codex/jobs/planning/config.md`: created planning defaults and recommended planning-output fields.
- `codex/runs/ACTIVE_RUN.txt`: pointed the active run to `issue-0118-add-planning-job-type-and-safe-job-sizing-policy`.
- `codex/runs/issue-0118-add-planning-job-type-and-safe-job-sizing-policy/job.md`: recorded the job specification verbatim.
- `codex/runs/issue-0118-add-planning-job-type-and-safe-job-sizing-policy/results.md`: recorded this closeout.

## Verification
- Ran the required preflight in the canonical clone before editing; the working tree was clean and not behind origin.
- Confirmed only the whitelisted governance and run files changed.
- Verified that `planning/template.md`, `planning/rules.md`, and `planning/config.md` define non-runtime planning work, advisory outputs, and safe job sizing guidance.
- Verified that `codex/AGENTS.md` and `codex/README.md` now recognize `planning/` as a valid job type.

## Assumptions
- Planning jobs should remain non-runtime by default even when they consume roadmap or external-audit inputs.
- Safe job sizing guidance is a default planning rule and does not override stricter existing governance gates.

## Limitations
- This job adds the planning job type and sizing policy only. It does not reconcile roadmap content or generate future candidate jobs outside this run folder.
