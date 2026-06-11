# Tournament OS Tools

Small helper scripts for Tournament OS planning and implementation.

## Create GitHub Issues

Script:

```text
CREATE_GITHUB_ISSUES.ps1
```

Purpose:

- Create Tournament OS Phase 1 labels.
- Create milestone `Tournament OS Phase 1`.
- Create main tracking issue.
- Create Phase 1 Epic issues.

Requirements:

- GitHub network access.
- `GH_TOKEN` or `GITHUB_TOKEN` environment variable with issue write permission.

Dry run:

```powershell
.\projects\tournament-os\tools\CREATE_GITHUB_ISSUES.ps1 -DryRun
```

Real run:

```powershell
.\projects\tournament-os\tools\CREATE_GITHUB_ISSUES.ps1
```

If the token can create issues but cannot create labels:

```powershell
.\projects\tournament-os\tools\CREATE_GITHUB_ISSUES.ps1 -SkipLabels
```

If the token can create issues but cannot create labels or milestones:

```powershell
.\projects\tournament-os\tools\CREATE_GITHUB_ISSUES.ps1 -SkipLabels -SkipMilestone
```

If the token can create issues but cannot create comments:

```powershell
.\projects\tournament-os\tools\CREATE_GITHUB_ISSUES.ps1 -SkipLabels -SkipMilestone -SkipComments
```

The script does not store tokens or secrets in Git.
