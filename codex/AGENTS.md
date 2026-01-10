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
- If `results.md` does not exist, Codex is permitted to create it. No other new files under `codex/` are permitted.

## Bootstrap permission (optional)
If the human pastes a complete job template into chat and no run folder exists yet,
Codex may:

1) Create `codex/runs/issue-XXXX-<short-title>/`
2) Write the pasted job text to `job.md` in that folder
3) Create `results.md` (empty placeholder) in that folder
4) Proceed with the job using that `job.md` as authoritative

Constraints:
- Folder name must exactly match `Issue/Task ID` + slugified `Short Title`
- Codex must not modify any other files under `codex/`
- If Issue/Task ID or Short Title is missing, STOP and ask
