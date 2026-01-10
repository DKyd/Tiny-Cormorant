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

- Modify ONLY files listed in **Allowed to Modify**.
- Create NO new files unless explicitly allowed (default: not allowed).
- If the fix requires touching an unlisted file, STOP and request an update to the whitelist.

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
