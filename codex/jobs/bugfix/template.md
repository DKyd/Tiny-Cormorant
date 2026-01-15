# Bugfix Job

## Metadata (Required)
- Issue/Task ID:
- Short Title:
- Run Folder Name:            # REQUIRED (e.g. issue-0021-bug-bridge-map-missing)
- Job Type: bugfix
- Author (human):
- Date:

---

## Bug Description
Describe the incorrect behavior and when it occurs.
Focus on observable symptoms, not implementation guesses.

---

## Expected Behavior
Describe what should happen instead.

---

## Repro Steps
Provide the minimal steps required to reproduce the issue reliably.

1.
2.
3.

---

## Observed Output / Error Text
Include exact text if applicable (UI message, error, log line).

---

## Suspected Area (Optional)
List files/systems you believe are involved.
This is a hint, not a directive.

---

## Scope Constraints
- Changes are limited strictly to fixing the described bug.
- No refactors, cleanup, stylistic changes, or redesigns.
- No new features may be introduced.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

-
-

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/MainGame.tscn`

---

## New Files Allowed?
- [ ] Yes (must list exact paths below)
- [x] No

If Yes, list exact new file paths:

-
-

---

## Acceptance Criteria (Must Be Testable)
All items must pass for the fix to be considered complete.

- [ ]
- [ ]
- [ ]

---

## Regression Checks
List behaviors that must still work after the fix.

-
-

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the fix.

1.
2.
3.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/<Run Folder Name>/`
2) Write this job verbatim to `codex/runs/<Run Folder Name>/job.md`
3) Create `codex/runs/<Run Folder Name>/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `<Run Folder Name>`

Codex must write final results only to:
- `codex/runs/<Run Folder Name>/results.md`

Results must include:
- Root cause summary
- Fix summary
- Files changed (and why)
- Manual tests performed
- Regression checks performed
- Remaining risks or follow-ups
