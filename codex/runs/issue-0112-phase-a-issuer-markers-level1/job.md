# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0112
- Short Title: Phase A issuer markers (deterministic placeholders) + Level 1 checks
- Run Folder Name: issue-0112-phase-a-issuer-markers-level1
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-02-23

---

## Goal
Ensure newly created `purchase_order`, `bill_of_sale`, and `contract` documents always include deterministic issuer placeholders (`issuer_org_id` and `issuer_marker`). Update Level 1 audit checks so missing issuer fields are flagged as INVALID with a clear finding code.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Document creation remains deterministic: issuer fields are derived by stable rules from existing context (no randomness, no wall-clock time).
- Level 1 audit remains non-enforcing: it reports findings without mutating cargo/state or blocking UI actions.
- Existing doc creation behavior remains intact aside from adding issuer fields; no other schema changes are introduced.

---

## Non-Goals
Explicitly list what this job must NOT do.
These are hard scope boundaries.

- Do NOT implement real issuer identity resolution (no reputation systems, no org registry lookups, no dynamic faction logic beyond the minimal deterministic placeholder rule).
- Do NOT modify Level 2 audits/invariants (issue-0109/0111 already handled).
- Do NOT add new UI screens or editor features; this job only adds fields at creation and validates in Level 1.
- Do NOT introduce enforcement, penalties, or inspection trigger changes.

---

## Context
Describe relevant existing systems, scenes, or scripts.
Include what already exists and what is missing.
Do not propose solutions here.

- The project generates freight documents during gameplay (purchase orders for buys, bills of sale for sells, and contracts for contract hauling).
- Under the updated North Star, documents should carry issuer metadata so later audit layers can reason about provenance and legitimacy.
- Currently, issuer fields are absent or inconsistently present, and Level 1 does not reliably flag issuer-metadata omissions.
- Level 1 audit already runs during inspections and should report missing issuer fields as documentary violations.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements. ?? NEW

- Identify the code paths where `purchase_order`, `bill_of_sale`, and `contract` docs are created and persisted into the freightdoc chain snapshot.
- At creation time, set:
  - `issuer_org_id` deterministically using a minimal rule: legal-market docs -> `"government"`, black-market docs -> `"cartel"`.
  - `issuer_marker` deterministically as a stable placeholder string derived from `issuer_org_id` and doc type (no randomness).
- Update Level 1 audit to require presence and non-empty values for `issuer_org_id` and `issuer_marker` on the above doc types.
- Ensure older docs lacking these fields are flagged INVALID by Level 1 (clear code + message), while newly created docs always pass.
- Keep changes confined to creation + Level 1 reporting; do not change inspection triggering or outcomes.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `scripts/customs/CustomsLevel1Audit.gd`
- `singletons/GameState.gd`
- `singletons/Customs.gd`

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

- `codex/runs/issue-0112-phase-a-issuer-markers-level1/job.md`
- `codex/runs/issue-0112-phase-a-issuer-markers-level1/results.md`

---

## Public API Changes
List any new or modified public methods, signals, or resources.
If none, write “None”.

- None

---

## Data Model & Persistence
Required if this job adds or modifies saved state **or introduces new required in-memory fields**. ?? NEW

- New or changed saved fields:
  - `issuer_org_id` (String) added to newly created `purchase_order`, `bill_of_sale`, `contract` docs.
  - `issuer_marker` (String) added to newly created `purchase_order`, `bill_of_sale`, `contract` docs.
- Migration / backward-compat expectations:
  - Existing saves/doc histories will not be migrated; older docs may lack issuer fields and must be reported as Level 1 INVALID if inspected.
- Save/load verification requirements:
  - Create new docs, save, reload, and confirm issuer fields persist and Level 1 passes for newly created docs.

---

## Determinism & Stability (If Applicable) ?? NEW
- What must be deterministic?
  - Issuer fields values on created docs (same inputs -> same outputs).
  - Level 1 finding codes and ordering.
- What inputs must remain stable?
  - Market kind (legal vs black market), doc type, and any existing context fields used to determine issuer.
- What must not introduce randomness or time-based variance?
  - No RNG, no timestamps, no wall-clock reads.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] Newly created `purchase_order`, `bill_of_sale`, and `contract` docs always include non-empty `issuer_org_id` and `issuer_marker`.
- [ ] If a user edits/removes `issuer_org_id` or `issuer_marker` from any of those doc types, Level 1 audit reports INVALID with a clear finding code/message indicating missing issuer fields.
- [ ] Normal gameplay flows (buy/sell/contracts) continue to work unchanged aside from the added doc fields (no new enforcement or blocking).

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Perform a legal buy and legal sell so a `purchase_order` and `bill_of_sale` are created. Inspect the docs and confirm both issuer fields exist and are non-empty.
2. Trigger a Level 1 audit (via a customs inspection). Confirm Level 1 is CLEAN for issuer checks on newly created docs.
3. Using the document editor, delete `issuer_org_id` (or set empty) on a `bill_of_sale` and trigger Level 1 audit again. Confirm Level 1 reports INVALID with a clear issuer-missing finding code.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Older documents lacking issuer fields: Level 1 should flag them deterministically (no crashes).
- Docs with unexpected `doc_type` casing: audit should normalize type comparisons consistently.
- If a creation path lacks a clear legal/black-market classification, Codex must stop and report rather than guessing.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,
architectural concerns, or future refactors.

- Risk: The repo may have multiple doc-creation paths; missing one would lead to inconsistent issuer metadata. Codex must locate and cover all three doc types.
- Risk: “legal vs black market” classification might not be explicitly available at creation sites; if ambiguous, Codex must stop and report.
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
  - `codex/runs/issue-0112-phase-a-issuer-markers-level1/**`
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
  - Staged set includes files outside ACTIVE_RUN.txt, codex/runs/issue-0112-phase-a-issuer-markers-level1/**, or job whitelist.
  - Scope/whitelist/blacklist conflict or ambiguous instruction.
- Run:
  - `git commit -m "issue-0112: Phase A issuer markers (deterministic placeholders) + Level 1 checks"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- STOP.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0112-phase-a-issuer-markers-level1/`
2) Write this job verbatim to `codex/runs/issue-0112-phase-a-issuer-markers-level1/job.md`
3) Create `codex/runs/issue-0112-phase-a-issuer-markers-level1/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0112-phase-a-issuer-markers-level1`

Codex must write final results only to:
- `codex/runs/issue-0112-phase-a-issuer-markers-level1/results.md`

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
