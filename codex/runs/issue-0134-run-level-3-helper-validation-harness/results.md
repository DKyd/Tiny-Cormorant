# Results

## Summary
- Ran the issue-0133 Level 3 helper validation harness with the provided Godot executable path.
- The provided executable exists and was used:
  - `C:\Users\akaph\OneDrive\Desktop\Godot_v4.6.1-stable_win64.exe`
- The harness command returned exit code `0` twice.
- The provided Windows Godot executable produced empty stdout in this shell, including for `--version`; this appears to be a stdout attachment limitation of the non-console executable, not a harness failure.
- No runtime code, helper code, validation harness code, data, scenes, project settings, `.godot/**`, documentation, or governance files were modified.

## Capability / Milestone Definition
The standalone Level 3 helper is validated enough for a future governed integration-planning job, with one evidence caveat:

- Pass evidence: the validation harness exited `0` twice through Godot using the provided executable.
- Determinism evidence: the harness internally calls `build_level3_reconciliation_report(ctx)` twice per fixture and exits nonzero if canonicalized reports differ; both full harness runs exited `0`.
- Caveat: JSON validation output was not visible because the provided non-console Godot executable emitted no stdout in this shell.

Any future integration must remain separately governed. This planning output does not authorize live integration, UI surfacing, pressure effects, logs, enforcement, or gameplay behavior changes.

## Preflight Evidence
- `git branch --show-current`
  - output: `master`
- `git status --short`
  - output: clean before scaffolding
- `git log --oneline -n 5 --decorate`
  - `dd1d7e6 (HEAD -> master, origin/master, origin/HEAD) issue-0133: Add deterministic Level 3 helper validation harness`
  - `560f13c issue-0132: Record OneDrive hydration resolution`
  - `20870c2 issue-0132: Record Godot Windows crash evidence`
  - `9dbfe0a issue-0132: Triage Godot headless validation crash`
  - `fd9c5f9 issue-0131: Implement Level 3 read-only reconciliation helper`
- `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - output: `issue-0133-add-deterministic-level-3-helper-validation-harness`
- `git fetch origin`
  - completed
- `git status -sb`
  - output: `## master...origin/master`

## Workspace Path Evidence
- Checked `C:\Users\akaph\Desktop\Ozark Interactive\Games\Tiny Cormorant`
  - result: path does not exist on this machine.
- Checked `C:\Users\akaph\OneDrive\Desktop\Ozark Interactive\Games\Tiny Cormorant`
  - result: path exists and is the current working tree.
- Path note: this matches the earlier machine-specific OneDrive Desktop redirect clarification. No governance files were modified.

## Godot Executable Evidence
Command:

```powershell
Test-Path "C:\Users\akaph\OneDrive\Desktop\Godot_v4.6.1-stable_win64.exe"
```

Output:

```text
True
```

Command:

```powershell
Get-Item "C:\Users\akaph\OneDrive\Desktop\Godot_v4.6.1-stable_win64.exe" | Select-Object FullName,Length,LastWriteTime
```

Output:

```text
FullName                                                         Length LastWriteTime
--------                                                         ------ -------------
C:\Users\akaph\OneDrive\Desktop\Godot_v4.6.1-stable_win64.exe 172310536 2/20/2026 10:06:16 AM
```

Observed but not used for validation because the job required the provided path unless unavailable:

```text
C:\Users\akaph\OneDrive\Desktop\Godot_v4.6.1-stable_win64_console.exe
```

## Validation Command 1
Command:

```powershell
& "C:\Users\akaph\OneDrive\Desktop\Godot_v4.6.1-stable_win64.exe" --headless --path . --script res://scripts/customs/CustomsLevel3ReconciliationValidation.gd
```

Exit code:

```text
0
```

Output:

```text

```

Status:
- Harness passed by exit code.
- Stdout was empty.

## Validation Command 2
Command:

```powershell
& "C:\Users\akaph\OneDrive\Desktop\Godot_v4.6.1-stable_win64.exe" --headless --path . --script res://scripts/customs/CustomsLevel3ReconciliationValidation.gd
```

Exit code:

```text
0
```

Output:

```text

```

Status:
- Harness passed by exit code on a repeated full run.
- Stdout was empty again.

## Stdout Probe
Command:

```powershell
& "C:\Users\akaph\OneDrive\Desktop\Godot_v4.6.1-stable_win64.exe" --version
```

Exit code:

```text
0
```

Output:

```text

```

Interpretation:
- The provided executable can run successfully but does not attach stdout in this shell.
- This explains why the validation JSON printed by the harness was not visible despite successful exit status.

