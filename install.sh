#!/usr/bin/env bash
set -euo pipefail

BASE="https://raw.githubusercontent.com/grant-wilson/agent-instructions/main/claude"

curl -fsSL "$BASE/CLAUDE.md" -o CLAUDE.md

SKILLS=(
  angular-conventions
  csharp-standards
  css-standards
  deno-conventions
  dotnet-conventions
  html-standards
  sql-standards
  typescript-standards
)

for skill in "${SKILLS[@]}"; do
  mkdir -p ".claude/skills/$skill"
  curl -fsSL "$BASE/.claude/skills/$skill/SKILL.md" -o ".claude/skills/$skill/SKILL.md"
done

echo "Installed."
