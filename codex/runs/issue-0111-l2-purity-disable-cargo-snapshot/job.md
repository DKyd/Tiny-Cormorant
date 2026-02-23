# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0111
- Short Title: Level 2 purity — disable cargo snapshot dependency in L2 invariants
- Run Folder Name: issue-0111-l2-purity-disable-cargo-snapshot
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-02-23

---

## Goal
Make Level 2 audits documentary-only by removing Level 2’s dependency on runtime cargo snapshots. If cargo snapshot data is missing, Level 2 must not degrade to INVALID; instead, the cargo-snapshot-based invariant must be policy-disabled (NOT_EVALUABLE) until Level 3.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Level 2 audit results are driven by documentary coherence (`docs_by_id`) and deterministic rules, not runtime cargo state.
- Level 2 never marks an otherwise coherent documentary chain INVALID solely due to missing cargo snapshot / runtime cargo context.
- Determinism: given the same document chain snapshot and tick, Level 2 produces identical invariant findings and classification (no randomness or wall-clock dependence).

---

## Non-Goals
Explicitly list what this job must NOT do.
These are hard scope boundaries.

- Do NOT change Level 1 audits, issuer fields, or document creation (that is issue-0112).
- Do NOT add enforcement, penalties, cargo mutation, or UI blocking based on Level 2 findings.
- Do NOT refactor the overall Level 2 audit runner beyond the minimum needed to policy-disable the cargo snapshot invariant.
- Do NOT change the meaning of other Level 2 invariants (L2INV-002+), their severities, or their output structure.

---

## Context
Describe relevant existing systems, scenes, or scripts.
Include what already exists and what is missing.
Do not propose solutions here.

- Level 2 audits are built by `Customs.run_level_2_audit(context)` and operate over normalized `docs_by_id` (via `Customs.gd::_normalize_level2_docs_for_audit()`).
- One existing Level 2 invariant (`L2INV-001`) currently compares declared quantities against a cargo snapshot / runtime cargo state.
- Under the updated North Star, Level 2 should be documentary-only; runtime cargo reconciliation belongs in Level 3.
- Current behavior can incorrectly produce INVALID when cargo snapshot is missing or incomplete, even if the documentary chain is coherent.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements. ?? NEW

