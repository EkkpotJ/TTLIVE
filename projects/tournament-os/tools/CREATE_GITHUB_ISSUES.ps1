param(
  [string]$Owner = "Aalika-Ss1",
  [string]$Repo = "TTLIVE",
  [switch]$DryRun,
  [switch]$SkipLabels,
  [switch]$SkipMilestone,
  [switch]$SkipComments
)

$ErrorActionPreference = "Stop"

$token = $env:GH_TOKEN
if (-not $token) {
  $token = $env:GITHUB_TOKEN
}

if (-not $token -and -not $DryRun) {
  throw "Set GH_TOKEN or GITHUB_TOKEN before creating GitHub issues."
}

$repoSlug = "$Owner/$Repo"
$apiBase = "https://api.github.com/repos/$repoSlug"

$headers = @{
  "Accept" = "application/vnd.github+json"
  "X-GitHub-Api-Version" = "2022-11-28"
}

if ($token) {
  $headers["Authorization"] = "Bearer $token"
}

function Invoke-GitHubJson {
  param(
    [string]$Method,
    [string]$Uri,
    [object]$Body
  )

  if ($DryRun) {
    Write-Host "DRY RUN $Method $Uri"
    if ($Body) {
      $Body | ConvertTo-Json -Depth 10
    }
    return $null
  }

  $json = $null
  if ($Body) {
    $json = $Body | ConvertTo-Json -Depth 10
  }

  Invoke-RestMethod -Method $Method -Uri $Uri -Headers $headers -Body $json -ContentType "application/json"
}

function New-LabelIfMissing {
  param(
    [string]$Name,
    [string]$Color,
    [string]$Description
  )

  try {
    Invoke-GitHubJson -Method "GET" -Uri "$apiBase/labels/$Name" | Out-Null
    Write-Host "Label exists: $Name"
  } catch {
    Write-Host "Creating label: $Name"
    Invoke-GitHubJson -Method "POST" -Uri "$apiBase/labels" -Body @{
      name = $Name
      color = $Color
      description = $Description
    } | Out-Null
  }
}

function New-Issue {
  param(
    [string]$Title,
    [string]$Body,
    [string[]]$Labels,
    [string]$MilestoneTitle
  )

  $issueBody = @{
    title = $Title
    body = $Body
  }

  if (-not $SkipLabels -and $Labels -and $Labels.Count -gt 0) {
    $issueBody["labels"] = $Labels
  }

  if ($MilestoneTitle -and -not $DryRun -and -not $SkipMilestone) {
    $milestones = Invoke-GitHubJson -Method "GET" -Uri "$apiBase/milestones?state=open"
    $milestone = $milestones | Where-Object { $_.title -eq $MilestoneTitle } | Select-Object -First 1
    if ($milestone) {
      $issueBody["milestone"] = $milestone.number
    }
  }

  Write-Host "Creating issue: $Title"
  Invoke-GitHubJson -Method "POST" -Uri "$apiBase/issues" -Body $issueBody
}

function Get-IssueByTitle {
  param(
    [string]$Title
  )

  if ($DryRun) {
    return $null
  }

  $encodedTitle = [System.Uri]::EscapeDataString($Title)
  $issues = Invoke-GitHubJson -Method "GET" -Uri "$apiBase/issues?state=all&per_page=100"
  $issues | Where-Object { $_.title -eq $Title -and -not $_.pull_request } | Select-Object -First 1
}

function New-IssueIfMissing {
  param(
    [string]$Title,
    [string]$Body,
    [string[]]$Labels,
    [string]$MilestoneTitle
  )

  $existing = Get-IssueByTitle -Title $Title
  if ($existing) {
    Write-Host "Issue exists: #$($existing.number) $Title"
    return $existing
  }

  New-Issue -Title $Title -Body $Body -Labels $Labels -MilestoneTitle $MilestoneTitle
}

function New-IssueComment {
  param(
    [int]$IssueNumber,
    [string]$Body
  )

  if (-not $IssueNumber) {
    return
  }

  Write-Host "Creating issue comment on #$IssueNumber"
  Invoke-GitHubJson -Method "POST" -Uri "$apiBase/issues/$IssueNumber/comments" -Body @{
    body = $Body
  } | Out-Null
}

$labels = @(
  @{ name = "ttlive"; color = "0E8A16"; description = "TTLIVE operating system work" },
  @{ name = "update"; color = "C5DEF5"; description = "Status update or planning update" },
  @{ name = "tournament-os"; color = "5319E7"; description = "Tournament Operating System subsystem" },
  @{ name = "phase-1"; color = "1D76DB"; description = "Tournament OS Phase 1 scope" },
  @{ name = "epic"; color = "B60205"; description = "Large grouped work item" },
  @{ name = "backend"; color = "0052CC"; description = "Backend implementation" },
  @{ name = "database"; color = "006B75"; description = "Database schema or migrations" },
  @{ name = "api"; color = "0E8A16"; description = "API contract or endpoint work" },
  @{ name = "testing"; color = "FBCA04"; description = "Tests and QA" },
  @{ name = "public-data"; color = "D4C5F9"; description = "Public-safe data and serializers" },
  @{ name = "overlay"; color = "F9D0C4"; description = "OBS/TikTok Live Studio stream-safe view" },
  @{ name = "discord"; color = "7057FF"; description = "Discord-ready flow or bot integration" },
  @{ name = "docs"; color = "0075CA"; description = "Documentation" },
  @{ name = "security"; color = "BFDADC"; description = "Security or permission work" },
  @{ name = "privacy"; color = "FAD8C7"; description = "Private data protection" }
)

