# Runbook Template

Copy this template for operational runbooks.

---

```markdown
---
title: "Runbook: {{title}}"
created: {{date}}
updated: {{date}}
owner: Team/Person
severity: P1 | P2 | P3 | P4
tags:
  - type/runbook
  - team/{{team}}
---

# Runbook: {{title}}

> [!warning] Severity Level
> **{{severity}}** - Response time: {{response_time}}

## Overview

Brief description of when to use this runbook.

## Symptoms

- [ ] Symptom 1 (how to identify)
- [ ] Symptom 2
- [ ] Symptom 3

## Prerequisites

- Access to [system/tool]
- Permissions: [required permissions]
- Tools: [required CLI tools]

## Diagnosis Steps

### 1. Check System Status

\`\`\`bash
# Command to check status
kubectl get pods -n production
\`\`\`

**Expected output**: Description of healthy state

### 2. Review Logs

\`\`\`bash
# Command to view logs
kubectl logs -f deployment/app -n production
\`\`\`

**Look for**: Error patterns, stack traces

## Resolution Steps

### Scenario A: [Description]

1. **Step 1**: Action description
   \`\`\`bash
   command here
   \`\`\`

2. **Step 2**: Action description
   \`\`\`bash
   command here
   \`\`\`

3. **Verify**: How to confirm resolution
   \`\`\`bash
   command here
   \`\`\`

### Scenario B: [Description]

1. **Step 1**: Action description

## Rollback Procedure

> [!danger] Use with caution
> Only proceed if resolution steps fail.

\`\`\`bash
# Rollback command
kubectl rollout undo deployment/app -n production
\`\`\`

## Post-Incident

- [ ] Update incident ticket
- [ ] Notify stakeholders
- [ ] Schedule post-mortem if P1/P2
- [ ] Update this runbook if needed

## Escalation

| Level | Contact | When |
|-------|---------|------|
| L1 | On-call engineer | First response |
| L2 | Team Lead | After 30 min |
| L3 | Engineering Manager | After 1 hour |

## Related

- [[Monitoring Dashboard]]
- [[Incident Response]]
- [[Architecture Overview]]

## History

| Date | Author | Change |
|------|--------|--------|
| {{date}} | {{author}} | Initial version |
```
