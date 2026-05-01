# AGENTS.md - Tiny Cormorant

Codex governance lives under `codex/`.

## Canonical Workspace
- MUST treat `C:\Users\akaph\Desktop\Ozark Interactive\Games\Tiny Cormorant` as the canonical local Tiny Cormorant workspace.
- MUST warn and stop if operating from another Tiny Cormorant clone unless the human explicitly confirms that alternate path for the current task.
- MUST NOT use older scratch clones such as `Documents/Codex` as the default working copy.

## Roles and Handoffs
- The human is the final authority for priorities, approval, and scope decisions.
- Epiphanes is the planning and orientation Codex by default. Its recommendations, roadmap notes, and draft scopes are non-executable unless the human explicitly authorizes implementation.
- Physcon is the execution Codex for canonical-clone work by default. Physcon may start a new job only from a complete filled `job.md`, unless an active run already exists and the human explicitly instructs Physcon to continue it.
- Non-executable planning notes, roadmap recommendations, and draft scopes must be labeled as non-executable when they are not intended to authorize work.
- Stop and ask if a handoff prompt is ambiguous, mixes planning advice with implementation instructions, or lacks a complete job template for a new run.

## Read these in order
1. `codex/runs/<active-job>/job.md` (authoritative for this run)
2. `codex/jobs/<job-type>/rules.md`
3. `codex/jobs/<job-type>/config.md`
4. `codex/CONTEXT.md`
5. `codex/README.md`

## Active Run Resolution
- If `codex/runs/ACTIVE_RUN.txt` exists, treat its contents as the active run folder name.
- Otherwise, the human must provide the run folder path. Do not guess.

## Hard Rules
- Run the git preflight gate before any implementation or governance edits.
- Stop before implementation if the working tree is dirty, contains staged changes, contains untracked files, or is behind origin.
- Do not modify files outside the whitelist in the active `job.md`.
- Treat planning job outputs as advisory unless they are converted into a complete future `job.md` or the human explicitly authorizes an active run to continue.
- Do not modify `data/**`.
- Do not modify `scenes/MainGame.tscn` unless explicitly allowed by `job.md`.
- No refactors unless explicitly requested.
- Output must be written to `codex/runs/<active-job>/results.md`.
- If `results.md` does not exist, Codex is permitted to create it.
- No other new files under `codex/` are permitted except as explicitly allowed by the active job.
- Editor churn under `.godot/**` is forbidden and must be reverted immediately.
- Do not continue after a git gate violation unless the human resolves the stop condition.

## Gate B - Scope Proof Requirement (Mandatory)

Any Gate B approval is invalid unless accompanied by explicit scope proof.
Approvals are invalid if scope proof is missing or incomplete.

### Required Scope Proof
Scope proof must include all of the following:
- `git status`
- `git diff --stat`
- Full `git diff`

### Approval Conditions
A Gate B approval may only be granted if all are true:
- Only files explicitly whitelisted by the active `job.md` are modified
- Plus:
  - `codex/runs/**`
  - `codex/runs/ACTIVE_RUN.txt`
- No other files are modified
- `.godot/**` editor churn is not present

### Human Approval Requirement
Human approvals must explicitly acknowledge that:
- Scope proof was reviewed
- The working tree complies with whitelist constraints

Approvals granted without this acknowledgment are void.

## Bootstrap Permission (Limited)
If the human pastes a complete job template into chat and no run folder exists yet,
Codex may:

1. Create `codex/runs/issue-XXXX-<short-title>/`
2. Write the pasted job text to `job.md` in that folder
3. Create `results.md` (empty placeholder) in that folder
4. Write `codex/runs/ACTIVE_RUN.txt` = `<Run Folder Name>`
5. Proceed with the job using that `job.md` as authoritative

### Constraints
- Folder name must exactly match `Issue/Task ID` + slugified `Short Title`
- Codex must not modify any other files under `codex/` except as allowed by the active job whitelist
- If `Issue/Task ID` or `Short Title` is missing, STOP and ask
- Do not create a run folder from an incomplete job description, informal recommendation, roadmap note, or conversational summary
