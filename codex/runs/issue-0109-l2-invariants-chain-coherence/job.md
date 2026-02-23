# Feature Job

## Metadata (Required)
- Issue/Task ID: issue-0109
- Short Title: Level 2 audit — add chain-coherence invariants (sources + oversell)
- Run Folder Name: issue-0109-l2-invariants-chain-coherence
- Job Type: feature
- Author (human): Douglass Kyd
- Date: 2026-02-23

---

## Goal
Extend the Level 2 customs audit engine by adding documentary chain-coherence invariants for bill-of-sale sourcing and oversell prevention, implemented inside `CustomsInvariants.gd`. These checks must cover North Star §7/§12 using Level 2 invariant failures (with clear codes + severities) so tampering becomes detectable via the real Level 2 path.

---

## Invariants (Must Hold After This Job)
These are non-negotiable system truths that must remain valid.

- Level 2 remains documentary-only: evaluation uses documents and their internal fields, not cargo snapshots or runtime cargo state.
- Level 2 findings are reported exclusively via invariant results (no enforcement, no cargo mutation, no blocking UI).
- Level 2 determinism: identical saved state + actions produce identical invariant findings (no randomness, no real-time dependence).

---

## Non-Goals
Explicitly list what this job must NOT do.
These are hard scope boundaries.

- Do NOT refactor the Level 2 engine, audit runner, or document schemas beyond what is strictly necessary to add invariants.
- Do NOT change gameplay outcomes (no penalties, seizures, market blocking, port blocking, or cargo edits); this job only adds invariant reporting.
- Do NOT add/modify Level 1 checks or issuer fields (that is issue-0112).
- Do NOT remove or deprecate any legacy Level 2 audit path (that is issue-0110).
- Do NOT change or disable the cargo snapshot invariant (that is issue-0111).

---

## Context
Describe relevant existing systems, scenes, or scripts.
Include what already exists and what is missing.
Do not propose solutions here.

- The project has a Level 2 customs audit system that evaluates documentary coherence via invariant checks and produces structured findings with invariant IDs/codes and severities.
- Some valuable chain-coherence checks exist conceptually (and/or in non-L2 paths) around bill-of-sale sources, matching totals, ensuring sources are valid/non-destroyed, and preventing aggregate oversell by source/commodity.
- These checks must be moved/implemented as true Level 2 invariants in `CustomsInvariants.gd` so the single Level 2 engine produces the findings required by North Star §7/§12.
- Bills of sale are expected to reference “source” documents for each sold line item (or per commodity) and those sources represent provenance for the sold quantity.

---

## Proposed Approach
A short, high-level plan (3–6 bullets).
Describe intent and boundaries only. This section does not authorize additional features, refactors, or speculative improvements.

- Add new Level 2 invariant functions (IDs 005+) in `CustomsInvariants.gd` that validate bill-of-sale source presence, source qty totals, source doc validity, source doc destruction status, and aggregate sold-by-source not exceeding available.
- Use existing document access helpers and the Level 2 invariant reporting format to emit failures as `fail` with severity `invalid` or `suspicious`, with clear invariant codes per failure reason.
- Ensure invariants operate purely on documentary state: bill-of-sale lines, their declared quantities, and referenced source docs (and source doc line quantities / remaining availability fields as defined by current data model).
- Add/extend minimal invariant test fixtures in the run folder (or existing L2 audit test harness if present) that demonstrate “clean” sales and “tampered” edits producing deterministic findings.
- Keep changes tightly scoped to adding invariants and any required helper accessors inside the whitelist; stop if required data fields are missing/ambiguous rather than inventing new schema.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `singletons/CustomsInvariants.gd`
- `singletons/CustomsAuditLevel2.gd`

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

- `codex/runs/issue-0109-l2-invariants-chain-coherence/job.md`
- `codex/runs/issue-0109-l2-invariants-chain-coherence/results.md`

---

## Public API Changes
List any new or modified public methods, signals, or resources.
If none, write “None”.

- None (all additions are internal Level 2 invariants and/or internal helper functions used only by the Level 2 audit path)

---

## Data Model & Persistence
Required if this job adds or modifies saved state **or introduces new required in-memory fields**.

- New or changed saved fields:
  - None (this job must not add new required fields; it validates existing fields only)
- Migration / backward-compat expectations:
  - If a bill of sale lacks source fields in older saves, the invariant must fail with a clear code (or return NOT_EVALUABLE only if the field truly does not exist in schema and cannot be distinguished from tampering).
- Save/load verification requirements:
  - Load an existing save with normal trading history and confirm Level 2 remains CLEAN unless sources are missing/tampered per the invariant rules.

---

## Determinism & Stability (If Applicable)
- What must be deterministic?
  - Invariant evaluation order, invariant codes, severities, and any computed totals/aggregates.
