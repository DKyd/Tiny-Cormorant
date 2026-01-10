# Bugfix Job

## Metadata
- Issue/Task ID:
- Short Title:
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

-
-

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

## Codex Output Requirements
Codex must write results to:

- `codex/runs/<job>/results.md`

If `results.md` does not exist, Codex is permitted to create it.
No other new files may be created.

Results must include:
- Root cause summary (brief)
- Fix summary
- Files changed (and why)
- Manual test steps performed
- Regression checks performed
- Any remaining risks or follow-ups
