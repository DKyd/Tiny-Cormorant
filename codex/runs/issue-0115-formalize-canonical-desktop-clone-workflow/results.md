# Results

## Summary
- Formalized `C:\Users\akaph\Desktop\Ozark Interactive\Games\Tiny Cormorant` as the canonical local Tiny Cormorant workspace across the governance docs.
- Reconciled run-folder bootstrap authority so `codex/AGENTS.md`, `codex/README.md`, and the governance template all allow limited Codex bootstrap creation when the human provides a complete job template.
- Updated governance references from `config.json` to `config.md` and pinned Godot 4.6 in `codex/CONTEXT.md`.
- Hardened `codex/tools/git_gates.ps1` so preflight and postflight emit machine-detectable nonzero exits on hard git gate failures, while postflight still permits the intended staged review set.

## Files Changed
- `codex/AGENTS.md`: added canonical clone policy, preflight stop rules, and aligned bootstrap authority.
- `codex/README.md`: documented the canonical workspace, mandatory git gates, governance job type, `config.md` authority, and aligned run-folder creation rules.
- `codex/CONTEXT.md`: pinned Godot 4.6 and added durable project-orientation facts, including the canonical workspace expectation.
- `codex/jobs/governance/template.md`: embedded the canonical workspace rule and aligned scaffolding authority with the rest of governance.
- `codex/jobs/governance/rules.md`: added canonical workspace requirements and explicit governance expectations for auditable gate failures.
- `codex/tools/git_gates.ps1`: added strict git command handling plus hard-failure detection for modified, staged, untracked, and behind-origin states.
- `codex/runs/ACTIVE_RUN.txt`: pointed the active run to `issue-0115-formalize-canonical-desktop-clone-workflow`.
- `codex/runs/issue-0115-formalize-canonical-desktop-clone-workflow/job.md`: recorded the job spec verbatim.
- `codex/runs/issue-0115-formalize-canonical-desktop-clone-workflow/results.md`: recorded this closeout.

## Verification
- Ran the required preflight in the canonical desktop clone before editing; it was clean and not behind origin.
- Re-ran `powershell -ExecutionPolicy Bypass -File codex/tools/git_gates.ps1 -Mode Preflight` after edits and confirmed a nonzero exit with explicit hard-failure output for modified and untracked files.
- Checked `git status --short --untracked-files=all` and confirmed only whitelisted governance files plus the active run folder changed.
- Confirmed the postflight review gate now allows the intended staged review set while still surfacing scope and status information.

## Assumptions
- The governance intent is to permit limited Codex bootstrap creation when the human provides a complete job template, because the active job explicitly requires that scaffolding behavior.
- Pinning Godot 4.6 in `codex/CONTEXT.md` is authoritative for future governance unless a later job explicitly changes it.

## Limitations
- The hard-failure verification exercised the dirty and untracked cases directly during this job. Behind-origin behavior remains implemented via the new upstream-behind check and would trigger when `HEAD..@{upstream}` is nonzero.
