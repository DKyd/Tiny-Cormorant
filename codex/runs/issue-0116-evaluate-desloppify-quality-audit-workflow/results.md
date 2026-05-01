# Results

## Summary
- Evaluated Desloppify as a diagnostic-only tool from the canonical workspace: `C:\Users\akaph\Desktop\Ozark Interactive\Games\Tiny Cormorant`.
- Added `.desloppify/` to `.gitignore` because it was not previously ignored.
- Installed Python 3.12 and Desloppify outside the repo, then ran a GDScript-only objective scan with explicit exclusions.
- Recommendation: use Desloppify only as an optional audit input for future governed jobs, not as an autonomous queue or cleanup authority.

## Commands Run
- Preflight:
  - `git branch --show-current`
  - `git status --short`
  - `git log --oneline -n 5 --decorate`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `powershell -ExecutionPolicy Bypass -File codex/tools/git_gates.ps1 -Mode Preflight`
- Local tooling discovery:
  - `desloppify --help` failed before install
  - `python --version` failed before install
  - `winget search --id Python.Python.3.12 --accept-source-agreements --disable-interactivity`
  - `winget install --id Python.Python.3.12 --exact --source winget --accept-source-agreements --accept-package-agreements --disable-interactivity`
  - `C:\Users\akaph\AppData\Local\Programs\Python\Python312\python.exe -m pip install --upgrade desloppify`
  - `C:\Users\akaph\AppData\Local\Programs\Python\Python312\Scripts\desloppify.exe --help`
  - `C:\Users\akaph\AppData\Local\Programs\Python\Python312\Scripts\desloppify.exe scan --help`
  - `C:\Users\akaph\AppData\Local\Programs\Python\Python312\Scripts\desloppify.exe langs`
- Diagnostic scan:
  - `C:\Users\akaph\AppData\Local\Programs\Python\Python312\Scripts\desloppify.exe --lang gdscript --exclude .git --exclude .godot --exclude .desloppify --exclude codex/runs scan --path . --profile objective --skip-slow --no-badge`
  - `C:\Users\akaph\AppData\Local\Programs\Python\Python312\Scripts\desloppify.exe --lang gdscript --exclude .git --exclude .godot --exclude .desloppify --exclude codex/runs status`
  - `C:\Users\akaph\AppData\Local\Programs\Python\Python312\Scripts\desloppify.exe --lang gdscript --exclude .git --exclude .godot --exclude .desloppify --exclude codex/runs next --count 8`
  - `C:\Users\akaph\AppData\Local\Programs\Python\Python312\Scripts\desloppify.exe --lang gdscript --exclude .git --exclude .godot --exclude .desloppify --exclude codex/runs plan queue`

## Exclusions Applied
- `.git`
- `.godot`
- `.desloppify`
- `codex/runs`

## Tool State
- Desloppify created local state under `.desloppify/`, including:
  - `plan.json`
  - `progression.jsonl`
  - `progression.jsonl.lock`
  - `query.json`
  - `state-gdscript.json`
  - `state-gdscript.json.bak`
- Verified with `git status --short --ignored .desloppify` that `.desloppify/` is ignored and not staged.

## Scan Output Summary
- Scan profile: `objective`
- Language: `gdscript`
- Slow phases skipped: yes
- Badge generation disabled: yes
- Reported scores:
  - `overall 11.5/100`
  - `objective 45.9/100`
  - `strict 11.5/100`
  - `verified 45.9/100`
- Reported issue summary:
  - `+52 new`
  - `52 open issues across 3 dimensions`
  - `20 subjective dimensions queued for review`
  - `26 issues hidden (showing 10/detector)`
- Reported dimension summary:
  - `File health 92.8%`
  - `Code quality 86.6%`
  - `Security 100.0%`
  - `Test health 0.0%`

## Notable Findings
- Desloppify detected first-class `gdscript` support in its language list.
- The scan reported:
  - `6 structural issues`
  - `9 coupling/structural issues total`
  - `36 test coverage issues`
  - `security: clean (36 files scanned)`
- The status dashboard highlighted these structural debt areas near the top:
  - `scripts/ui`
  - `scripts/customs`
  - `singletons/GameState.gd`
  - `singletons/Galaxy.gd`
  - `singletons/Economy.gd`
  - `CommodityDB.gd`
  - `data/CommodityDB.gd`
- The `next` and `plan queue` views were not useful for governed implementation work in this run. They surfaced only a workflow item telling the operator to rescan rather than a concrete file-level action.

## Limitations and Risks
- The `objective` scan still reported `20 subjective dimensions queued for review`. I intentionally did not invoke the `review` workflow because the job warned that subjective or LLM-assisted review may send code or summaries off-machine if unclear.
- The scan emitted a stale-reference warning for the excluded `codex/runs` directory: `Excluded directory 'codex/runs' has 0 references from scanned code — may be stale`.
- The status dashboard mentioned a `codex/runs` debt area even though that path was excluded, but follow-up `show` commands for `codex/runs`, `scripts/ui`, `structural`, `orphaned`, and `subjective` returned `No open issues matching`. That inconsistency reduces trust in the drill-down and queueing UX for this repository.
- The scan was incomplete by design because `--skip-slow` was used to keep the evaluation lightweight and avoid deeper duplicate-analysis cost.
- Desloppify produced local state and a persistent plan under `.desloppify/`; this is acceptable for local auditing, but it reinforces the need to keep the tool advisory and uncommitted.

## Recommendation
- Do not adopt Desloppify as an authoritative workflow driver for Tiny Cormorant at this time.
- Use it, at most, as an optional diagnostic pass at the start of a future governance or audit job.
- Keep any usage constrained by the existing Tiny Cormorant governance model:
  - canonical clone only unless explicitly overridden by the human
  - explicit exclusions for local/generated directories
  - no autonomous `next` loop execution
  - no direct cleanup outside a normal job whitelist
  - no commits of `.desloppify/**`
- If future humans want value from it, the best pattern is:
  - run an `objective` scan
  - capture the score and findings in `results.md`
  - convert individual cleanup themes into separate normal jobs with whitelists and review gates

## Proposed Follow-Up Jobs
- Governance job: define an optional “external audit input” workflow template if the team wants to standardize Desloppify-style scans.
- Feature or refactor jobs: address specific findings only after they are translated into normal Tiny Cormorant jobs scoped to particular runtime files.

## Scope Confirmation
- No Desloppify findings were fixed during this job.
- No runtime files were modified.
- No `.desloppify/**` files were staged or committed.
