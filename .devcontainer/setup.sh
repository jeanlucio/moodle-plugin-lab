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

echo "==> [1/7] MariaDB — serviço e banco"
sudo service mariadb start
sudo mysql <<'SQL'
CREATE DATABASE IF NOT EXISTS moodle DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'moodle'@'%' IDENTIFIED BY 'moodle';
GRANT ALL PRIVILEGES ON moodle.* TO 'moodle'@'%';
FLUSH PRIVILEGES;
SQL

echo "==> [2/7] Código do Moodle ($MOODLE_BRANCH)"
if [ ! -d "$MOODLE_DIR/.git" ]; then
    git clone --branch "$MOODLE_BRANCH" --depth 1 \
        https://github.com/moodle/moodle.git "$MOODLE_DIR"
fi
mkdir -p "$DATAROOT"

echo "==> [3/7] Dependências PHP do Moodle (composer) — obrigatório no 5.x"
if [ ! -d "$MOODLE_DIR/vendor" ]; then
    ( cd "$MOODLE_DIR" && composer install --no-interaction --no-progress )
fi

echo "==> [4/7] local_moodlecheck (verificador de PHPDoc, o mesmo do CI)"
if [ ! -d "$MOODLE_DIR/public/local/moodlecheck" ]; then
    git clone --depth 1 \
        https://github.com/moodlehq/moodle-local_moodlecheck.git \
        "$MOODLE_DIR/public/local/moodlecheck"
fi

echo "==> [5/7] Instalação do site Moodle"
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

    # wwwroot dinâmico (o host muda por Codespace) + suporte a proxy TLS do GitHub.
    bash "$WORKSPACE/.devcontainer/patch-config.sh" "$MOODLE_DIR/config.php"

    # Português do Brasil (best-effort — se a rede do langpack falhar, segue em inglês).
    php "$WORKSPACE/.devcontainer/moodle-langpack.php" pt_br || \
        echo "aviso: pt_br não instalado automaticamente; instale em Admin > Idioma."
    php "$CLI/cfg.php" --name=lang --set=pt_br || true

    # Ambiente PHPUnit (segundo conjunto de tabelas + dataroot próprio).
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
        mkdir -p "$WORKSPACE/phpunitdata"
        php "$MOODLE_DIR/public/admin/tool/phpunit/cli/init.php" || true
    fi
fi

echo "==> [6/7] Dependências de build do Moodle (grunt, eslint, stylelint)"
if [ ! -d "$MOODLE_DIR/node_modules" ]; then
    ( cd "$MOODLE_DIR" && npm install --no-audit --no-fund --loglevel=error )
fi

echo "==> [7/7] Ferramentas de bancada (moodle-dev-tools — conjunto curado)"
if [ ! -d "$TOOLS_DIR/.git" ]; then
    git clone --depth 1 \
        https://github.com/jeanlucio/moodle-dev-tools.git "$TOOLS_DIR"
fi
bash "$WORKSPACE/.devcontainer/install-tools.sh"

echo ""
echo "Ambiente pronto. O site sobe automaticamente no boot, na porta 8000."
echo "Login: admin / Sandbox123!"