- Locate the cargo-snapshot-dependent Level 2 invariant (`L2INV-001`) and identify where it reads cargo snapshot/runtime cargo data from the audit context.
- Policy-disable this invariant for Level 2 by returning `STATUS_NOT_EVALUABLE` with a clear `not_evaluable_reason` (e.g., `policy_disabled_until_level3`) rather than FAIL/INVALID.
- Ensure the invariant is deterministic and does not depend on whether the `cargo` field is present in the context.
- Preserve output shape: keep invariant ID, status, severity, and details consistent with other invariants.
- Update any docs/comments in the invariant file to clearly indicate the Level 2 vs Level 3 boundary.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `scripts/customs/CustomsInvariants.gd`
- `scripts/customs/CustomsLevel2Audit.gd`

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/MainGame.tscn`

---

## New Files Allowed?
- [x] Yes (must list exact paths below)
- [ ] No

If Yes, list exact new file paths:

- `codex/runs/issue-0111-l2-purity-disable-cargo-snapshot/job.md`
- `codex/runs/issue-0111-l2-purity-disable-cargo-snapshot/results.md`

---

## Public API Changes
List any new or modified public methods, signals, or resources.
If none, write “None”.

- None

---

## Data Model & Persistence
Required if this job adds or modifies saved state **or introduces new required in-memory fields**. ?? NEW

- New or changed saved fields:
  - None
- Migration / backward-compat expectations:
  - Older saves with incomplete cargo context must not cause Level 2 INVALID solely due to cargo snapshot checks.
- Save/load verification requirements:
  - Load an existing save and run a Level 2 audit at a customs trigger; confirm L2INV-001 is NOT_EVALUABLE (policy-disabled) and other invariants behave unchanged.

---

## Determinism & Stability (If Applicable) ?? NEW
- What must be deterministic?
  - L2INV-001 output must be deterministic and identical regardless of runtime cargo snapshot presence.
- What inputs must remain stable?
  - `docs_by_id`, `tick`, and invariant evaluation ordering.
- What must not introduce randomness or time-based variance?
  - No random numbers, no wall-clock calls, no frame-time dependence.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] Running Level 2 with missing/empty cargo snapshot does NOT produce INVALID due to L2INV-001 (it returns NOT_EVALUABLE with a clear reason).
- [ ] Level 2 results remain driven by documentary coherence; all non-cargo invariants continue to evaluate and report as before.
- [ ] A normal sale/inspection flow still produces CLEAN when documents are coherent (no new failures introduced by this change).

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Load a save, perform a normal legal buy/sell sequence, and trigger a Level 2 audit via an inspection (entry/departure/sale). Confirm Level 2 remains CLEAN when docs are coherent.
2. Trigger a Level 2 audit using a context with missing cargo snapshot (e.g., via an internal/debug call path if available, or by temporarily passing an empty `cargo` field in the inspection context) and confirm:
   - `L2INV-001` is `NOT_EVALUABLE` with reason `policy_disabled_until_level3` (or equivalent).
   - The overall Level 2 classification does not become INVALID solely because of cargo snapshot absence.
3. Confirm other invariants (e.g., L2INV-005..009 from issue-0109) still behave deterministically under the same document edits/tampering.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Cargo snapshot is present but inconsistent: L2INV-001 must still be policy-disabled for Level 2 (NOT_EVALUABLE), not a FAIL.
- Older saves or partial chain snapshots: Level 2 must still evaluate documentary invariants without crashing.
- Audit context missing expected keys: invariant should return NOT_EVALUABLE with clear details, not throw.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,
architectural concerns, or future refactors.

- Risk: Some flows may implicitly rely on L2INV-001 failing to raise pressure/escalation; this job intentionally removes that Level 2 signal and defers it to Level 3.
- Risk: If L2INV-001 currently contributes to overall classification logic, disabling it may change classification; this is intended only insofar as it prevents INVALID due solely to cargo snapshot dependency.
- If assumptions prove false, Codex must stop and report rather than inventing solutions. ?? NEW

---

## Governance & Review Gates (Mandatory) ?? NEW
- Codex must not make code changes until required preflight/review steps are complete.
- Codex must present diffs for review before declaring results final.
- If scope, whitelist, or non-goals are violated, Codex must stop and report the issue.

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
  - `codex/runs/issue-0111-l2-purity-disable-cargo-snapshot/**`
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
  - Staged set includes files outside ACTIVE_RUN.txt, codex/runs/issue-0111-l2-purity-disable-cargo-snapshot/**, or job whitelist.
  - Scope/whitelist/blacklist conflict or ambiguous instruction.
- Run:
  - `git commit -m "issue-0111: Level 2 purity — disable cargo snapshot dependency in L2 invariants"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- STOP.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0111-l2-purity-disable-cargo-snapshot/`
2) Write this job verbatim to `codex/runs/issue-0111-l2-purity-disable-cargo-snapshot/job.md`
3) Create `codex/runs/issue-0111-l2-purity-disable-cargo-snapshot/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0111-l2-purity-disable-cargo-snapshot`

Codex must write final results only to:
- `codex/runs/issue-0111-l2-purity-disable-cargo-snapshot/results.md`

Results must include:
- Summary of changes and rationale
- Files changed (with brief explanation per file)
- Assumptions made
- Known limitations or TODOs

---

## Logging Checklist
- [ ] All explicit player actions that succeed or fail emit a clear log entry
- [ ] All time advancement paths log a reason and tick delta
- [ ] No UI-only interactions produce log entries
- [ ] No per-frame or loop-driven spam was introduced
- [ ] Log messages are human-readable
- [ ] `print()` usage is debug-only or removed in favor of `Log.add_entry()`
- [ ] Log volume feels appropriate for a capped, recent-history log
