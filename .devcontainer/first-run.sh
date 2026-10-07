#!/usr/bin/env bash
# Confirmação interativa do nome do autor. Chamado pelo 'plugin-new', na primeira vez que o
# aluno cria um plugin. NÃO é chamado pelo .bashrc: o VS Code abre terminais interativos
# sozinhos (ex.: o do postAttachCommand) e o 'read' abaixo consumiria o comando deles como se
# fosse o nome — o terminal travava e o comando nunca rodava.
set -euo pipefail

CFG_DIR="$HOME/.config/moodle-plugin-lab"
mkdir -p "$CFG_DIR"

# Nome válido: não vazio, até 80 caracteres, sem caracteres de comando de shell.
name_ok() {
    [ -n "$1" ] && [ "${#1}" -le 80 ] && ! printf '%s' "$1" | grep -q '[;$|`<>\\]'
}

CURRENT="$(cat "$CFG_DIR/author" 2>/dev/null || true)"
name_ok "$CURRENT" || CURRENT="Seu Nome"

echo ""
echo "────────────────────────────────────────────────────────────────"
echo "  Moodle Plugin Lab — configuração inicial (só desta vez)"
echo "────────────────────────────────────────────────────────────────"
echo "  Seu nome entra no cabeçalho de licença (@copyright) de cada"
echo "  arquivo criado com 'plugin-new'."
echo ""

NAME=""
for _ in 1 2 3; do
    read -r -p "  Seu nome completo [${CURRENT}]: " ANSWER || ANSWER=""
    NAME="${ANSWER:-$CURRENT}"
    name_ok "$NAME" && break
    echo "  Nome inválido (use só o seu nome, sem ; \$ | < >). Tente de novo."
    NAME=""
done
[ -n "$NAME" ] || NAME="$CURRENT"

printf '%s\n' "$NAME" > "$CFG_DIR/author"
touch "$CFG_DIR/.author-confirmed"

echo ""
echo "  Autor definido: ${NAME}"
echo "  (para mudar depois:  set-author \"Outro Nome\")"
echo "────────────────────────────────────────────────────────────────"
echo ""
