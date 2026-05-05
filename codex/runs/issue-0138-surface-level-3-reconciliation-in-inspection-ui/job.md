# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0138
- Short Title: Surface Level 3 reconciliation in inspection UI
- Run Folder Name: issue-0138-surface-level-3-reconciliation-in-inspection-ui
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-05-05

---

## Goal
Surface the existing `level3_reconciliation` report in the Customs inspection UI as display-only information. The player should be able to understand clean, suspicious, not-evaluable, absent, and malformed Level 3 reconciliation states without changing helper semantics, pressure, logs, or enforcement.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Level 3 UI surfacing must be display-only.
- No runtime inspection, pressure, scrutiny, log, cargo, credit, document, save/load, travel, or enforcement behavior may change.
- Level 2 quantity/cargo reconciliation must remain policy-disabled.
- The UI must not call `CustomsLevel3Reconciliation` directly; it only renders `report["level3_reconciliation"]` if present.
- Existing Level 1 and Level 2 inspection UI behavior must continue to work.
- No fines, seizures, holds, cargo denial, travel blocking, reputation effects, physical inspections, or forced offloads may be introduced or implied.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- Do not change `Customs.gd`, `GameState.gd`, `CustomsLevel3Reconciliation.gd`, or validation harness behavior.
- Do not add pressure/scrutiny effects from Level 3 findings.
- Do not add logs or new inspection triggers.
- Do not add container class generation, helper semantics, data primitives, or reconciliation policy changes.
- Do not perform broad UI redesign or visual polish.
- Do not run Desloppify or external audit tooling.

---

## Context
`issue-0136` attached `report["level3_reconciliation"]` to inspection reports when `max_depth >= 3`, with no UI, pressure, logs, or enforcement. `issue-0137` planned UI surfacing and recommended placing Level 3 in the existing Customs inspection panel after the Level 2 section, using display-only wording, safe absent/malformed/not-evaluable fallbacks, and capped finding detail.

The player reaches the panel through:

`Main Menu -> New Game -> Bridge -> Port -> Customs`

The existing panel already displays inspection metadata, reasons, Level 1 surface audit, Level 2 documentary audit details, document summary, and a no-enforcement/pressure-only note. This job should add the Level 3 section only.

---

## Proposed Approach
A short, high-level plan (3-6 bullets).  
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements.

