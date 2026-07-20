#!/usr/bin/env bash
# publish-public.sh
# Publishes a talks-free snapshot of the harness to the public mirror repo.
# The public repo gets its own history (never the private one, whose commits
# contain the talks).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PUBLIC_REMOTE="${PUBLIC_REMOTE:-https://github.com/cms1308/hep-th-presentation.git}"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Reuse the mirror's existing history if it has one; otherwise start fresh.
if git clone --depth 1 "$PUBLIC_REMOTE" "$TMP" 2>/dev/null; then
  echo "[publish] cloned existing mirror"
else
  git -C "$TMP" init -q -b main
  git -C "$TMP" remote add origin "$PUBLIC_REMOTE"
  echo "[publish] initialized new mirror"
fi

# The public mirror is the harness (schema, templates, skills, scripts) —
# talks/ contents stay private.
rsync -a --delete \
  --exclude .git \
  --exclude 'talks/*' \
  --exclude .DS_Store \
  "$ROOT"/ "$TMP"/

# Keep the talks/ directory visible in the mirror, contents ignored on clones.
mkdir -p "$TMP/talks"
touch "$TMP/talks/.gitkeep"
grep -q "^talks/\*$" "$TMP/.gitignore" 2>/dev/null || printf "talks/*\n!talks/.gitkeep\n" >> "$TMP/.gitignore"

cd "$TMP"
git add -A
if git diff --cached --quiet; then
  echo "[publish] mirror already up to date"
  exit 0
fi
git commit -q -m "publish: snapshot $(date +%F)"
git push -u origin main
echo "[publish] pushed snapshot to $PUBLIC_REMOTE"
