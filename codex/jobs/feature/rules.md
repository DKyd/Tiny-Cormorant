# Feature Job Rules (Codex)

These rules apply to all jobs using `codex/jobs/feature/`.

If any instruction conflicts:
1) `codex/runs/<job>/job.md` overrides everything
2) then these rules
3) then `codex/CONTEXT.md`
4) then `codex/README.md`

---

## Scope & Discipline

- Implement ONLY what is required to satisfy the job’s Acceptance Criteria.
- Do not “clean up” unrelated code. No drive-by refactors.
- Prefer the smallest diff that achieves the goal.
- Do not rename files, nodes, scenes, or APIs unless explicitly required by the job.
- If you discover necessary follow-up work, write it in `results.md` as a recommendation—do not do it automatically.

---

## File Access Rules

- The `codex/` directory is read-only by default.
- Exception: Codex MAY write to the active run folder only:
  - `codex/runs/<active-job>/job.md`
  - `codex/runs/<active-job>/results.md`
- Codex must NOT modify any other files under `codex/` (including other runs, templates, configs, or governance files).

- Modify ONLY files listed in **Allowed to Modify**.
- If a change requires touching a file outside the whitelist, STOP and ask.

### Active Run Resolution
- If `codex/runs/ACTIVE_RUN.txt` exists, treat its contents as the active run folder name.
- Otherwise, STOP and ask the human for the run folder path. Do not guess.

### results.md Creation Exception
- If `results.md` does not exist in the active run folder, you are permitted to create it.
- No other new files may be created under `codex/` beyond `job.md` and `results.md` in the active run folder.

---

## Architecture Rules

- Respect existing project folder intent: `scenes/`, `scripts/`, `singletons/`, `data/`.
- Avoid introducing new global state unless explicitly approved in `job.md`.
- Keep UI as presentation + input; core state changes flow through systems/singletons.
- Do not couple unrelated systems together to “make it work fast”.

---

## GDScript / Godot Style

- Write idiomatic, readable GDScript.
- Prefer explicit names over abbreviations.
- Keep functions small and focused.
- No commented-out code blocks.
- No unused variables or dead code.
- If you add signals or public methods, document them briefly in code comments.

---

## Output Requirements (Must Do)

You must update `codex/runs/<job>/results.md` with:

1. **Summary** (what changed, why)
2. **Files Changed** (each file + purpose)
3. **New Public APIs** (methods/signals/resources)
4. **Manual Test Steps** (copy from job.md, adjusted if needed)
5. **Assumptions Made**
6. **Known Limitations / Follow-ups**

---

## Stop Conditions (Ask Instead of Guessing)

Stop and request clarification if:
- The acceptance criteria are ambiguous or incomplete
- The only apparent solution requires touching forbidden/unlisted files
- You need to invent missing architecture or “choose a design direction”
- You encounter multiple plausible implementations with tradeoffs
- A change risks breaking existing gameplay flows

When stopped, propose 1–2 concrete options with pros/cons.
