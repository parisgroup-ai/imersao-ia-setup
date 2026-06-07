---
name: impeccable
description: >-
  Provides premium design vocabulary, supporting Google Stitch spec-based
  DESIGN.md / PRODUCT.md and anti-pattern slop removal.
version: 1.0.0
---

# Impeccable Design Vocabulary and Aesthetics

Use this skill when developing premium frontend layouts, polishing styling, or curating brand design systems.

## Design Commands (23 shorthands)

The operator uses these shorthands to quickly direct styling changes:
- `/polish`: Fine-tune paddings, contrast ratios, and structural balance.
- `/typeset`: Apply display-vs-body typographic scales (pairing Outfit/Cormorant with clean sans-serif body).
- `/colorize`: Refactor color schemes to use strict semantic CSS tokens.
- `/animate`: Add subtle micro-animations (entrances, interactive state HMR transitions).
- `/quieter`: Mute visual priority of label elements.
- `/bolder`: Elevate accent elements' visual weight.
- `/delight`: Infuse subtle design signatures (e.g. oklch-based gradients).
- `/teach`: Parse or generate the `DESIGN.md` / `PRODUCT.md` context files.
- `/document`: Sync visual changes back into the spec.

## Google Stitch Specifications

Always keep files in sync:
- **`DESIGN.md`**: Typography, Colors, Spacings, Radius & Borders, Shadows, and Components.
- **`PRODUCT.md`**: Audience, brand voice, anti-references, register mode (`brand` vs `product`).

Avoid 25 curated anti-patterns ("AI Slop"):
- Purple gradients unless branding dictates.
- Cardocalypse (nested containers).
- Hardcoded gray tags (use semantically tied backgrounds).
- Rounding inconsistencies (cards must be rounded-xl; inputs rounded-lg).
