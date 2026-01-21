# Governance Job

## Metadata (Required)
- Issue/Task ID:
- Short Title:
- Run Folder Name:
- Job Type: governance
- Author (human):
- Date:

---

## Goal
Describe the governance outcome in 1–3 sentences.
Focus on process/policy behavior, not implementation.

---

## Invariants (Must Hold After This Job)
Non-negotiable truths that must remain valid.

-
-
-

---

## Non-Goals
Hard scope boundaries.

-
-

---

## Context
What happened, what risk it created, and why this governance change is needed.
Do not propose solutions here.

---

## Policy Change (Normative)
Write the new rule(s) in MUST / MUST NOT language.

- MUST:
- MUST NOT:

---

## Proposed Approach
High-level plan (3–6 bullets). Boundaries only.

-
-
-

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
- `.godot/**`

---

## New Files Allowed?
- [ ] Yes (must list exact paths below)
- [ ] No

If Yes, list exact new file paths:

-
-

---

## Acceptance Criteria (Must Be Testable)
Objectively verifiable “done.”

- [ ]
- [ ]
- [ ]

---

## Verification Steps (Non-Game)
How a human verifies the governance change (reading files and/or git commands).

1.
2.
3.

---

## Risks / Notes
- If assumptions prove false, Codex must stop and report rather than inventing solutions.

---

## Governance & Review Gates (Mandatory)
- Codex must not make changes until required preflight/review steps are complete.
- Codex must present diffs for review before declaring results final.
- Gate B approvals must include scope proof (`git status`, `git diff --stat`, full `git diff`).
- If scope/whitelist/non-goals are violated, Codex must stop and report the issue.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any changes:

1) Create `codex/runs/<Run Folder Name>/`
2) Write this job verbatim to `codex/runs/<Run Folder Name>/job.md`
3) Create `codex/runs/<Run Folder Name>/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `<Run Folder Name>`

Codex must write final results only to:
- `codex/runs/<Run Folder Name>/results.md`
