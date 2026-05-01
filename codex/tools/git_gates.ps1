param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Preflight', 'Postflight')]
    [string]$Mode
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-GitReadOnly {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [string[]]$Args
    )

    Write-Host ''
    Write-Host ('=== {0} ===' -f $Label)
    & git @Args
    if ($LASTEXITCODE -ne 0) {
        throw ('Git command failed: {0}' -f $Label)
    }
}

function Invoke-GitOptional {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [string[]]$Args
    )

    Write-Host ''
    Write-Host ('=== {0} ===' -f $Label)
    & git @Args
    return $LASTEXITCODE
}

function Invoke-ReviewGateDiffs {
    Invoke-GitReadOnly -Label 'git diff --name-only --staged (REVIEW GATE: staged file list)' -Args @('diff', '--name-only', '--staged')
    Invoke-GitReadOnly -Label 'git diff --stat --staged (REVIEW GATE: staged diff stat)' -Args @('diff', '--stat', '--staged')
    Invoke-GitReadOnly -Label 'git diff --staged (REVIEW GATE: staged diff)' -Args @('diff', '--staged')
}

function Get-WorkingTreeStatus {
    $statusLines = (& git status --porcelain=v1)
    if ($LASTEXITCODE -ne 0) {
        throw 'Git status probe failed.'
    }

    $result = [ordered]@{
        HasModified = $false
        HasStaged = $false
        HasUntracked = $false
        Lines = @($statusLines)
    }

    foreach ($line in $statusLines) {
        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }

        if ($line.StartsWith('??')) {
            $result.HasUntracked = $true
            continue
        }

        $indexStatus = $line.Substring(0, 1)
        $worktreeStatus = $line.Substring(1, 1)

        if ($indexStatus -ne ' ') {
            $result.HasStaged = $true
        }

        if ($worktreeStatus -ne ' ') {
            $result.HasModified = $true
        }
    }

    return [pscustomobject]$result
}

function Get-BehindCount {
    & git rev-parse --abbrev-ref '@{upstream}' *> $null
    if ($LASTEXITCODE -ne 0) {
        return 0
    }

    $count = (& git rev-list --count 'HEAD..@{upstream}').Trim()
    if ($LASTEXITCODE -ne 0) {
        throw 'Git behind-count probe failed.'
    }

    if ([string]::IsNullOrWhiteSpace($count)) {
        return 0
    }

    return [int]$count
}

function Assert-NoHardFailures {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ModeName,
        [switch]$RequireNoModified,
        [switch]$RequireNoStaged,
        [switch]$RequireNoUntracked,
        [switch]$RequireNotBehind
    )

    $status = Get-WorkingTreeStatus
    $behindCount = Get-BehindCount
    $violations = New-Object System.Collections.Generic.List[string]

    if ($RequireNoModified -and $status.HasModified) {
        $violations.Add('working tree has modified files')
    }

    if ($RequireNoStaged -and $status.HasStaged) {
        $violations.Add('index has staged changes')
    }

    if ($RequireNoUntracked -and $status.HasUntracked) {
        $violations.Add('working tree has untracked files')
    }

    if ($RequireNotBehind -and $behindCount -gt 0) {
        $violations.Add(('branch is behind upstream by {0} commit(s)' -f $behindCount))
    }

    if ($violations.Count -eq 0) {
        return
    }

    Write-Host ''
    Write-Host ('=== {0} HARD FAILURES ===' -f $ModeName)
    foreach ($violation in $violations) {
        Write-Host ('- {0}' -f $violation)
    }

    exit 1
}

if ($Mode -eq 'Preflight') {
    Invoke-GitReadOnly -Label 'git branch --show-current' -Args @('branch', '--show-current')
    Invoke-GitReadOnly -Label 'git status --short' -Args @('status', '--short')
    Invoke-GitReadOnly -Label 'git log --oneline -n 5 --decorate' -Args @('log', '--oneline', '-n', '5', '--decorate')
    Invoke-GitReadOnly -Label 'git show HEAD:codex/runs/ACTIVE_RUN.txt' -Args @('show', 'HEAD:codex/runs/ACTIVE_RUN.txt')
    Invoke-GitReadOnly -Label 'git fetch origin' -Args @('fetch', 'origin')
    Invoke-GitReadOnly -Label 'git status -sb' -Args @('status', '-sb')

    $stagedProbeExit = Invoke-GitOptional -Label 'git diff --quiet --staged (check staged changes exist)' -Args @('diff', '--quiet', '--staged')
    if ($stagedProbeExit -ne 0) {
        Invoke-ReviewGateDiffs
    } else {
        Write-Host ''
        Write-Host '=== REVIEW GATE (staged diffs) ==='
        Write-Host '(no staged changes)'
    }

    Assert-NoHardFailures -ModeName 'PREFLIGHT' -RequireNoModified -RequireNoStaged -RequireNoUntracked -RequireNotBehind
}

if ($Mode -eq 'Postflight') {
    Invoke-ReviewGateDiffs
    Invoke-GitReadOnly -Label 'git log --oneline -n 3' -Args @('log', '--oneline', '-n', '3')
    Invoke-GitReadOnly -Label 'git show HEAD:codex/runs/ACTIVE_RUN.txt' -Args @('show', 'HEAD:codex/runs/ACTIVE_RUN.txt')
    Invoke-GitReadOnly -Label 'git status --short' -Args @('status', '--short')

    Assert-NoHardFailures -ModeName 'POSTFLIGHT' -RequireNoModified -RequireNoUntracked -RequireNotBehind
}