if ($SkipLabels) {
  Write-Host "Skipping label creation and issue label assignment."
} else {
  foreach ($label in $labels) {
    New-LabelIfMissing -Name $label.name -Color $label.color -Description $label.description
  }
}

$milestoneTitle = "Tournament OS Phase 1"

if ($SkipMilestone) {
  Write-Host "Skipping milestone creation and issue milestone assignment."
} elseif ($DryRun) {
  Write-Host "DRY RUN milestone: $milestoneTitle"
} else {
  $milestones = Invoke-GitHubJson -Method "GET" -Uri "$apiBase/milestones?state=open"
  $milestone = $milestones | Where-Object { $_.title -eq $milestoneTitle } | Select-Object -First 1
  if (-not $milestone) {
    Write-Host "Creating milestone: $milestoneTitle"
    Invoke-GitHubJson -Method "POST" -Uri "$apiBase/milestones" -Body @{
      title = $milestoneTitle
      description = "Tournament OS Phase 1 backend-readiness and implementation planning."
    } | Out-Null
  }
}

$mainBody = @"
## Goal

Track Tournament OS Phase 1 planning and backend-readiness work.

## Current Status

- SRS is approximately 95%+ ready.
- Group Points Qualifier scoring and advancement contract exists.
- Public and stream-safe OBS/TikTok Live Studio data boundaries are defined.
- GitHub issue template files exist.
- Phase 1 epics are ready to create.

## Scope

- FastAPI backend foundation
- PostgreSQL schema foundation
- ruleset snapshots
- registration and check-in
- scoring and disputes
- leaderboard and advancement
- public-safe and stream-safe read models
- audit and event outbox
- Excel export

## Out Of Scope

- payment
- SaaS multi-tenant management
- OCR as official scoring
- full Discord command system
- advanced overlay editor

## References

- projects/tournament-os/spec/SYSTEM_REQUIREMENTS_SPECIFICATION.md
- projects/tournament-os/spec/GROUP_POINTS_QUALIFIER_SPEC.md
- projects/tournament-os/spec/API_CONTRACT_PHASE_1.md
- projects/tournament-os/backlog/GITHUB_ISSUES_PHASE_1.md
"@

$mainIssue = New-IssueIfMissing -Title "[Tournament OS] Phase 1 System Planning" -Body $mainBody -Labels @("tournament-os", "phase-1", "docs") -MilestoneTitle $milestoneTitle

$updatePath = Join-Path $PSScriptRoot "..\backlog\GITHUB_ISSUE_UPDATE_2026-06-12.md"
if ($SkipComments) {
  Write-Host "Skipping issue comments."
} elseif (Test-Path $updatePath) {
  $updateComment = Get-Content -Path $updatePath -Raw
  if ($mainIssue -and $mainIssue.number) {
    New-IssueComment -IssueNumber $mainIssue.number -Body $updateComment
  } elseif ($DryRun) {
    Write-Host "DRY RUN would post update comment from $updatePath"
  }
}

$epics = @(
  "Documentation Freeze And Architecture",
  "Identity, Permissions, And Tokens",
  "Tournament Core And Rulesets",
  "Registration And Check-In",
  "Group Generation And Lobby Management",
  "Scoring, Leaderboard, Advancement, And Disputes",
  "Public Data, OBS/TikTok Live Studio, And Export",
  "Events, Audit, Realtime-Ready Flow, And Discord-Ready Flow",
  "Backend Foundation"
)

foreach ($epic in $epics) {
  $body = @"
## Goal

Deliver the Phase 1 epic: $epic.

## Source

See:

- projects/tournament-os/backlog/GITHUB_ISSUES_PHASE_1.md
- projects/tournament-os/spec/SYSTEM_REQUIREMENTS_SPECIFICATION.md

## Acceptance Criteria

- [ ] Scope is reviewed against SRS.
- [ ] Required docs/specs are linked.
- [ ] Child implementation issues are created or listed.
- [ ] Privacy and backend ownership boundaries are respected.
- [ ] Tests are identified where implementation risk exists.
"@

  New-IssueIfMissing -Title "[Tournament OS][Epic] $epic" -Body $body -Labels @("tournament-os", "phase-1", "epic") -MilestoneTitle $milestoneTitle
}

Write-Host "Done."
