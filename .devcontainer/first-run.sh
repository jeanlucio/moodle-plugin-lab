#!/usr/bin/env bash
# Confirmação interativa do nome do autor, na primeira vez que um terminal é aberto.
# Chamado pelo trecho que o install-tools.sh acrescenta ao ~/.bashrc.
set -euo pipefail

CFG_DIR="$HOME/.config/moodle-plugin-lab"
mkdir -p "$CFG_DIR"
CURRENT="$(cat "$CFG_DIR/author" 2>/dev/null || echo 'Seu Nome')"

echo ""
echo "────────────────────────────────────────────────────────────────"
echo "  Moodle Plugin Lab — configuração inicial (só desta vez)"
echo "────────────────────────────────────────────────────────────────"
echo "  Seu nome entra no cabeçalho de licença (@copyright) de cada"
echo "  arquivo criado com 'plugin-new'."
echo ""
read -r -p "  Seu nome completo [${CURRENT}]: " ANSWER || ANSWER=""
NAME="${ANSWER:-$CURRENT}"

printf '%s\n' "$NAME" > "$CFG_DIR/author"
touch "$CFG_DIR/.author-confirmed"

echo ""
echo "  Autor definido: ${NAME}"
echo "  (para mudar depois:  set-author \"Outro Nome\")"
echo ""
echo "  Site Moodle: aba da porta 8000   ·   admin / Sandbox123!"
echo "  Primeiro passo:  docs/GUIA-DO-ALUNO.md"
echo "────────────────────────────────────────────────────────────────"
echo ""
