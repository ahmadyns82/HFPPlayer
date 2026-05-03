#!/bin/bash
# Run this script from inside the HFPPlayer folder after unzipping
# Usage: bash push_to_github.sh YOUR_GITHUB_USERNAME

set -e

USERNAME=${1:-"ahmadyns82"}
REPO="HFPPlayer"
REMOTE="https://github.com/$USERNAME/$REPO.git"

echo "=== Pushing to $REMOTE ==="

# Init if needed
if [ ! -d ".git" ]; then
  git init
  git branch -M main
fi

# Stage everything
git add -A
git status

echo ""
echo "Files to be committed:"
git diff --cached --name-only

echo ""
read -p "Continue with push? (y/n): " confirm
if [ "$confirm" != "y" ]; then
  echo "Aborted."
  exit 0
fi

git commit -m "feat: full HFPPlayer project" 2>/dev/null || \
git commit -m "fix: update project files" 2>/dev/null || true

# Set remote
git remote remove origin 2>/dev/null || true
git remote add origin "$REMOTE"

git push -u origin main --force

echo ""
echo "✅ Done! Check https://github.com/$USERNAME/$REPO"
echo "   You should see HFPPlayer.xcodeproj/ and Views/, Models/, Services/ folders."
