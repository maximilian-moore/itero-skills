# Phase 4: User Journey, Flows & Design Tokens

In collaborative and multi-agent projects, design consistency easily degrades when
different agents build separate screens without a unified source of visual truth.

This phase establishes the thin user journey and core design tokens in `docs/user-journey.md`.

---

## 1. The Journey Document (`docs/user-journey.md`)

Keep it under two pages:
1. **Personas & Context:** Who uses this, on what devices, in what environment.
2. **Core Jobs-to-be-Done:** Outcomes users need to achieve.
3. **Key User Flows:** 3 to 5 critical flows described step-by-step from user perspective.
4. **Screens & State Matrix:** For each screen, define 4 states:
   - Empty state
   - Loading state
   - Error state
   - Success state
5. **Design Tokens:**
   - Palette (Background, Surface, Text, Muted, Accent, Danger, Success)
   - Typography (Font families, weights, scale)
   - Spacing & Radius (Base grid, corner roundings)
   - Component Library (e.g. Tailwind, shadcn/ui, Mantine)

Every worker subagent implementing a UI feature references `docs/user-journey.md` to
ensure screens stay visually coherent across branches.
