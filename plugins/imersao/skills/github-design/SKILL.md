---
name: github-design
description: "Use when setting up GitHub repositories, workflows, issue templates, or project organization - enforces best practices for .github folder structure, reusable workflows, branch protection, CODEOWNERS, labels, and GitHub Projects. Triggers on: GitHub, repository setup, workflow, Actions, issue template, PR template, CODEOWNERS, labels, branch protection."
version: 1.0.0
author: gustavo
tags: [github, workflow, ci-cd, repository]
---

# GitHub Design Skill

## Overview

Design GitHub repositories and workflows following best practices for organization, automation, and collaboration.

## When to Use

- Setting up a new repository
- Creating or modifying GitHub Actions workflows
- Designing issue/PR templates
- Organizing labels and milestones
- Configuring branch protection
- Setting up GitHub Projects

## .github Folder Structure

```
.github/
├── workflows/
│   ├── ci.yml                    # Main CI pipeline
│   ├── release.yml               # Release automation
│   └── reusable/
│       ├── build.yml             # Reusable build workflow
│       └── test.yml              # Reusable test workflow
├── ISSUE_TEMPLATE/
│   ├── config.yml                # Template chooser config
│   ├── bug_report.yml            # Bug report form
│   ├── feature_request.yml       # Feature request form
│   └── question.yml              # Question form
├── PULL_REQUEST_TEMPLATE.md      # PR template
├── CODEOWNERS                    # Code ownership
├── FUNDING.yml                   # Sponsorship links
├── dependabot.yml                # Dependency updates
├── labels.yml                    # Label definitions (for label sync)
└── SECURITY.md                   # Security policy
```

## GitHub Actions Best Practices

### Reusable Workflows

```yaml
# .github/workflows/reusable/test.yml
name: Reusable Test

on:
  workflow_call:
    inputs:
      node-version:
        description: 'Node.js version'
        required: false
        type: string
        default: '20'
    secrets:
      NPM_TOKEN:
        required: false

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}
          cache: 'npm'
      - run: npm ci
      - run: npm test
```

### Calling Reusable Workflows

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  test:
    uses: ./.github/workflows/reusable/test.yml
    with:
      node-version: '20'
    secrets: inherit
```

### Matrix Builds

```yaml
jobs:
  test:
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        node: [18, 20, 22]
        exclude:
          - os: windows-latest
            node: 18
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node }}
```

### Caching

```yaml
- uses: actions/cache@v4
  with:
    path: |
      ~/.npm
      node_modules
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-
```

### Concurrency Control

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

### Environment Protection

```yaml
jobs:
  deploy:
    environment:
      name: production
      url: https://example.com
    steps:
      - name: Deploy
        run: ./deploy.sh
```

## Issue Templates (YAML Forms)

### Bug Report

```yaml
# .github/ISSUE_TEMPLATE/bug_report.yml
name: Bug Report
description: "Report a bug"
labels: ["bug", "triage"]
body:
  - type: markdown
    attributes:
      value: Thanks for reporting!

  - type: textarea
    id: description
    attributes:
      label: Description
      description: Clear description of the bug
    validations:
      required: true

  - type: textarea
    id: steps
    attributes:
      label: Steps to Reproduce
      placeholder: |
        1. Go to...
        2. Click on...
        3. See error
    validations:
      required: true

  - type: textarea
    id: expected
    attributes:
      label: Expected Behavior
    validations:
      required: true

  - type: textarea
    id: actual
    attributes:
      label: Actual Behavior
    validations:
      required: true

  - type: dropdown
    id: severity
    attributes:
      label: Severity
      options:
        - Low - Minor inconvenience
        - Medium - Feature partially broken
        - High - Feature completely broken
        - Critical - Production is down
    validations:
      required: true

  - type: input
    id: version
    attributes:
      label: Version
      placeholder: v1.2.3

  - type: textarea
    id: environment
    attributes:
      label: Environment
      placeholder: |
        OS: macOS 14
        Browser: Chrome 120
        Node: 20.10.0
```

### Feature Request

```yaml
# .github/ISSUE_TEMPLATE/feature_request.yml
name: Feature Request
description: "Suggest a new feature"
labels: ["enhancement", "triage"]
body:
  - type: textarea
    id: problem
    attributes:
      label: Problem
      description: What problem does this solve?
    validations:
      required: true

  - type: textarea
    id: solution
    attributes:
      label: Proposed Solution
    validations:
      required: true

  - type: textarea
    id: alternatives
    attributes:
      label: Alternatives Considered

  - type: checkboxes
    id: terms
    attributes:
      label: Checklist
      options:
        - label: I have searched for existing issues
          required: true
        - label: I am willing to submit a PR
```

### Template Chooser Config

```yaml
# .github/ISSUE_TEMPLATE/config.yml
blank_issues_enabled: false
contact_links:
  - name: Documentation
    url: https://docs.example.com
    about: Check documentation first
  - name: Discord
    url: https://discord.gg/example
    about: Ask questions in our Discord
```

## PR Template

```markdown
<!-- .github/PULL_REQUEST_TEMPLATE.md -->

## Summary

<!-- Brief description of changes -->

## Type of Change

- [ ] Bug fix (non-breaking change fixing an issue)
- [ ] New feature (non-breaking change adding functionality)
- [ ] Breaking change (fix or feature causing existing functionality to change)
- [ ] Documentation update

## Related Issues

<!-- Link related issues: Closes #123, Fixes #456 -->

## Testing

<!-- How was this tested? -->

- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing performed

## Checklist

- [ ] My code follows the project's style guidelines
- [ ] I have performed a self-review
- [ ] I have added tests covering my changes
- [ ] I have updated documentation if needed
- [ ] All CI checks pass
```

## CODEOWNERS

```gitignore
# .github/CODEOWNERS

