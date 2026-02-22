param(
    [Parameter(Mandatory = $true)]
    [ValidateSet(''Preflight'', ''Postflight'')]
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

if ($Mode -eq 'Preflight') {
    Invoke-GitReadOnly -Label 'git branch --show-current' -Args @('branch', '--show-current')
    Invoke-GitReadOnly -Label 'git status --short' -Args @('status', '--short')
    Invoke-GitReadOnly -Label 'git log --oneline -n 5 --decorate' -Args @('log', '--oneline', '-n', '5', '--decorate')
    Invoke-GitReadOnly -Label 'git show HEAD:codex/runs/ACTIVE_RUN.txt' -Args @('show', 'HEAD:codex/runs/ACTIVE_RUN.txt')
    Invoke-GitReadOnly -Label 'git fetch origin' -Args @('fetch', 'origin')
    Invoke-GitReadOnly -Label 'git status -sb' -Args @('status', '-sb')
}

if ($Mode -eq 'Postflight') {
    Invoke-GitReadOnly -Label 'git log --oneline -n 3' -Args @('log', '--oneline', '-n', '3')
    Invoke-GitReadOnly -Label 'git show HEAD:codex/runs/ACTIVE_RUN.txt' -Args @('show', 'HEAD:codex/runs/ACTIVE_RUN.txt')
    Invoke-GitReadOnly -Label 'git status --short' -Args @('status', '--short')
}