## Determinism Evidence
- The harness itself performs repeated helper calls for every fixture and compares canonicalized report signatures.
- Both complete harness runs exited `0`.
- Therefore repeated-run determinism was validated by the harness exit contract.
- The exact JSON summary could not be captured from stdout with the provided non-console executable.

## Runtime Isolation / Policy Evidence
Command:

```powershell
rg "CustomsLevel3ReconciliationValidation" data scripts singletons scenes project.godot
```

Output:

```text
scripts\customs\CustomsLevel3ReconciliationValidation.gd:class_name CustomsLevel3ReconciliationValidation
```

Interpretation:
- No live runtime systems call the validation harness.

Command:

```powershell
rg "policy_disabled_until_level3|L2INV-001" scripts/customs/CustomsInvariants.gd
```

Output:

```text
const INVARIANT_ID_QTY: String = "L2INV-001"
	results.append(_evaluate_quantity_consistency_policy_disabled_until_level3(docs_by_id))
# L2INV-001 intentionally policy-disabled at Level 2.
static func _evaluate_quantity_consistency_policy_disabled_until_level3(docs_by_id: Dictionary) -> Dictionary:
				"policy_disabled_until_level3",
			"policy_disabled_until_level3",
```

Interpretation:
- Level 2 quantity/cargo reconciliation remains policy-disabled.

## Post-Run Working Tree
Command:

```powershell
git status --short
```

Output:

```text
 M codex/runs/ACTIVE_RUN.txt
?? codex/runs/issue-0134-run-level-3-helper-validation-harness/
```

Command:

```powershell
git status -sb
```

Output:

```text
## master...origin/master
 M codex/runs/ACTIVE_RUN.txt
?? codex/runs/issue-0134-run-level-3-helper-validation-harness/
```

`.godot/**` status:
- No `.godot/**` files appeared in `git status --short`.
- No `.godot/**` files were staged or committed.

## Dependencies And Blockers
- Godot executable path: available and runnable.
- OneDrive project hydration: no hydration error or crash was observed.
- Godot crash status: no crash observed.
- Parse/runtime errors: none surfaced; harness exited `0`.
- Output capture blocker: the provided non-console Godot executable produced no stdout, so JSON output was not captured.

Risk level for remaining blocker:
- Low for helper confidence, because the harness exit contract passed twice.
- Low-to-medium for developer ergonomics, because richer machine-readable output may require using the adjacent console executable or a future narrow tooling note.

## Candidate Job Sequence
### 1. Plan Read-Only Level 3 Integration Context
- Target job type: planning
- Risk level: high
- Likely whitelist:
  - future active run folder only
- Narrow goal:
  - decide where and how a read-only Level 3 report may be attached without enforcement, UI, logs, pressure, cargo mutation, save/load mutation, or travel changes.
- Verification approach:
  - source review of `Customs.gd`, `GameState.gd`, report payload owners, and existing Level 1/Level 2 audit flows.
- Explicit non-goals:
  - no implementation, no UI, no pressure, no enforcement, no physical inspections.

### 2. Optional: Add Console-Friendly Harness Output Guidance
- Target job type: planning or tooling documentation
- Risk level: low
- Likely whitelist:
  - future active run folder only, or a narrowly scoped documentation file if explicitly authorized
- Narrow goal:
  - record that Windows users should prefer `Godot_v4.6.1-stable_win64_console.exe` when stdout JSON is required.
- Verification approach:
  - run the console executable in a future governed job if authorized.
- Explicit non-goals:
  - no helper changes, no harness changes, no runtime integration.

### 3. Future Narrow Read-Only Integration
- Target job type: feature
- Risk level: high
- Likely whitelist sketch:
  - `singletons/Customs.gd`
  - `scripts/customs/CustomsLevel3Reconciliation.gd` only if small integration support is explicitly scoped
  - future active run folder files
- Narrow goal:
  - call the already-validated helper from a non-enforcing audit context and attach the report to an internal payload.
- Verification approach:
  - before/after snapshots prove no cargo, credits, pressure, logs, save/load, docs, travel, or UI state changes.
  - static search confirms Level 2 `L2INV-001` remains `policy_disabled_until_level3`.
- Explicit non-goals:
  - no UI surfacing, no pressure effects, no enforcement, no fines, no holds, no seizures, no forced offloads, no cargo denial, no travel blocking.

## Recommendation
Proceed next with a planning job for read-only Level 3 integration context, not direct implementation of UI/pressure/enforcement. The helper and harness have enough pass evidence for planning the integration boundary, while the stdout capture caveat should remain visible in future validation instructions.

Do not combine helper bugfix, harness output ergonomics, and live integration in one job.