- Add a Level 3 reconciliation section to `CustomsInspectionPanel.tscn` after the existing Level 2 section.
- Update `CustomsInspectionPanel.gd` to render `report["level3_reconciliation"]` if present.
- Display classification/status, summary, capped findings, capped not-evaluable reasons, and a read-only/no-enforcement note.
- Provide safe fallbacks for absent, empty, malformed, or partial payloads.
- Verify the UI does not call helper/runtime mutation APIs and does not alter Level 1/Level 2 rendering.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `scenes/ui/CustomsInspectionPanel.tscn`
- `scripts/ui/CustomsInspectionPanel.gd`
- `codex/runs/ACTIVE_RUN.txt`
- `codex/runs/issue-0138-surface-level-3-reconciliation-in-inspection-ui/job.md`
- `codex/runs/issue-0138-surface-level-3-reconciliation-in-inspection-ui/results.md`

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/**` except `scenes/ui/CustomsInspectionPanel.tscn`
- `scripts/**` except `scripts/ui/CustomsInspectionPanel.gd`
- `singletons/**`
- `.godot/**`
- `.desloppify/**`
- `Documentation/**`
- `project.godot`
- `codex/AGENTS.md`
- `codex/README.md`
- `codex/CONTEXT.md`
- `codex/jobs/**`
- `codex/tools/**`

---

## New Files Allowed?
- [x] Yes (must list exact paths below)
- [ ] No

If Yes, list exact new file paths:

- `codex/runs/issue-0138-surface-level-3-reconciliation-in-inspection-ui/job.md`
- `codex/runs/issue-0138-surface-level-3-reconciliation-in-inspection-ui/results.md`

---

## Public API Changes
List any new or modified public methods, signals, or resources.  
If none, write “None”.

- None.

---

## Data Model & Persistence
Required if this job adds or modifies saved state or introduces new required in-memory fields.

- New or changed saved fields:
  - None.
- Migration / backward-compat expectations:
  - Existing inspection reports without `level3_reconciliation` must render safely.
  - Existing saves are unaffected.
- Save/load verification requirements:
  - Verify no save/load code is modified.

---

## Determinism & Stability (If Applicable)
- What must be deterministic?
  - Rendering order of Level 3 findings and not-evaluable entries should preserve report order or use stable ordering if needed.
- What inputs must remain stable?
  - Existing inspection report payloads, Level 1/Level 2 UI inputs, and `level3_reconciliation` report fields.
- What must not introduce randomness or time-based variance?
  - No RNG, no wall-clock dependence, no helper calls, no state mutation, no log emission, and no runtime recomputation.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] The Customs inspection panel includes a Level 3 reconciliation section after the existing Level 2 section.
- [ ] When `report["level3_reconciliation"]` is present and valid, the section displays classification/status, summary, capped findings, capped not-evaluable entries, and read-only/no-enforcement wording.
- [ ] When `level3_reconciliation` is absent or empty, the section displays a safe fallback and does not crash.
- [ ] Malformed or partial Level 3 payloads display a clear fallback/warning instead of crashing.
- [ ] Existing Level 1 and Level 2 display behavior remains intact.
- [ ] UI code does not call `CustomsLevel3Reconciliation`, `Customs`, `GameState` mutation methods, logging, pressure, save/load, cargo, credit, document, travel, or enforcement APIs.
- [ ] No files outside the whitelist are modified.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Ensure the OneDrive Tiny Cormorant project folder is marked “Always keep on this device.”
2. Open the canonical project in Godot 4.6.1.
3. Start a new game and navigate `Bridge -> Port -> Customs`.
4. Confirm existing inspection metadata, reasons, Level 1 surface audit, Level 2 documentary audit, and document summary still render.
5. In a report with `level3_reconciliation`, confirm the Level 3 section displays status/summary/findings/not-evaluable details in readable text.
6. In a report without `level3_reconciliation`, confirm the Level 3 section shows a safe fallback and does not crash.
7. Confirm viewing the panel does not change cargo, credits, documents, time, pressure, logs, save/load, travel, or enforcement state.
8. Confirm no `.godot/**` churn is staged or committed.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Missing `level3_reconciliation` key.
- Empty `level3_reconciliation` dictionary.
- Missing or non-array `findings`.
- Missing or non-array `not_evaluable`.
- Missing `classification`, `status`, or `summary`.
- Findings/not-evaluable entries containing non-dictionary values.
- Long finding lists; display should cap details and remain readable.
- Level 3 report mostly `not_evaluable` because container class metadata is not yet present.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts, architectural concerns, or future refactors.

- The first UI surfacing may often show `not_evaluable` until container class metadata exists; wording should make this feel like limited evidence, not a crash.
- This is not a full UI polish pass.
- If existing panel layout cannot safely accommodate the section without broader redesign, Codex must stop and report rather than expanding scope.
- If assumptions prove false, Codex must stop and report rather than inventing solutions.

---

## Governance & Review Gates (Mandatory)
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
  B) Run the current issue’s Closeout Gate (stage → staged diff review → commit → push)
- If `git status -sb` shows the branch is behind origin (e.g. `[behind N]`), Codex MUST STOP and instruct `git pull --ff-only` (or stash-or-closeout first if the tree is dirty).
- Codex must not proceed with any implementation until the working tree is clean AND the branch is not behind origin.

## Git Postflight & Closeout Gate (Mandatory)
After implementation is complete, Codex must perform these gates in order:

1) Review Gate (Staged Diff)
- Stage ONLY:
  - `codex/runs/ACTIVE_RUN.txt`
  - `codex/runs/issue-0138-surface-level-3-reconciliation-in-inspection-ui/**`
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
  - Staged set includes files outside ACTIVE_RUN.txt, codex/runs/issue-0138-surface-level-3-reconciliation-in-inspection-ui/**, or job whitelist.
  - Scope/whitelist/blacklist conflict or ambiguous instruction.
- Run:
  - `git commit -m "issue-0138: Surface Level 3 reconciliation in inspection UI"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- STOP.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0138-surface-level-3-reconciliation-in-inspection-ui/`
2) Write this job verbatim to `codex/runs/issue-0138-surface-level-3-reconciliation-in-inspection-ui/job.md`
3) Create `codex/runs/issue-0138-surface-level-3-reconciliation-in-inspection-ui/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0138-surface-level-3-reconciliation-in-inspection-ui`

Codex must write final results only to:
- `codex/runs/issue-0138-surface-level-3-reconciliation-in-inspection-ui/results.md`

Results must include:
- Summary of changes and rationale
- Files changed (with brief explanation per file)
- Assumptions made
- Known limitations or TODOs

---

## Logging Checklist
- [ ] All explicit player actions that succeed or fail emit a clear log entry
- [ ] All time advancement paths log a reason and tick delta
- [x] No UI-only interactions produce log entries
- [x] No per-frame or loop-driven spam was introduced
- [x] Log messages are human-readable
- [x] `print()` usage is debug-only or removed in favor of `Log.add_entry()`
- [x] Log volume feels appropriate for a capped, recent-history log
