# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0094
- Short Title: Surface Level-2 invariant violations in Customs logs (detection-only)
- Run Folder Name: issue-0094-surface-level2-invariant-violations-customs-logs
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-02-21

---

## Goal
When a Customs inspection reaches Level-2 depth, the game must emit a clear CUSTOMS log summary that reports the presence (or absence) of cross-document invariant violations. This makes Level-2 contradictions legible to the player without introducing enforcement or any new simulation outcomes.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Inspections remain detection-only (no fines, seizures, holds, confiscation, or reputation effects).
- Deterministic behavior is preserved: identical world state produces identical Level-2 audit + identical log content (including ordering).
- No per-frame or loop-driven log spam is introduced; logs are emitted only during explicit inspection resolution.

---

## Non-Goals
Explicitly list what this job must NOT do.  
These are hard scope boundaries.

- No new invariant rules, no changes to Level-2 classification semantics, and no changes to pressure escalation rules.
- No UI changes (no new banners/panels) beyond existing log surfacing.
- No persistence changes / new save fields.

---

## Context
`GameState.run_customs_inspection()` already produces Level-2 audit output at `max_depth >= 2`, including:
- `report["level2_audit"]`
- `report["level2_evidence_flags"]`
- `report["invariant_violations"]` (wired via Customs public API after refactor-0093)

However, the existence and details of `invariant_violations` are not consistently visible to the player unless inspecting report payloads or relying on older log snippets. We need a single, human-readable CUSTOMS log line that summarizes Level-2 invariant contradictions during inspection resolution.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).  
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements.

- During `run_customs_inspection()` when `max_depth >= 2`, emit one CUSTOMS log entry summarizing Level-2 invariant status.
- If `report["invariant_violations"]` is empty: log “no Level-2 invariant violations”.
- If non-empty: log count plus top-N (small cap) violation codes/messages in deterministic order.
- Ensure formatting is stable and concise; do not duplicate large payloads into logs.
- Do not change the audit engine, evidence flags, classification, or pressure escalation behavior.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `res://singletons/GameState.gd`
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

- N/A

---

## Public API Changes
List any new or modified public methods, signals, or resources.  
If none, write “None”.

- None.

---

## Data Model & Persistence
Required if this job adds or modifies saved state **or introduces new required in-memory fields**.

- New or changed saved fields:
  - None
- Migration / backward-compat expectations:
  - Fully backward compatible
- Save/load verification requirements:
  - None

---

## Determinism & Stability (If Applicable)
- What must be deterministic?
  - The invariant violation summary log content (including ordering and top-N selection) must be deterministic for identical state.
- What inputs must remain stable?
  - `level2_context`, `level2_audit`, and `report["invariant_violations"]` ordering as produced by the audit engine.
- What must not introduce randomness or time-based variance?
  - No RNG, no timestamps, no floating ordering of dictionary iteration; any selection must use stable ordering.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] When an inspection runs with `max_depth >= 2`, exactly one CUSTOMS log entry is emitted summarizing Level-2 invariant status.
- [ ] If invariant violations exist, the log includes: count + a deterministic top-N list of violation identifiers/messages.
- [ ] If no invariant violations exist, the log explicitly states that none were found.
- [ ] No changes occur to Level-2 audit semantics, classification outcomes, or pressure escalation behavior.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Start a run (or load a save), accept a freight contract, and ensure an inspection can trigger at depth >= 2 (system entry / existing deterministic trigger).
2. Perform one scenario with clean documents (expect “no invariant violations” log).
3. Perform one scenario with a known mismatch (e.g., change cargo quantity / mismatch a supporting doc) and trigger the inspection again (expect “N invariant violations: …” log).
4. Re-run the same scenario from the same state (reload) and confirm log wording/order matches exactly.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- `report["invariant_violations"]` missing or non-Array: log a safe fallback (“invariant violations unavailable”) and do not crash.
- Very large findings list: log must cap output (top-N) and avoid excessive verbosity.
- Null/empty docs snapshot: must not crash; log should be safe and concise.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,  
architectural concerns, or future refactors.

- Avoid duplicate logging if inspections already emit other Level-2-related log lines; ensure this is one summary line only.
- Ensure deterministic ordering: do not rely on Dictionary iteration order when formatting.
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
  - `codex/runs/issue-0094-surface-level2-invariant-violations-customs-logs/**`
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
  - `git commit -m "issue-0094: Surface Level-2 invariant violations in Customs logs (detection-only)"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- STOP.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0094-surface-level2-invariant-violations-customs-logs/`
2) Write this job verbatim to `codex/runs/issue-0094-surface-level2-invariant-violations-customs-logs/job.md`
3) Create `codex/runs/issue-0094-surface-level2-invariant-violations-customs-logs/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0094-surface-level2-invariant-violations-customs-logs`

Codex must write final results only to:
- `codex/runs/issue-0094-surface-level2-invariant-violations-customs-logs/results.md`

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
