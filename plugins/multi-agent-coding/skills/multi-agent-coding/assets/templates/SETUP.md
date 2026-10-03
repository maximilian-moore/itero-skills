# Setup

Everything you need to run this on a new machine or secondary worktree.

## 1. Clone and install

```bash
git clone [repo url]
cd [repo]
[install command, e.g. npm install]
```

For parallel agent execution on the same machine, use a git worktree:
```bash
git worktree add ../[repo]-worker-2 feat/BL-XXX-[actor]-[slug]
```

## 2. Secrets

Copy the example file. Never commit the real one, it is git-ignored for a reason.

```bash
cp .env.example .env
```

Then fill in each value below.

### `EXAMPLE_API_KEY`
- **What it is:** [one line]
- **Where to get it:** [exact site and page, e.g. console.anthropic.com > API Keys > Create key]
- **Cost:** [free / paid, roughly what]
- **If you lose it:** [can you regenerate, and does regenerating break anything]

## 3. Run and Verify

```bash
./scripts/verify.sh
[run command, e.g. npm run dev]
```

## Moving between machines or agents
Never email, message, or paste secrets into an unencrypted chat window. Get fresh values from the
sources above on each machine. If a key has ever appeared in a chat transcript or a
screenshot, rotate it immediately.

## Troubleshooting
| Symptom | Cause | Fix |
|---|---|---|
| | | |
