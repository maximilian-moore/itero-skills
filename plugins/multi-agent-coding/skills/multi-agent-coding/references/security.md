# Phase 0 & Phase 6: Security, Secrets & Public Readiness

In multi-agent environments, secrets and credentials are at heightened risk because
multiple tools, APIs, and models process workspace content.

---

## 1. Phase 0: Repo Initialization & Secret Isolation

### Step 1: Initialize Git
```bash
git init
git branch -M main
gh repo create <name> --private --source=. --remote=origin
```
Always private by default. Never push to public without Phase 6 verification.

### Step 2: Airtight `.gitignore`
Write `.gitignore` immediately:
- `.env`, `.env.*` (never `.env.example`)
- `node_modules/`, `venv/`, `__pycache__/`, `target/`, `dist/`, `.next/`
- `*.db`, `*.sqlite`, `data/`
- `*.pem`, `*.key`, `id_rsa*`

### Step 3: Secrets Contract (`.env.example` & `docs/SETUP.md`)
1. `.env.example` lists every variable needed with dummy placeholders.
2. `docs/SETUP.md` explains where to acquire each secret per machine.
3. Every agent that introduces a new environment variable must update `.env.example`
   in the exact same commit.

### Step 4: Verification Script (`scripts/verify.sh`)
Create `scripts/verify.sh` to run linting, building, tests, and secret checks.

---

## 2. Phase 6: Public Readiness & Pre-Release Scan

Before a private repository is made public or shared outside the core team:

1. **Run Secret Scan on Full Git History:**
   Execute `./scripts/scan-secrets.sh`. It checks all commits for pattern leaks (API keys,
   tokens, private keys).
2. **Review `docs/learnings.md` & `architecture.md`:**
   Ensure no internal company URLs, staging credentials, or PII were inadvertently logged.
3. **Verify License & README:**
   Ensure `LICENSE` and user-facing `README.md` are present and up to date.
