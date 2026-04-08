# Detection Patterns by Language

Detailed patterns for identifying code duplication across different languages and frameworks.

## TypeScript/JavaScript

### Type Definitions

```bash
# Find duplicate interface/type names
grep -rhn "export\s\+\(type\|interface\)\s\+\w\+" --include="*.ts" --include="*.tsx" | \
  awk -F: '{match($3, /export\s+(type|interface)\s+(\w+)/, arr); print arr[2], $1":"$2}' | \
  sort | uniq -d -f1

# Find types defined in multiple packages
for pkg in packages/*/src; do
  echo "=== $pkg ==="
  grep -rhn "export type \w\+" "$pkg" --include="*.ts" | head -20
done

# Zod schemas with same name
grep -rn "export const \w\+Schema = z\." --include="*.ts" | \
  awk -F: '{match($3, /const (\w+)Schema/, arr); print arr[1]}' | \
  sort | uniq -c | sort -rn | head -20
```

### Error Classes

```bash
# Find all custom error classes
grep -rn "class \w\+Error extends" --include="*.ts"

# Find error classes with duplicate names
grep -rhn "class \w\+Error" --include="*.ts" | \
  awk -F: '{match($3, /class (\w+Error)/, arr); print arr[1]}' | \
  sort | uniq -c | sort -rn | awk '$1 > 1'
```

### Configuration Objects

```bash
# Status configuration patterns
grep -rn "STATUS_CONFIG\|VARIANT_CONFIG\|STATE_CONFIG" --include="*.ts"

# Factory functions
grep -rn "export\s\+function\s\+create\w\+" --include="*.ts"

# Similar const exports
grep -rn "export const [A-Z_]\+:" --include="*.ts" | \
  awk -F: '{match($3, /const ([A-Z_]+)/, arr); print arr[1]}' | \
  sort | uniq -c | sort -rn | head -30
```

### Utility Functions

```bash
# Format/transform functions
grep -rn "export function format\w\+\|export function transform\w\+" --include="*.ts"

# Parse functions
grep -rn "export function parse\w\+" --include="*.ts"

# Validation functions
grep -rn "export function validate\w\+\|export function is\w\+" --include="*.ts"

# Helper functions by name pattern
grep -rn "export function \(get\|set\|create\|build\|make\)\w\+" --include="*.ts" | \
  awk -F: '{match($3, /function (\w+)/, arr); print arr[1]}' | \
  sort | uniq -c | sort -rn | head -30
```

### React Components

```bash
# Similar component names
grep -rn "export\s\+\(function\|const\)\s\+\w\+\s*[=:]\s*\(React\.FC\|(\)" --include="*.tsx" | \
  awk -F: '{match($3, /(function|const)\s+(\w+)/, arr); print arr[2]}' | \
  sort | uniq -c | sort -rn | awk '$1 > 1'

# Hooks with same name
grep -rn "export function use\w\+" --include="*.ts" --include="*.tsx" | \
  awk -F: '{match($3, /function (use\w+)/, arr); print arr[1]}' | \
  sort | uniq -c | sort -rn | awk '$1 > 1'
```

## Python

### Error Classes

```bash
# Find all custom exceptions
grep -rn "class \w\+\(Error\|Exception\)\(" --include="*.py"

# Find duplicate exception names
grep -rhn "class \w\+Error" --include="*.py" | \
  awk -F: '{match($3, /class (\w+Error)/, arr); print arr[1]}' | \
  sort | uniq -c | sort -rn | awk '$1 > 1'

# Exception hierarchy analysis
grep -rn "class \w\+Error(\w\+Error)" --include="*.py" | \
  awk '{match($0, /class (\w+Error)\((\w+Error)\)/, arr); print arr[2], "->", arr[1]}'
```

### Pydantic Models

```bash
# Find Pydantic models
grep -rn "class \w\+\(BaseModel\|Base\)" --include="*.py"

# Similar model names
grep -rhn "class \w\+(BaseModel)" --include="*.py" | \
  awk -F: '{match($3, /class (\w+)/, arr); print arr[1]}' | \
  sort | uniq -c | sort -rn | awk '$1 > 1'
```

### Utility Functions

```bash
# Helper functions
grep -rn "^def \(get_\|set_\|create_\|build_\|make_\|parse_\|format_\)" --include="*.py"

# Async helpers
grep -rn "^async def \w\+" --include="*.py" | \
  awk -F: '{match($3, /def (\w+)/, arr); print arr[1]}' | \
  sort | uniq -c | sort -rn | head -30
```

### Constants

```bash
# Module-level constants (UPPER_CASE)
grep -rn "^[A-Z_]\+ = " --include="*.py" | \
  awk -F: '{match($3, /^([A-Z_]+)/, arr); print arr[1]}' | \
  sort | uniq -c | sort -rn | head -30

# Enum definitions
grep -rn "class \w\+(Enum)" --include="*.py"
```

## Go

### Error Definitions

