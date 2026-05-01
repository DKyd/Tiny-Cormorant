# Results

## Summary
- Formalized the role and handoff protocol between the human, Epiphanes, and Physcon across the whitelisted governance files.
- Clarified that Physcon may start a new executable job only from a complete filled `job.md`, unless explicitly continuing an active run.
- Added durable stop-and-ask rules for ambiguous prompts, incomplete job descriptions, and mixed planning-versus-implementation instructions.

## Files Changed
- `codex/AGENTS.md`: added a role and handoff section, plus an explicit ban on bootstrapping from incomplete job descriptions or informal recommendations.
- `codex/README.md`: added handoff rules to the high-level governance workflow and hard rules, distinguishing planning notes from executable authorization.
- `codex/jobs/governance/template.md`: added a mandatory handoff-protocol section and a scaffolding restriction against incomplete job descriptions.
- `codex/jobs/governance/rules.md`: added role definitions, authorization boundaries, and a stop-and-ask rule for ambiguous handoffs.
- `codex/runs/ACTIVE_RUN.txt`: pointed the active run to `issue-0117-formalize-epiphanes-physcon-handoff-protocol`.
- `codex/runs/issue-0117-formalize-epiphanes-physcon-handoff-protocol/job.md`: recorded the job specification verbatim.
- `codex/runs/issue-0117-formalize-epiphanes-physcon-handoff-protocol/results.md`: recorded this closeout.

## Verification
- Ran the required preflight in the canonical clone before editing; the working tree was clean and not behind origin.
- Confirmed changes are limited to the job whitelist and active run files.
- Verified the governance surfaces now define the human, Epiphanes, and Physcon roles, distinguish non-executable planning from executable authorization, and require a complete filled `job.md` for new Physcon jobs.

## Assumptions
- Epiphanes and Physcon are durable role names for the current governance phase and should be treated as governance terms until a later governance job changes them.
- The existing limited bootstrap authority from issue-0115 should remain, but only for complete pasted job templates.

## Limitations
- This job only formalizes the handoff protocol. It does not create the future planning job type or update any roadmap artifacts.
