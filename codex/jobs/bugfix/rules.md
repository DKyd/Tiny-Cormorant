# Bugfix Job Rules (Codex)

Authority order:
1) `codex/runs/<job>/job.md`
2) these rules
3) `codex/CONTEXT.md`
4) `codex/README.md`

---

## Core Rule: Fix Only

- Make the smallest possible change that fixes the bug.
- Do not refactor, rename, reorganize, or “clean up” unrelated code.
- Do not change UI layout or add new features unless explicitly required by the bug description.
- If you discover a deeper issue that requires broader changes, STOP and ask.

---

## File Access Rules

- The `codex/` directory is read-only by default.
- Exception: Codex MAY write to the active run folder only:
  - `codex/runs/<active-job>/job.md`
  - `codex/runs/<active-job>/results.md`
- Codex must NOT modify any other files under `codex/` (including other runs, templates, configs, or governance files).

- Modify ONLY files listed in **Allowed to Modify**.
- If a change requires touching a file outside the whitelist, STOP and ask.

---

## Output Requirements

Update `codex/runs/<job>/results.md` with:
- Root cause (1–3 sentences)
- Fix summary
- Files changed + purpose
- Manual test steps executed
- Regression checks
- Assumptions made
- Follow-ups (if any)

---

## Stop Conditions (Ask Instead of Guess)

Stop and ask if:
- The bug cannot be reproduced from the provided steps
- Multiple plausible fixes exist with tradeoffs
- Fix requires a refactor or a new system
- Fix requires touching files outside the whitelist