```bash
# Custom error types
grep -rn "type \w\+Error struct" --include="*.go"

# Error variables
grep -rn "var Err\w\+ = errors\." --include="*.go"

# Duplicate error names
grep -rhn "var Err\w\+" --include="*.go" | \
  awk -F: '{match($3, /var (Err\w+)/, arr); print arr[1]}' | \
  sort | uniq -c | sort -rn | awk '$1 > 1'
```

### Interface Definitions

```bash
# Find interfaces
grep -rn "type \w\+ interface {" --include="*.go"

# Similar interface names
grep -rhn "type \w\+ interface" --include="*.go" | \
  awk -F: '{match($3, /type (\w+) interface/, arr); print arr[1]}' | \
  sort | uniq -c | sort -rn | awk '$1 > 1'
```

### Struct Definitions

```bash
# Find structs with similar names
grep -rhn "type \w\+ struct" --include="*.go" | \
  awk -F: '{match($3, /type (\w+) struct/, arr); print arr[1]}' | \
  sort | uniq -c | sort -rn | awk '$1 > 1'
```

## Cross-Language Patterns

### Import Analysis

```bash
# TypeScript: Most imported modules
grep -rhn "from ['\"]" --include="*.ts" --include="*.tsx" | \
  awk -F"from ['\"]" '{print $2}' | \
  awk -F"['\"]" '{print $1}' | \
  sort | uniq -c | sort -rn | head -30

# Python: Most imported modules
grep -rhn "^from \w\+ import\|^import \w\+" --include="*.py" | \
  awk '{print $2}' | \
  sort | uniq -c | sort -rn | head -30
```

### Circular Import Detection

```bash
# TypeScript: Find potential circular imports
for file in $(find . -name "*.ts" -not -path "*/node_modules/*"); do
  dir=$(dirname "$file")
  base=$(basename "$file" .ts)
  grep -l "from ['\"].*/$base['\"]" "$dir"/*.ts 2>/dev/null | \
    grep -v "$file" | \
    while read dep; do
      if grep -q "from ['\"].*$(basename $dep .ts)['\"]" "$file"; then
        echo "CIRCULAR: $file <-> $dep"
      fi
    done
done
```

### Dead Code Detection

```bash
# Find exports not imported anywhere
for export in $(grep -rhn "export \(const\|function\|class\|type\|interface\) \w\+" --include="*.ts" | \
  awk -F: '{match($3, /export (const|function|class|type|interface) (\w+)/, arr); print arr[2]}' | \
  sort -u); do
  count=$(grep -rn "import.*$export\|from.*$export" --include="*.ts" | wc -l)
  if [ "$count" -eq 0 ]; then
    echo "Unused export: $export"
  fi
done
```

## Monorepo-Specific Patterns

### Cross-Package Duplication

```bash
# Find same type name in multiple packages
for name in $(grep -rhn "export type \w\+" packages/*/src --include="*.ts" | \
  awk -F: '{match($3, /type (\w+)/, arr); print arr[1]}' | sort | uniq -d); do
  echo "=== Duplicate type: $name ==="
  grep -rn "export type $name" packages/*/src --include="*.ts"
done

# Find same function in multiple packages
for name in $(grep -rhn "export function \w\+" packages/*/src --include="*.ts" | \
  awk -F: '{match($3, /function (\w+)/, arr); print arr[1]}' | sort | uniq -d); do
  echo "=== Duplicate function: $name ==="
  grep -rn "export function $name" packages/*/src --include="*.ts"
done
```

### Package Boundary Violations

```bash
# Find direct file imports across packages (should use package exports)
grep -rn "from ['\"]\.\.\/\.\.\/\.\.\/" --include="*.ts" | grep -v node_modules

# Find imports bypassing package.json exports
grep -rn "from ['\"]@repo/\w\+/src/" --include="*.ts"
```

## Analysis Output Formatting

### Generate Summary Report

```bash
#!/bin/bash
# Run from project root

echo "# Duplication Analysis Report"
echo "Generated: $(date)"
echo ""

echo "## Type Definitions"
grep -rhn "export type \w\+" --include="*.ts" | \
  awk -F: '{match($3, /type (\w+)/, arr); print arr[1]}' | \
  sort | uniq -c | sort -rn | awk '$1 > 1 {print "- " $2 ": " $1 " occurrences"}'

echo ""
echo "## Error Classes"
grep -rhn "class \w\+Error" --include="*.ts" --include="*.py" | \
  awk -F: '{match($3, /class (\w+Error)/, arr); print arr[1]}' | \
  sort | uniq -c | sort -rn | awk '$1 > 1 {print "- " $2 ": " $1 " occurrences"}'

echo ""
echo "## Configuration Objects"
grep -rn "STATUS_CONFIG\|VARIANT_CONFIG" --include="*.ts" | wc -l | \
  xargs -I {} echo "- Config patterns found: {} files"

echo ""
echo "## Factory Functions"
grep -rn "export function create\w\+" --include="*.ts" | wc -l | \
  xargs -I {} echo "- Factory functions: {}"
```
