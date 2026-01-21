# AGENTS.md — Tiny Cormorant

Codex governance lives under `codex/`.

## Read these in order
1. `codex/runs/<active-job>/job.md` (authoritative for this run)
2. `codex/jobs/<job-type>/rules.md`
3. `codex/jobs/<job-type>/config.json`
4. `codex/CONTEXT.md`
5. `codex/README.md`

## Active run resolution
- If `codex/runs/ACTIVE_RUN.txt` exists, treat its contents as the active run folder name.
- Otherwise, the human must provide the run folder path. Do not guess.

## Hard rules
- Do not modify files outside the whitelist in the active `job.md`.
- Do not modify `data/**`.
- Do not modify `scenes/MainGame.tscn` unless explicitly allowed by `job.md`.
- No refactors unless explicitly requested.
- Output must be written to `codex/runs/<active-job>/results.md`.
- If `results.md` does not exist, Codex is permitted to create it.
- **No other new files under `codex/` are permitted, except as noted below.**
- **Editor churn under `.godot/**` is forbidden and must be reverted immediately.**

### Exception: New files under `codex/jobs/**` (Governance-only)
New files under `codex/jobs/**` are permitted **only** when:
- The active `job.md` explicitly whitelists the exact new file paths, and
- The job is a governance/process job whose stated goal is to update Codex governance assets.

No other new files under `codex/` are permitted.

---

## Gate B — Scope Proof Requirement (Mandatory)

Any Gate B approval is **invalid** unless accompanied by explicit scope proof.

### Required Scope Proof
Scope proof must include **all** of the following:
- `git status`
- `git diff --stat`
- Full `git diff`

### Approval Conditions
A Gate B approval may only be granted if **all** are true:
- Only files explicitly whitelisted by the active `job.md` are modified
- Plus:
  - `codex/runs/**`
  - `codex/runs/ACTIVE_RUN.txt`
- **No other files** are modified
- `.godot/**` editor churn is not present

### Human Approval Requirement
Human approvals must explicitly acknowledge that:
- Scope proof was reviewed
- The working tree complies with whitelist constraints

Approvals granted without this acknowledgment are void.

---

## Bootstrap permission (optional)
If the human pastes a complete job template into chat and no run folder exists yet,
Codex may:

1) Create `codex/runs/issue-XXXX-<short-title>/`
2) Write the pasted job text to `job.md` in that folder
3) Create `results.md` (empty placeholder) in that folder
4) Write `codex/runs/ACTIVE_RUN.txt` = `<Run Folder Name>`
5) Proceed with the job using that `job.md` as authoritative

### Constraints
- Folder name must exactly match `Issue/Task ID` + slugified `Short Title`
- Codex must not modify any other files under `codex/` except as allowed by the active job whitelist
- If Issue/Task ID or Short Title is missing, **STOP and ask**
