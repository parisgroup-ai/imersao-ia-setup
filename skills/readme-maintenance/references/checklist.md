# README Audit Checklist

Comprehensive checklist for auditing documentation files.

## README.md Checklist

### Structure

- [ ] **Title** - Uses correct format (`# @repo/name` or `# @pageshell/name`)
- [ ] **Description** - Has one-line description after title
- [ ] **Sections ordered** - Follows standard order (Features, Usage, API, Config, Scripts)
- [ ] **No empty sections** - All sections have content

### Content Accuracy

- [ ] **Package name matches** - Title matches `package.json#name`
- [ ] **Description matches** - Description aligns with `package.json#description`
- [ ] **Exports documented** - All `package.json#exports` have documentation
- [ ] **Scripts documented** - All relevant `package.json#scripts` listed
- [ ] **Dependencies mentioned** - Key dependencies noted if relevant

### Code Examples

- [ ] **Language specified** - All code blocks have language identifier
- [ ] **Imports shown** - Examples include import statements
- [ ] **Examples work** - Code examples are valid TypeScript/JavaScript
- [ ] **Real types used** - Examples use actual types from package

### Links & References

- [ ] **Internal links valid** - Links to other files resolve
- [ ] **External links work** - URLs are accessible
- [ ] **ADR references current** - ADR links point to existing ADRs
- [ ] **Related packages linked** - Cross-references to related packages

### Formatting

- [ ] **Consistent headings** - Heading levels follow hierarchy
- [ ] **Tables formatted** - Tables render correctly
- [ ] **Lists consistent** - Bullet/numbered lists used appropriately
- [ ] **No orphan backticks** - Code formatting is complete

## AGENTS.md Checklist

### Frontmatter

- [ ] **Has YAML frontmatter** - File starts with `---`
- [ ] **title field** - Contains location identifier
- [ ] **created field** - Has creation date (YYYY-MM-DD)
- [ ] **updated field** - Has last update date
- [ ] **status field** - Set to `active` or appropriate status
- [ ] **tags array** - Has relevant tags
- [ ] **related array** - Links to parent AGENTS files

### Required Sections

- [ ] **Scope** - Defines what the file covers
- [ ] **Project Context** - Explains purpose
- [ ] **Mandatory Startup** - References root AGENTS.md
- [ ] **Key Locations** - Table of important paths
- [ ] **Safe Defaults** - Lists what NOT to do automatically
- [ ] **Validation** - Test/lint/typecheck commands
- [ ] **Herança** - Links to parent AGENTS
- [ ] **Links** - Links to CLAUDE.md, README.md

### Content Quality

- [ ] **Key paths exist** - Paths in Key Locations table exist
- [ ] **Commands work** - Validation commands are correct
- [ ] **Safe defaults relevant** - Warnings are specific to package
- [ ] **API examples valid** - Code examples compile

### Consistency

- [ ] **Obsidian links** - Uses `[[link]]` format for internal refs
- [ ] **Path references** - Paths are relative and correct
- [ ] **Parent inheritance** - Correctly inherits from parent AGENTS

## Cross-File Validation

### README ↔ AGENTS.md

- [ ] **No duplication** - Detailed API in AGENTS, summary in README
- [ ] **Consistent naming** - Same package name used
- [ ] **Complementary content** - README for users, AGENTS for agents

### README ↔ package.json

- [ ] **Name matches** - Title matches `name` field
- [ ] **Exports covered** - All exports documented
- [ ] **Scripts listed** - Important scripts documented
- [ ] **Description aligns** - Descriptions are consistent

### README ↔ Source Code

- [ ] **Exports current** - Documented API matches actual exports
- [ ] **Types accurate** - Type signatures match implementation
- [ ] **Examples compile** - Code examples use valid syntax

## Common Issues by Package Type

### Utility Packages (@repo/*)

- [ ] Function signatures documented
- [ ] Configuration options listed
- [ ] Environment variables documented

### UI Packages (@pageshell/*)

- [ ] Components listed with descriptions
- [ ] Props tables for each component
- [ ] Usage examples with JSX
- [ ] Peer dependencies listed
- [ ] Tree-shaking imports shown

### App Documentation

- [ ] Tech stack listed
- [ ] Getting started guide
- [ ] Environment variables documented
- [ ] Project structure explained
- [ ] Deployment notes included

## Severity Levels

### Critical (Must Fix)

- Missing README.md for published package
- Package name mismatch
- Broken internal links
- Outdated API (missing exports)
- Security-related information outdated

### High (Should Fix)

- Missing code examples
- Incomplete API documentation
- Missing AGENTS.md for complex package
- Outdated scripts list
- Missing configuration docs

### Medium (Nice to Fix)

- Formatting inconsistencies
- Missing Features section
- Incomplete cross-references
- Minor typos in examples

### Low (Optional)

- Style preference differences
- Additional examples could help
- Related links could be added
