#!/usr/bin/env bash
# onCreateCommand — roda UMA vez (no prebuild do Codespace). Deixa o ambiente pronto:
# dependências, banco, site instalado, verificador de PHPDoc, build e ferramentas.
# O boot de cada dia é o start.sh (leve).
set -euo pipefail

MOODLE_BRANCH="${MOODLE_BRANCH:-MOODLE_502_STABLE}"
WORKSPACE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MOODLE_DIR="$WORKSPACE/moodle"
DATAROOT="$WORKSPACE/moodledata"
TOOLS_DIR="$WORKSPACE/tools"
# Moodle 5.x: os scripts CLI ficam na RAIZ (moodle/admin/cli), não sob public/.
CLI="$MOODLE_DIR/admin/cli"

echo "==> [1/8] MariaDB — serviço e banco"
sudo service mariadb start
sudo mysql <<'SQL'
CREATE DATABASE IF NOT EXISTS moodle DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'moodle'@'%' IDENTIFIED BY 'moodle';
GRANT ALL PRIVILEGES ON moodle.* TO 'moodle'@'%';
FLUSH PRIVILEGES;
SQL

echo "==> [2/8] Código do Moodle ($MOODLE_BRANCH)"
if [ ! -d "$MOODLE_DIR/.git" ]; then
    git clone --branch "$MOODLE_BRANCH" --depth 1 \
        https://github.com/moodle/moodle.git "$MOODLE_DIR"
fi
mkdir -p "$DATAROOT"

echo "==> [3/8] Dependências PHP do Moodle (composer) — obrigatório no 5.x"
if [ ! -d "$MOODLE_DIR/vendor" ]; then
    ( cd "$MOODLE_DIR" && composer install --no-interaction --no-progress )
fi

echo "==> [4/8] local_moodlecheck (verificador de PHPDoc, o mesmo do CI)"
if [ ! -d "$MOODLE_DIR/public/local/moodlecheck" ]; then
    git clone --depth 1 \
        https://github.com/moodlehq/moodle-local_moodlecheck.git \
        "$MOODLE_DIR/public/local/moodlecheck"
fi

echo "==> [5/8] Plugins de referência (integrações)"
REFS="$WORKSPACE/.devcontainer/reference-plugins.txt"
if [ -f "$REFS" ]; then
    while read -r url dest ref _; do
        case "$url" in ''|\#*) continue ;; esac
        target="$MOODLE_DIR/public/$dest"
        [ -d "$target/.git" ] && continue
        if [ -z "${ref:-}" ]; then
            ref="$(git ls-remote --tags --refs --sort=-v:refname "$url" 'v*' 2>/dev/null \
                   | head -1 | sed 's#.*refs/tags/##')"
        fi
        if [ -n "$ref" ]; then
            git clone --depth 1 --branch "$ref" "$url" "$target" \
                && echo "  $dest @ $ref" || echo "aviso: falha ao clonar $url @ $ref"
        else
            git clone --depth 1 "$url" "$target" \
                && echo "  $dest @ main (sem release)" || echo "aviso: falha ao clonar $url"
        fi
    done < "$REFS"
fi

echo "==> [6/8] Instalação do site Moodle"
# install.php cria config.php + schema. Só na primeira vez — num rebuild o
# config.php sobrevive em /workspaces (o schema não; o start.sh reinstala).
if [ ! -f "$MOODLE_DIR/config.php" ]; then
    php "$CLI/install.php" \
        --non-interactive --agree-license \
        --wwwroot="http://localhost:8000" \
        --dataroot="$DATAROOT" \
        --dbtype=mariadb --dbhost=127.0.0.1 \
        --dbname=moodle --dbuser=moodle --dbpass=moodle --prefix=mdl_ \
        --fullname="Moodle Plugin Lab" --shortname="lab" \
        --adminuser=admin --adminpass="Sandbox123!" \
        --adminemail="admin@example.invalid"
fi

# Idempotente — roda em toda (re)criação, inclusive rebuild:
# wwwroot dinâmico (o host muda por Codespace) + linhas do ambiente PHPUnit.
bash "$WORKSPACE/.devcontainer/patch-config.sh" "$MOODLE_DIR/config.php"
if ! grep -q 'phpunit_prefix' "$MOODLE_DIR/config.php"; then
    python3 - "$MOODLE_DIR/config.php" "$WORKSPACE" <<'PY'
import sys
path, ws = sys.argv[1], sys.argv[2]
src = open(path).read().splitlines(keepends=True)
extra = ("\n$CFG->phpunit_prefix = 'phpu_';\n"
         f"$CFG->phpunit_dataroot = '{ws}/phpunitdata';\n")
for i, line in enumerate(src):
    if 'lib/setup.php' in line:
        src.insert(i, extra)
        break
open(path, 'w').write(''.join(src))
PY
fi
mkdir -p "$WORKSPACE/phpunitdata"

echo "==> [7/8] Dependências de build do Moodle (grunt, eslint, stylelint)"
if [ ! -d "$MOODLE_DIR/node_modules" ]; then
    ( cd "$MOODLE_DIR" && npm install --no-audit --no-fund --loglevel=error )
fi

echo "==> [8/8] Ferramentas de bancada (moodle-dev-tools — conjunto curado)"
if [ ! -d "$TOOLS_DIR/.git" ]; then
    git clone --depth 1 \
        https://github.com/jeanlucio/moodle-dev-tools.git "$TOOLS_DIR"
fi
bash "$WORKSPACE/.devcontainer/install-tools.sh"

echo ""
echo "Ambiente pronto. O site sobe automaticamente no boot, na porta 8000."
echo "Login: admin / Sandbox123!"
