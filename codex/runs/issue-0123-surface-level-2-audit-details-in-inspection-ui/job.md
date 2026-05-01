# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0123
- Short Title: Surface Level 2 audit details in inspection UI
- Run Folder Name: issue-0123-surface-level-2-audit-details-in-inspection-ui
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-05-01

---

## Goal
Show existing Level 2 documentary audit details in the Customs inspection UI when a report includes a `level2_audit` payload. The player should be able to understand the Level 2 outcome, key findings, and pressure-only consequence boundary without changing audit logic or enforcement behavior.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Level 2 audit semantics, invariant evaluation, classification, triggers, and pressure behavior must not change.
- The UI must remain read-only presentation; it must not mutate cargo, credits, documents, time, scrutiny, pressure, or inspection state.
- No enforcement may be introduced: no fines, seizures, holds, cargo denial, travel blocking, reputation effects, or forced offloads.
- Missing or malformed Level 2 payloads must fail closed with clear UI fallback instead of crashing.
- Existing Level 1 surface audit display must continue to work.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- Do not add, remove, or change Level 2 invariants.
- Do not change `Customs.gd`, `GameState.gd`, pressure escalation, depth bias, inspection chance, inspection triggers, or report generation semantics.
- Do not add Level 3 reconciliation, probable-cause mechanics, physical inspections, or enforcement.
- Do not add new logs for UI-only rendering.
- Do not redesign the whole Customs inspection panel or refactor unrelated UI.

---

## Context
The player can currently reach the Customs inspection panel through:

`Main Menu -> New Game -> Bridge -> Port -> Customs`

The Port `Customs` button calls `GameState.run_customs_inspection(...)` and displays the report in `scenes/ui/CustomsInspectionPanel.tscn` via `scripts/ui/CustomsInspectionPanel.gd`.

The existing panel shows inspection metadata, classification, reasons, a Level 1 surface audit through `SurfaceAuditPanel`, document summary values, and recommended penalty text. The reconciled roadmap says Level 2 documentary audit infrastructure is substantially complete, but player-facing Level 2 surfacing is weaker than the underlying payload.

This job should display the existing `report["level2_audit"]` payload when present. It should use player-readable wording and compact formatting rather than exposing raw object dumps.

---

## Proposed Approach
A short, high-level plan (3-6 bullets).  
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements.

- Add a compact Level 2 documentary audit section to the existing Customs inspection panel.
- Render existing `level2_audit` fields such as classification and findings when present.
- Format findings in stable player-facing text using existing message/summary/details fields where available.
- Show clear fallback text when no Level 2 audit payload is attached, when findings are empty, or when payload shape is malformed.
- Include a pressure-only/no-enforcement boundary note without changing gameplay behavior.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `scenes/ui/CustomsInspectionPanel.tscn`
- `scripts/ui/CustomsInspectionPanel.gd`
- `codex/runs/ACTIVE_RUN.txt`
- `codex/runs/issue-0123-surface-level-2-audit-details-in-inspection-ui/job.md`
- `codex/runs/issue-0123-surface-level-2-audit-details-in-inspection-ui/results.md`

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/MainGame.tscn`
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

- `codex/runs/issue-0123-surface-level-2-audit-details-in-inspection-ui/job.md`
- `codex/runs/issue-0123-surface-level-2-audit-details-in-inspection-ui/results.md`

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
  - Existing saves and reports without `level2_audit` must continue to display safely.
- Save/load verification requirements:
  - None required; this is read-only UI presentation of existing report payloads.

---

## Determinism & Stability (If Applicable)
- What must be deterministic?
  - Display ordering of Level 2 findings should preserve the report payload order or use an explicitly stable ordering if needed.
- What inputs must remain stable?
  - Existing inspection report payloads, including `level2_audit.classification` and `level2_audit.findings`.
- What must not introduce randomness or time-based variance?
  - UI rendering must not roll RNG, inspect wall-clock time, advance game time, or mutate inspection state.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] When an inspection report includes a valid `level2_audit` payload, the Customs inspection panel shows a Level 2 documentary audit section with classification/outcome and findings.
- [ ] When no `level2_audit` payload is attached, the panel shows a safe fallback and does not crash.
- [ ] Malformed or partial Level 2 payloads show a clear fallback/warning instead of crashing.
- [ ] Existing Level 1 surface audit display still renders as before.
- [ ] The UI makes the pressure-only/no-enforcement boundary clear without adding gameplay effects.
- [ ] No audit logic, pressure behavior, triggers, depth selection, cargo, credits, documents, or save/load behavior are changed.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Open the canonical project in Godot 4.6.1.
2. Start a new game.
3. Navigate `Bridge -> Port -> Customs`.
4. Trigger a Customs inspection and confirm the existing inspection metadata, reasons, Level 1 surface audit, and document summary still render.
5. In any scenario where the report includes `level2_audit`, confirm the panel shows Level 2 classification and findings in readable text.
6. In a scenario where no Level 2 audit is attached, confirm the panel shows a safe fallback such as “No Level 2 documentary audit attached” and does not crash.
7. Confirm no cargo, credits, documents, travel, or enforcement state changes occur from viewing the panel.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Missing `level2_audit` key.
- Empty `level2_audit` dictionary.
- Missing or non-array `findings`.
- Findings containing non-dictionary entries.
- Findings with missing `message`, `summary`, `severity`, `status`, `code`, or `invariant_id`.
- Long findings lists should remain readable enough and not prevent the panel from loading.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts, architectural concerns, or future refactors.

- Current runtime validation cannot easily force specific Level 2 outcomes without a harness; implementation should be defensive and verifiable through report-shape inspection plus normal UI smoke testing.
- If existing Level 2 payload fields are too inconsistent to render safely from the UI layer alone, Codex must stop rather than modifying report generation outside the whitelist.
- The existing “Recommended Penalty” UI label may be conceptually stale under the no-enforcement roadmap, but this job should not redesign or remove it unless it directly blocks Level 2 surfacing.
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
  - `codex/runs/issue-0123-surface-level-2-audit-details-in-inspection-ui/**`
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
  - Staged set includes files outside ACTIVE_RUN.txt, codex/runs/issue-0123-surface-level-2-audit-details-in-inspection-ui/**, or job whitelist.
  - Scope/whitelist/blacklist conflict or ambiguous instruction.
- Run:
  - `git commit -m "issue-0123: Surface Level 2 audit details in inspection UI"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- STOP.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0123-surface-level-2-audit-details-in-inspection-ui/`
2) Write this job verbatim to `codex/runs/issue-0123-surface-level-2-audit-details-in-inspection-ui/job.md`
3) Create `codex/runs/issue-0123-surface-level-2-audit-details-in-inspection-ui/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0123-surface-level-2-audit-details-in-inspection-ui`

Codex must write final results only to:
- `codex/runs/issue-0123-surface-level-2-audit-details-in-inspection-ui/results.md`

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
