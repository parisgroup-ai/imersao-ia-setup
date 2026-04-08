---
name: dep-check
description: Audit npm dependencies for vulnerabilities, outdated packages, and monorepo workspace consistency. Use before PRs or after pnpm install.
disable-model-invocation: true
---

# Dependency Check

Quick dependency audit for the ToStudy monorepo.

## Workflow

### 1. Security Audit

```bash
pnpm audit --prod 2>&1 | tail -20
```

### 2. Outdated Packages (Major Only)

```bash
pnpm outdated --recursive --long 2>&1 | grep -E 'MAJOR|Package' | head -30
```

### 3. Workspace Consistency

Check for version mismatches across workspace packages:

```bash
# Find duplicate versions of key packages
node -e "
const fs = require('fs');
const glob = require('glob');
const pkgs = glob.sync('**/package.json', { ignore: 'node_modules/**' });
const deps = {};
for (const p of pkgs) {
  const pkg = JSON.parse(fs.readFileSync(p, 'utf8'));
  const all = { ...pkg.dependencies, ...pkg.devDependencies };
  for (const [name, ver] of Object.entries(all)) {
    if (!deps[name]) deps[name] = [];
    deps[name].push({ file: p, version: ver });
  }
}
for (const [name, versions] of Object.entries(deps)) {
  const unique = [...new Set(versions.map(v => v.version))];
  if (unique.length > 1) {
    console.log(name + ': ' + unique.join(' vs '));
  }
}
" 2>/dev/null || echo "Install glob first: pnpm add -D glob"
```

### 4. Shared Package Version Sync

```bash
# Verify no duplicate installations of shared packages (duplicates break React context)
# Replace <package-name> with your shared UI package
find node_modules -name "package.json" -path "*/<package-name>/package.json" 2>/dev/null | xargs grep '"version"'
```

### 5. Report

Output summary with:
- Vulnerability count by severity
- Major version bumps available
- Version mismatches across workspaces
- Shared package installation status (single vs duplicate)
