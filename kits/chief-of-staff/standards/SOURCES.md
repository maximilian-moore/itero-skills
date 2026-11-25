# Sources of vendored standards

Copied on 2026-11-07 so every harness reads the same, stable file. Re-copy deliberately
when updating; never edit these copies (put local rules in `../skills.md`).

| File | Source | Version | License |
|---|---|---|---|
| `security-and-hardening.md` | addyosmani/agent-skills `skills/security-and-hardening/SKILL.md` | 0.6.10 | MIT, (c) 2025 Addy Osmani |
| `debugging-and-error-recovery.md` | addyosmani/agent-skills `skills/debugging-and-error-recovery/SKILL.md` | 0.6.10 | MIT, (c) 2025 Addy Osmani |
| `flutter-dart-code-review.md` | ECC (Everything Claude Code) `skills/flutter-dart-code-review/SKILL.md` | e04ea0b9 (2026-09-03) | MIT, (c) 2026 Affaan Mustafa |
| `typescript-review.md` | ECC `agents/typescript-reviewer.md` | e04ea0b9 (2026-09-03) | MIT, (c) 2026 Affaan Mustafa |
| `security-checklist.md` | addyosmani/agent-skills `references/security-checklist.md` (the `../../references/security-checklist.md` links in `security-and-hardening.md` mean this file) | 0.6.10 | MIT, (c) 2025 Addy Osmani |
| `test-driven-development.md` | addyosmani/agent-skills `skills/test-driven-development/SKILL.md` | 0.6.10 | MIT, (c) 2025 Addy Osmani |

## Written for HQ (not copies)

| File | Based on |
|---|---|
| `code-review.md` | <OWNER>'s `review.md` checklist and severities, plus the find-then-verify method of Anthropic's `code-review` plugin (claude-plugins-official, Apache 2.0). Method described in our own words; no text copied. |
| `security-review.md` | <OWNER>'s `review.md` and `security.md`, `security-and-hardening.md`, and the general approach of Anthropic's security reviews (scope to the change and its data flow, verify every finding). The `claude-security` plugin is proprietary ("All rights reserved"); nothing from it is copied. |