- What inputs must remain stable?
  - Document IDs, document type strings, line item quantities, source references, destroyed flags/status, and any per-doc “available qty” semantics already present in the data model.
- What must not introduce randomness or time-based variance?
  - No reliance on `Time.get_ticks_msec()`, system clock, random numbers, or frame timing.

---

## Acceptance Criteria (Must Be Testable)
These define “done” and must be objectively verifiable.

- [ ] Selling goods normally (with properly formed sources) produces a Level 2 audit result of CLEAN (no new invariant failures).
- [ ] Editing/tampering a bill of sale to remove sources OR mismatch source totals causes Level 2 to return INVALID with clear invariant codes (new IDs 005+), with severity `invalid` or `suspicious` as appropriate.
- [ ] Referencing a non-existent source doc, a disallowed type, or a destroyed source doc produces a deterministic Level 2 failure with a clear invariant code.
- [ ] Overselling by manipulating sources (aggregate sold-by-source/commodity exceeds available) produces a deterministic Level 2 failure with a clear invariant code.
- [ ] No cargo snapshot or runtime cargo state is consulted by the new invariants.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the feature.

1. Launch the project, load a test save (or start a new run) and perform a normal legal sale that generates a bill of sale with sources populated.
2. Trigger the Level 2 customs audit (via the existing inspection/audit path) and confirm the result is CLEAN with no new L2INV failures.
3. Using the in-game doc editor (Captain’s Quarters) or any existing debug doc editor, tamper the bill of sale by removing sources or altering source quantities so totals no longer match sold qty.
4. Trigger Level 2 audit again and confirm it reports INVALID with the expected new invariant code(s) and a clear message indicating the failure reason (missing sources / mismatch totals).
5. Tamper the bill of sale to reference a bogus/nonexistent source doc ID (and separately, a doc type that is not allowed as a source if the editor permits) and rerun Level 2; confirm deterministic INVALID findings.
6. If the game supports “destroying” docs, mark a source doc destroyed (or simulate destroyed flag/state), then rerun Level 2; confirm the destroyed-source invariant fails.
7. Create an oversell scenario by editing sources so aggregate sold-by-source exceeds available, rerun Level 2, and confirm the oversell invariant fails.

---

## Edge Cases / Failure Modes
List known edge cases or scenarios that must fail gracefully.

- Bills of sale with multiple line items and multiple sources per line: ensure totals are computed per commodity and/or per line consistently and deterministically.
- Older saves where source fields may be absent: emit a clear failure or NOT_EVALUABLE reason (only if truly schema-missing), without crashing.
- Duplicate source references across multiple bills of sale: aggregate oversell must account for all relevant sales deterministically.
- Source docs that exist but are of an unrecognized type string: must fail with a clear invariant code rather than crashing.

---

## Risks / Notes
Anything that could cause regressions, merge conflicts,
architectural concerns, or future refactors.

- Risk: the current doc schema may not encode “available” quantity in a way that supports oversell checks without interpretation; if so, Codex must stop and report the ambiguity rather than inventing new semantics.
- Risk: invariant ordering or shared helper logic could subtly change existing Level 2 outputs; ensure new invariants only add failures and do not alter prior invariant evaluations.
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
  B) Run the current issue’s Closeout Gate (stage ? staged diff review ? commit ? push)
- If `git status -sb` shows the branch is behind origin (e.g. `[behind N]`), Codex MUST STOP and instruct `git pull --ff-only` (or stash-or-closeout first if the tree is dirty).
- Codex must not proceed with any implementation until the working tree is clean AND the branch is not behind origin.

## Git Postflight & Closeout Gate (Mandatory)
After implementation is complete, Codex must perform these gates in order:

1) Review Gate (Staged Diff)
- Stage ONLY:
  - `codex/runs/ACTIVE_RUN.txt`
  - `codex/runs/issue-0109-l2-invariants-chain-coherence/**`
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
  - Staged set includes files outside ACTIVE_RUN.txt, codex/runs/issue-0109-l2-invariants-chain-coherence/**, or job whitelist.
  - Scope/whitelist/blacklist conflict or ambiguous instruction.
- Run:
  - `git commit -m "issue-0109: Level 2 audit — add chain-coherence invariants (sources + oversell)"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- STOP.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0109-l2-invariants-chain-coherence/`
2) Write this job verbatim to `codex/runs/issue-0109-l2-invariants-chain-coherence/job.md`
3) Create `codex/runs/issue-0109-l2-invariants-chain-coherence/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0109-l2-invariants-chain-coherence`

Codex must write final results only to:
- `codex/runs/issue-0109-l2-invariants-chain-coherence/results.md`

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
