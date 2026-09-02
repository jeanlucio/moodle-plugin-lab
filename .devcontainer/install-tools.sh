#!/usr/bin/env bash
# Instala o conjunto CURADO de moodle-dev-tools para o ambiente do aluno.
# Fora do conjunto: monitores Telegram, marketplace-downloads, query-baseline,
# security-audit e os wrappers multi-container (moodle-upgrade). O que depende de
# 'docker exec' é substituído por wrappers nativos em bin/ (moodle-coverage,
# moodle-check-schema, moodle-check).
set -euo pipefail

WORKSPACE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOLS_DIR="$WORKSPACE/tools"
SUPPORT_DIR="$HOME/.moodle-dev-tools"
HOOKS_DIR="$HOME/.githooks"
BIN_DIR="$HOME/.local/bin"

mkdir -p "$SUPPORT_DIR" "$HOOKS_DIR" "$BIN_DIR"

# --- Arquivos de suporte do hook -------------------------------------------------
cp "$TOOLS_DIR/phpcs-ai-call.py"    "$SUPPORT_DIR/"
cp "$TOOLS_DIR/phpcs-bootstrap.php" "$SUPPORT_DIR/"
chmod +x "$SUPPORT_DIR/phpcs-ai-call.py"

# --- Config de ambiente (paths do Codespace, sem segredo nenhum) ----------------
cat > "$HOME/.moodle-dev-tools.env" <<EOF
MDT_MOODLE_ROOT=$WORKSPACE
MDT_MOODLE_HTML=$WORKSPACE/moodle
MDT_MOODLE_PUBLIC=$WORKSPACE/moodle/public
EOF

# Arquivo de chaves de IA — criado vazio (revisão IA desligada por padrão, SKIP_AI=1).
if [ ! -f "$HOME/.phpcs-ai.env" ] && [ -f "$TOOLS_DIR/.phpcs-ai.env.example" ]; then
    cp "$TOOLS_DIR/.phpcs-ai.env.example" "$HOME/.phpcs-ai.env"
    chmod 600 "$HOME/.phpcs-ai.env"
fi

# --- Hook de pre-commit (global; só age de verdade em repositório de plugin) -----
ln -sf "$TOOLS_DIR/pre-commit"         "$HOOKS_DIR/pre-commit"
ln -sf "$TOOLS_DIR/prepare-commit-msg" "$HOOKS_DIR/prepare-commit-msg"
chmod +x "$TOOLS_DIR/pre-commit" "$TOOLS_DIR/prepare-commit-msg"
git config --global core.hooksPath "$HOOKS_DIR"

# --- moodle-phpstan: corrige o único path hardcoded do script e liga o wrapper ---
sed -i "s#/home/ubuntu/moodle-dev-tools/phpstan#$TOOLS_DIR/phpstan#g" \
    "$TOOLS_DIR/phpstan.sh"
chmod +x "$TOOLS_DIR/phpstan.sh" "$TOOLS_DIR/scope-audit.sh"
ln -sf "$TOOLS_DIR/phpstan.sh"     "$BIN_DIR/moodle-phpstan"
ln -sf "$TOOLS_DIR/scope-audit.sh" "$BIN_DIR/moodle-scope-audit"

if command -v composer >/dev/null 2>&1 && [ -f "$TOOLS_DIR/phpstan/composer.json" ]; then
    ( cd "$TOOLS_DIR/phpstan" && composer install --no-interaction --no-progress \
        >/dev/null 2>&1 ) || echo "aviso: composer install em tools/phpstan falhou"
fi

# --- Confirmação do nome do autor no primeiro terminal interativo ---------------
MARKER="# >>> moodle-plugin-lab first-run >>>"
if ! grep -qF "$MARKER" "$HOME/.bashrc" 2>/dev/null; then
    cat >> "$HOME/.bashrc" <<EOF

$MARKER
# O GITHUB_TOKEN automático do Codespace só dá acesso ao repo de origem. Removendo-o,
# git e gh passam a usar a credencial completa do 'gh auth login' (repos do aluno).
unset GITHUB_TOKEN GH_TOKEN
if [ -t 1 ] && [ ! -f "\$HOME/.config/moodle-plugin-lab/.author-confirmed" ]; then
    bash "$WORKSPACE/.devcontainer/first-run.sh" || true
fi
# <<< moodle-plugin-lab first-run <<<
EOF
fi

echo "moodle-dev-tools (curado) instalado."
