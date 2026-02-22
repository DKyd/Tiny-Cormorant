# Bugfix Job

## Metadata (Required)
- Issue/Task ID: issue-0106
- Short Title: Fix Level 2 ctx doc typing so declaration-like docs are evaluable
- Run Folder Name: issue-0106-bug-l2-ctx-doc-typing-missing-declaration-docs
- Job Type: bugfix
- Author (human): Douglass Kyd
- Date: 2026-02-22

---

## Bug Description
When a customs inspection reaches **Level 2 depth**, `level2_audit` is present and invariants are emitted, but key invariants remain `not_evaluable` even in a deliberate **doc vs cargo quantity mismatch** scenario. Diagnostics (issue-0105) show:

- `L2INV-001[not_evaluable/none:missing_declaration_docs]`
- `L2INV-003[not_evaluable/none:missing_comparable_timestamps]`

This indicates the Level 2 evaluation context (`ctx`) passed into `CustomsInvariants.evaluate(ctx)` does not provide documents in the expected typed/bucketed form (e.g., `docs.declaration_or_purchase_order`), so invariants cannot locate “declaration-like” documents to compare against cargo.

---

## Expected Behavior
When Level 2 depth is reached, the Level 2 audit context must include documents in a shape that allows invariants to evaluate:

- L2INV-001 should no longer be `not_evaluable:missing_declaration_docs` when FreightDocs exist.
- In a doc-vs-cargo qty mismatch, L2INV-001 should become evaluable and produce a failure finding (or, at minimum, advance to a more specific not-evaluable reason such as missing quantities rather than missing docs entirely).
- The change must remain deterministic and must not introduce enforcement or state mutation.

---

## Repro Steps
Provide the minimal steps required to reproduce the issue reliably.

1. Accept a contract so a FreightDoc is created (e.g., `FDOC-0001`) and modify it to produce a doc-vs-cargo quantity mismatch.
2. Trigger an entry clearance inspection that reaches Level 2 depth.
3. Observe Level 2 invariant diagnostic samples showing `missing_declaration_docs`.

---

## Observed Output / Error Text
Example:
`Level-2 invariants: none found (level2_audit present; invariants=4, findings=0, sample=L2INV-001[not_evaluable/none:missing_declaration_docs], ...).`

---

## Suspected Area (Optional)
- `res://singletons/Customs.gd`
  - `run_level_2_audit()` builds `ctx["docs"]` from `GameState.get_freightdoc_chain_snapshot()`, but may be passing docs in a non-typed/non-bucketed schema that invariants don’t recognize.

---

## Scope Constraints
- Changes are limited strictly to fixing the described bug.
- No refactors, cleanup, stylistic changes, or redesigns.
- No new features may be introduced.
- Do NOT modify invariant definitions/logic (CustomsInvariants.gd) in this job.
- Do NOT change triggers, inspection depth selection, enforcement, cargo/docs state, or time advancement.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `res://singletons/Customs.gd`

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

- [ ] In the doc-vs-cargo qty mismatch repro, L2INV-001 is no longer `not_evaluable:missing_declaration_docs`.
- [ ] Level 2 ctx remains deterministic: same save/state ? same invariant statuses and ordering.
- [ ] No enforcement/state mutation: Level 2 audit remains read-only and does not alter cargo, credits, docs, or time beyond existing inspection behavior.

---

## Regression Checks
List behaviors that must still work after the fix.

- Level 1 inspection behavior is unchanged.
- Level 2 audit payload still attaches to the report (`report["level2_audit"]`) and diagnostic logging remains readable.
- Existing “policy disabled” invariant (L2INV-002) remains not evaluable by design.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the fix.

1. Reproduce the doc-vs-cargo quantity mismatch scenario and trigger a Level 2 entry clearance inspection.
2. Confirm the Level 2 diagnostic sample no longer shows `missing_declaration_docs` for L2INV-001.
3. Confirm that with a real qty mismatch, L2INV-001 becomes evaluable and yields a failure finding (and classification updates accordingly), or that it progresses to a more specific not-evaluable reason (e.g., missing quantities) rather than missing docs.
4. Repeat from the same save twice to confirm determinism (same sample ordering and reasons).

---

## Git Preflight Gate (Mandatory)
Before ANY code changes, Codex must run and report:

- `git branch --show-current`
- `git status --short`
- `git log --oneline -n 5 --decorate`
- `git show HEAD:codex/runs/ACTIVE_RUN.txt`
- `git fetch origin`
- `git status -sb`
- Preferred wrapper: `powershell -ExecutionPolicy Bypass -File codex/tools/git_gates.ps1 -Mode Preflight`

Rules:
- If `git status --short` is not empty (modified OR untracked files), Codex MUST STOP and ask the user to choose ONE:
  A) Stash WIP (must include untracked): `git stash push -u -m "wip: <short description>"`
  B) Run the current issue’s Closeout Gate (stage ? staged diff review ? commit ? push)
- If `git status -sb` shows the branch is behind origin (e.g. `[behind N]`), Codex MUST STOP and instruct `git pull --ff-only` (or stash-or-closeout first if the tree is dirty).
- Codex must not proceed with any implementation until the working tree is clean AND the branch is not behind origin.

## Git Postflight & Closeout Gate (Mandatory)
After implementation is complete, Codex must perform these gates in order:

1) Review Gate (Staged Diff)
- Stage ONLY:
  - `codex/runs/ACTIVE_RUN.txt`
  - `codex/runs/<Run Folder Name>/**`
  - Whitelisted files for this job
- Then show:
  - `git diff --stat --staged`
  - `git diff --staged`
- Show staged diffs, then auto-closeout unless a gate violation is detected.
- STOP and request user input only if a gate violation or ambiguity is detected.

2) Closeout Gate (Commit + Push)
- If all gates pass and the staged set is whitelist-clean, Codex MUST auto-run closeout immediately (no explicit approval required).
- STOP conditions (user input required):
  - Working tree is dirty.
  - Branch is behind origin.
  - Staged set includes files outside ACTIVE_RUN.txt, codex/runs/<Run Folder Name>/**, or job whitelist.
  - Scope/whitelist/blacklist conflict or ambiguous instruction.
- Run:
  - `git commit -m "<Issue/Task ID>: <Short Title>"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- STOP.

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
