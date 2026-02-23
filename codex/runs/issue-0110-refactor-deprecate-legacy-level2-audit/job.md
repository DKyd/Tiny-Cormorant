# Refactor Job

## Metadata (Required)
- Issue/Task ID: issue-0110
- Short Title: Deprecate legacy GameState Level 2 audit path (single source of truth)
- Run Folder Name: issue-0110-refactor-deprecate-legacy-level2-audit
- Job Type: refactor
- Author (human): Douglass Kyd
- Date: 2026-02-23

---

## Goal
Remove ambiguity by ensuring there is exactly one authoritative Level 2 audit entrypoint used by the game. The legacy/alternate Level 2 audit path (`run_level2_customs_audit`) must be clearly deprecated (or removed if safe) so future work and debugging always targets the same implementation.

No behavior change: the same Level 2 audit that is currently in use remains the one in use.

---

## Non-Goals
- No gameplay changes.
- No feature additions.
- No behavior changes beyond structure/readability.
- Do NOT change Level 2 invariant logic or classifications.
- Do NOT introduce or remove any audit triggers (sale/entry/departure checks remain as-is).

---

## Invariants (Must Remain True)
- Time advances only via `GameState.advance_time(reason)`.
- Docked UI interactions do not advance time.
- GameState remains authoritative for transitions.
- UI does not mutate state directly.
- Economy determinism remains keyed by `(system_id, tick, market_kind)`.

Job-specific:
- The active Level 2 audit path used by `Customs.gd` remains the only runtime path for Level 2 audits.
- Any deprecated legacy audit function is not called from anywhere in the repo (no live call sites).

---

## Scope

### Files Allowed to Modify (Whitelist)
- `singletons/GameState.gd`
- `singletons/Customs.gd`

### Files Forbidden to Modify (Blacklist)
- `data/**`
- `scenes/MainGame.tscn`

---

## Approach (High Level)
1) Identify the currently used Level 2 audit entrypoint (expected: `Customs.gd.run_level_2_audit()` -> `CustomsLevel2Audit.build_level2_audit(...)`).
2) Locate `GameState.run_level2_customs_audit` (or equivalent legacy Level 2 path) and confirm whether it has any call sites.
3) If there are **zero call sites**, either:
   - A) Remove the legacy function (preferred if allowed by repo norms), OR
   - B) Mark it as `LEGACY/UNUSED` with a clear comment and keep it returning a safe, deterministic result (no side effects).
4) If there **are** call sites, redirect them to the canonical Level 2 path and then deprecate the legacy function.
5) Preserve behavior equivalence: no changes to audit output format, classifications, or triggers—only consolidation/clarity.

---

## Verification

### Manual Test Steps
1. In Godot, perform an action that can trigger customs inspection (entry/departure/sale), and confirm Level 2 audits still run and produce findings normally (or CLEAN when appropriate).
2. Confirm the legacy Level 2 audit function is not invoked (via code search / no references).

### Regression Checklist
- [ ] No UI action advances time
- [ ] No state mutation moved into UI
- [ ] Logs still reflect real player actions
- [ ] No protected paths touched
- [ ] Repo search shows no remaining callers of the legacy Level 2 audit function

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
  - `codex/runs/issue-0110-refactor-deprecate-legacy-level2-audit/**`
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
  - Staged set includes files outside ACTIVE_RUN.txt, codex/runs/issue-0110-refactor-deprecate-legacy-level2-audit/**, or job whitelist.
  - Scope/whitelist/blacklist conflict or ambiguous instruction.
- Run:
  - `git commit -m "issue-0110: Deprecate legacy GameState Level 2 audit path (single source of truth)"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- STOP.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0110-refactor-deprecate-legacy-level2-audit/`
2) Write this job verbatim to `codex/runs/issue-0110-refactor-deprecate-legacy-level2-audit/job.md`
3) Create `codex/runs/issue-0110-refactor-deprecate-legacy-level2-audit/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0110-refactor-deprecate-legacy-level2-audit`

Codex must write final results only to:
- `codex/runs/issue-0110-refactor-deprecate-legacy-level2-audit/results.md`

Results must include:
- Summary of refactor
- Files changed
- Manual test results
- Confirmation behavior is unchanged
- Follow-ups / known gaps (if any)

---

## Migration Notes
None.

---

## Logging Checklist
- [ ] No debug spam added
- [ ] No meaningful logs removed
- [ ] `print()` removed or debug-only
- [ ] Log volume appropriate
