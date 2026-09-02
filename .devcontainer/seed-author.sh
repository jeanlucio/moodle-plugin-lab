#!/usr/bin/env bash
# postCreateCommand — roda quando o Codespace do aluno nasce. Adivinha o nome dele
# (para os cabeçalhos @copyright) sem exigir interação. A confirmação interativa
# acontece depois, no primeiro terminal aberto (.devcontainer/first-run.sh).
set -euo pipefail

CFG_DIR="$HOME/.config/moodle-plugin-lab"
mkdir -p "$CFG_DIR"
[ -f "$CFG_DIR/author" ] && exit 0

NAME="$(gh api user --jq '.name // empty' 2>/dev/null || true)"
[ -z "$NAME" ] && NAME="$(git config --global user.name 2>/dev/null || true)"
[ -z "$NAME" ] && NAME="${GITHUB_USER:-}"
[ -z "$NAME" ] && NAME="Seu Nome"

printf '%s\n' "$NAME" > "$CFG_DIR/author"
