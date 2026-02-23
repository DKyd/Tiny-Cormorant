param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Preflight', 'Postflight')]
    [string]$Mode
)

function Invoke-GitReadOnly {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [string[]]$Args
    )

    Write-Host ""
    Write-Host ("=== {0} ===" -f $Label)
    & git @Args
}

function Invoke-GitOptional {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [string[]]$Args
    )

    Write-Host ""
    Write-Host ("=== {0} ===" -f $Label)
    try {
        & git @Args
    } catch {
        Write-Host ("(non-fatal) Failed: {0}" -f $Label)
    }
}

function Invoke-ReviewGateDiffs {
    # Always show staged contents for in-chat review.
    # This is intentionally chat-friendly: name-only, stat, then full diff.
    Invoke-GitReadOnly -Label 'git diff --name-only --staged (REVIEW GATE: staged file list)' -Args @('diff', '--name-only', '--staged')
    Invoke-GitReadOnly -Label 'git diff --stat --staged (REVIEW GATE: staged diff stat)' -Args @('diff', '--stat', '--staged')
    Invoke-GitReadOnly -Label 'git diff --staged (REVIEW GATE: staged diff)' -Args @('diff', '--staged')
}

if ($Mode -eq 'Preflight') {
    Invoke-GitReadOnly -Label 'git branch --show-current' -Args @('branch', '--show-current')
    Invoke-GitReadOnly -Label 'git status --short' -Args @('status', '--short')
    Invoke-GitReadOnly -Label 'git log --oneline -n 5 --decorate' -Args @('log', '--oneline', '-n', '5', '--decorate')
    Invoke-GitReadOnly -Label 'git show HEAD:codex/runs/ACTIVE_RUN.txt' -Args @('show', 'HEAD:codex/runs/ACTIVE_RUN.txt')
    Invoke-GitReadOnly -Label 'git fetch origin' -Args @('fetch', 'origin')
    Invoke-GitReadOnly -Label 'git status -sb' -Args @('status', '-sb')

    # Optional: if something is already staged during preflight, show it so
    # Codex can't "forget" to present diffs.
    Invoke-GitOptional -Label 'git diff --quiet --staged (check staged changes exist)' -Args @('diff', '--quiet', '--staged')
    if ($LASTEXITCODE -ne 0) {
        Invoke-ReviewGateDiffs
    } else {
        Write-Host ""
        Write-Host "=== REVIEW GATE (staged diffs) ==="
        Write-Host "(no staged changes)"
    }
}

if ($Mode -eq 'Postflight') {
    # Postflight should always include a Review Gate dump of staged diffs.
    # This makes it hard to accidentally commit/push without having printed the diff.
    Invoke-ReviewGateDiffs

    Invoke-GitReadOnly -Label 'git log --oneline -n 3' -Args @('log', '--oneline', '-n', '3')
    Invoke-GitReadOnly -Label 'git show HEAD:codex/runs/ACTIVE_RUN.txt' -Args @('show', 'HEAD:codex/runs/ACTIVE_RUN.txt')
    Invoke-GitReadOnly -Label 'git status --short' -Args @('status', '--short')
}