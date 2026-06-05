# Grading Rubric — Detailed Criteria

Use this rubric when assigning grades to each area. The goal is consistency — two different people auditing the same project should arrive at similar grades.

## Security & Data Protection

| Grade | Criteria |
|-------|----------|
| 9-10 | All auth flows verified. RLS/RBAC on every table. No keys exposed. Input validation on both ends. Encryption at rest and in transit. Compliance features work. |
| 7-8 | Auth works correctly. Access control exists but may have minor gaps. No critical exposures. Some validation missing on backend. |
| 5-6 | Auth exists but has edge cases (token refresh issues, missing route protection). Some inputs not validated. Minor data exposure risks. |
| 3-4 | Auth has significant gaps. Some routes unprotected. API keys partially exposed or in git history. No input validation on backend. |
| 1-2 | No auth or trivially bypassable. User data accessible cross-tenant. Keys in frontend code. No encryption. |

## Functional Integrity

| Grade | Criteria |
|-------|----------|
| 9-10 | All flows work end-to-end. Error handling everywhere. Edge cases covered. State management solid. |
| 7-8 | Main flows work. Minor edge cases unhandled. Most errors caught. Some loading/empty states missing. |
| 5-6 | Main flows work but with rough edges. Some secondary flows broken. Error handling inconsistent. |
| 3-4 | Core flows have bugs. Data loss possible. Missing error handling causes silent failures. |
| 1-2 | Core flows broken. App crashes on common actions. Data corruption possible. |

## Domain Data Coherence

| Grade | Criteria |
|-------|----------|
| 9-10 | All domain data consistent across the entire stack. Single source of truth for all constants. Types match everywhere. |
| 7-8 | Core data consistent. Minor enum mismatches between frontend/backend. Calculations correct. |
| 5-6 | Some data inconsistencies found. Different representations of same data in 2+ places. Minor calculation errors possible. |
| 3-4 | Significant inconsistencies. Data shown to user may be wrong in some scenarios. Types diverge between layers. |
| 1-2 | Data cannot be trusted. Same record shows different values on different screens. Calculations produce wrong results. |

## Visual Consistency

| Grade | Criteria |
|-------|----------|
| 9-10 | Pixel-perfect consistency. All viewports work. All states handled. Professional polish. |
| 7-8 | Consistent design. Works on mobile and desktop. Most states handled. Minor spacing/alignment issues. |
| 5-6 | Generally consistent but some pages feel different. Some mobile issues. Missing empty/error states. |
| 3-4 | Inconsistent styling. Broken on mobile. Missing loading/error states. Mixed typography. |
| 1-2 | No consistent design. Broken layouts. Placeholder text. Unusable on mobile. |

## Performance

| Grade | Criteria |
|-------|----------|
| 9-10 | Sub-2s load times. Lazy loading everywhere. Optimal caching. Efficient queries. No unnecessary re-renders. |
| 7-8 | Good load times. Routes lazy-loaded. Caching configured. Minor optimization opportunities. |
| 5-6 | Acceptable load times. Some routes not lazy-loaded. Caching basic. Some heavy queries. |
| 3-4 | Slow load times. No code splitting. No caching. Query waterfalls. Large bundle. |
| 1-2 | Unusably slow. Everything in one bundle. No optimization. Timeouts on normal usage. |

## Test Coverage

| Grade | Criteria |
|-------|----------|
| 9-10 | 80%+ coverage. Unit + integration + E2E. All critical paths tested. CI runs green. TypeScript strict. |
| 7-8 | 60%+ coverage. Core business logic tested. Some E2E tests. TS compiles clean. |
| 5-6 | Some tests exist. Core flows partially covered. TS has some errors. No E2E. |
| 3-4 | Few tests, most failing or outdated. No coverage for critical paths. TS errors in important files. |
| 1-2 | No tests or all failing. No type safety. No CI. |

## UX Polish

| Grade | Criteria |
|-------|----------|
| 9-10 | Every interaction gives feedback. Error recovery works. Accessible. Beautiful copy. No TODOs. |
| 7-8 | Good feedback for main actions. Most errors handled gracefully. Minor copy issues. Basic accessibility. |
| 5-6 | Some actions lack feedback. Some English/placeholder text. Error messages sometimes technical. |
| 3-4 | Many actions lack feedback. Double-click possible. TODOs/FIXMEs visible. Poor error messages. |
| 1-2 | No loading states. No error handling. Placeholder text everywhere. Inaccessible. |