# Default owners
* @org/core-team

# Frontend
/src/components/ @org/frontend-team
/src/pages/ @org/frontend-team
*.tsx @org/frontend-team
*.css @org/frontend-team

# Backend
/src/api/ @org/backend-team
/src/services/ @org/backend-team

# Infrastructure
/.github/ @org/devops-team
/infra/ @org/devops-team
Dockerfile @org/devops-team
docker-compose*.yml @org/devops-team

# Documentation
/docs/ @org/docs-team
*.md @org/docs-team

# Security-sensitive
/src/auth/ @org/security-team @org/core-team
.env.example @org/security-team
```

## Labels System

### Standard Labels

| Label | Color | Description |
|-------|-------|-------------|
| `bug` | #d73a4a | Something isn't working |
| `enhancement` | #a2eeef | New feature or request |
| `documentation` | #0075ca | Documentation improvements |
| `good first issue` | #7057ff | Good for newcomers |
| `help wanted` | #008672 | Extra attention needed |
| `duplicate` | #cfd3d7 | Duplicate issue |
| `wontfix` | #ffffff | Will not be worked on |
| `invalid` | #e4e669 | Not valid issue |

### Priority Labels

| Label | Color | Description |
|-------|-------|-------------|
| `priority: critical` | #b60205 | Production down |
| `priority: high` | #d93f0b | Important, needs quick fix |
| `priority: medium` | #fbca04 | Normal priority |
| `priority: low` | #0e8a16 | Nice to have |

### Status Labels

| Label | Color | Description |
|-------|-------|-------------|
| `triage` | #ededed | Needs triage |
| `blocked` | #b60205 | Blocked by dependency |
| `in progress` | #1d76db | Being worked on |
| `needs review` | #fbca04 | Ready for review |

### Area Labels

| Label | Color | Description |
|-------|-------|-------------|
| `area: frontend` | #c5def5 | Frontend related |
| `area: backend` | #bfd4f2 | Backend related |
| `area: infra` | #d4c5f9 | Infrastructure |
| `area: ci` | #f9d0c4 | CI/CD related |

## Branch Protection Rules

### Main Branch

```json
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["ci", "lint", "test"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true,
    "require_last_push_approval": true
  },
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_conversation_resolution": true
}
```

### Configure via CLI

```bash
gh api repos/{owner}/{repo}/branches/main/protection \
  -X PUT \
  -F required_status_checks='{"strict":true,"contexts":["ci"]}' \
  -F enforce_admins=true \
  -F required_pull_request_reviews='{"required_approving_review_count":1}'
```

## Dependabot

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
      day: "monday"
    open-pull-requests-limit: 10
    labels:
      - "dependencies"
      - "automerge"
    groups:
      dev-dependencies:
        dependency-type: "development"
        update-types: ["minor", "patch"]
      prod-dependencies:
        dependency-type: "production"
        update-types: ["patch"]
    ignore:
      - dependency-name: "aws-sdk"
        update-types: ["version-update:semver-major"]

  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
    labels:
      - "ci"
      - "automerge"
```

## GitHub Projects (ProjectV2)

### Automations via Workflows

```yaml
# .github/workflows/project-automation.yml
name: Project Automation

on:
  issues:
    types: [opened, closed, reopened]
  pull_request:
    types: [opened, closed, reopened, ready_for_review]

jobs:
  add-to-project:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/add-to-project@v1
        with:
          project-url: https://github.com/orgs/org/projects/1
          github-token: ${{ secrets.PROJECT_TOKEN }}
```

## Quick Reference

| Task | Command/File |
|------|-------------|
| Create workflow | `.github/workflows/name.yml` |
| Issue template | `.github/ISSUE_TEMPLATE/name.yml` |
| PR template | `.github/PULL_REQUEST_TEMPLATE.md` |
| Code owners | `.github/CODEOWNERS` |
| Dependabot | `.github/dependabot.yml` |
| Create label | `gh label create "name" -c "color" -d "description"` |
| List labels | `gh label list` |
| Branch protection | `gh api repos/{owner}/{repo}/branches/main/protection` |

## Checklist

### New Repository Setup

- [ ] Create `.github/` folder structure
- [ ] Configure issue templates (YAML forms)
- [ ] Add PR template
- [ ] Set up CODEOWNERS
- [ ] Create standard labels
- [ ] Configure Dependabot
- [ ] Set up CI workflow
- [ ] Configure branch protection
- [ ] Add SECURITY.md
- [ ] Add CONTRIBUTING.md

### Workflow Design

- [ ] Use reusable workflows for common patterns
- [ ] Enable caching for dependencies
- [ ] Set concurrency to avoid duplicate runs
- [ ] Use matrix for cross-platform testing
- [ ] Configure environments for deployments
- [ ] Use secrets appropriately (never in logs)
- [ ] Add timeout-minutes to jobs

### Security

- [ ] No secrets in workflow logs (mask with `::add-mask::`)
- [ ] Use `GITHUB_TOKEN` with minimal permissions
- [ ] Pin action versions with SHA (not tags)
- [ ] Review third-party actions before using
- [ ] Enable secret scanning
- [ ] Configure Dependabot alerts

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Using `on: push` without branch filter | Add `branches: [main]` |
| Not caching dependencies | Add `actions/cache` or built-in cache |
| Hardcoding secrets | Use `${{ secrets.NAME }}` |
| Not using CODEOWNERS | Create `.github/CODEOWNERS` |
| Markdown issue templates | Migrate to YAML forms |
| No concurrency control | Add `concurrency` block |
| Actions without timeouts | Add `timeout-minutes: 30` |
| Not using environments | Add `environment:` for deployments |
