# Documentation Governance

Rules for maintaining traceability and consistency across documentation.

## Traceability Rules

### Rule 1: Mandatory IDs

Every traceable artifact must have a unique ID:

| Artifact | Format | Example |
|----------|--------|---------|
| Requirement | `REQ-###` | REQ-042 |
| ADR | `ADR-###` | ADR-007 |
| PR | `PR #####` | PR #123 |
| Test | `TEST-###` | TEST-101 |
| Epic | `EPIC-##` | EPIC-21 |
| Story | `STORY-###` | STORY-042 |

### Commit References

Commits should reference IDs:

```bash
feat(users): add password reset [REQ-042]
fix(auth): token expiry [ADR-007, PR #120]
```

### Rule 2: Bidirectional Links

Every reference must exist in both directions:

```
REQ-042 ←→ ADR-007 ←→ PR #123 ←→ TEST-101
```

| If you create... | Must link in... |
|------------------|-----------------|
| ADR | Requirements that motivated it |
| PR | ADR that justifies it (if structural) |
| Test | Requirement or PR it validates |

### Rule 3: ADR Required for Structural Decisions

**Requires ADR before PR:**

- Architecture changes
- New external dependencies
- Schema/API changes
- Infrastructure changes
- Performance/cost trade-offs

**Does NOT require ADR:**

- Bug fixes
- Internal refactoring
- Dependency updates (patch/minor)
- Documentation only

> [!danger] Blocker
> PR without linked ADR for structural decision = cannot merge.

### Rule 4: Rollback Always Defined

Every ADR and structural PR must answer:

1. **Triggers:** When to revert? (metrics, errors, time)
2. **Steps:** How to revert? (commands, order)
3. **Validation:** How to confirm reverted?

## Document Lifecycle

### Status Flow

```
draft → review → published → deprecated
                    ↑
                    └── (updates cycle back to review)
```

### Status Definitions

| Status | Meaning | Actions |
|--------|---------|---------|
| `draft` | Work in progress | Can edit freely |
| `review` | Ready for peer review | Request feedback |
| `published` | Approved, finalized | Changelog for updates |
| `deprecated` | Outdated | Link to replacement |

### Review Checklist

Before moving to `published`:

- [ ] Frontmatter complete (title, date, tags, status)
- [ ] All internal links work
- [ ] Code examples tested
- [ ] Callouts used appropriately
- [ ] Related pages linked
- [ ] Changelog updated

## Ownership

### Document Ownership

Every document should have:

- **Owner**: Person/team responsible
- **Last Updated**: Date of last change
- **Status**: Current lifecycle state

### Ownership Transfer

When ownership changes:

1. Update `author` in frontmatter
2. Add changelog entry
3. Notify new owner
4. Update team mappings

## Archive Policy

### When to Archive

- Document superseded by newer version
- Feature removed from product
- Technology no longer in use

### How to Archive

1. Set status to `deprecated`
2. Add callout linking to replacement:
   ```markdown
   > [!warning] Deprecated
   > This document is deprecated. See [[New Document]] instead.
   ```
3. Move to `archive/` folder (optional)
4. Keep links working (don't delete)

## Compliance Checklist

### ADR Governance

Before finalizing an ADR:

- [ ] Unique ID assigned (`ADR-###`)
- [ ] Status defined
- [ ] Requirements linked
- [ ] Required sections complete
- [ ] Rollback defined (if structural)
- [ ] Bidirectional links created

### PR Governance

Before opening a PR:

- [ ] Requirements linked (`REQ-###`)
- [ ] ADR linked (if structural)
- [ ] Scope defined
- [ ] Quality checklist complete
- [ ] Rollback defined (if structural)
- [ ] Evidence attached

### Final Validation

Before merging:

- [ ] No structural PR without ADR
- [ ] All bidirectional links verified
- [ ] Unique IDs (no duplicates)
- [ ] Rollback testable
