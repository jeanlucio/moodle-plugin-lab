#!/usr/bin/env bash
# postStartCommand — roda em todo boot. Sobe o banco e o servidor, e se auto-cura:
# o /var/lib/mysql fica dentro do container e some num rebuild/restart do Codespace,
# mas moodle/config.php e moodledata/ ficam em /workspaces e sobrevivem.
set -euo pipefail

WORKSPACE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MOODLE_DIR="$WORKSPACE/moodle"
CLI="$MOODLE_DIR/admin/cli"

db() { mysql -umoodle -pmoodle -h127.0.0.1 moodle -e "$1" >/dev/null 2>&1; }

sudo service mariadb start

sudo mysql <<'SQL' 2>/dev/null || true
CREATE DATABASE IF NOT EXISTS moodle DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'moodle'@'%' IDENTIFIED BY 'moodle';
GRANT ALL PRIVILEGES ON moodle.* TO 'moodle'@'%';
FLUSH PRIVILEGES;
SQL

if [ -f "$MOODLE_DIR/config.php" ]; then
    # Auto-cura: o site foi instalado mas o schema sumiu (reset do datadir num rebuild).
    if ! db "SELECT 1 FROM mdl_config LIMIT 1"; then
        echo "Banco vazio — reinstalando o schema do Moodle (~1 min)..."
        php "$CLI/install_database.php" --agree-license \
            --adminuser=admin --adminpass='Sandbox123!' \
            --adminemail='admin@example.invalid' \
            --fullname='Moodle Plugin Lab' --shortname='lab' --lang=en
    fi

    # Português do Brasil: baixa o pacote uma vez; garante o idioma padrão em todo boot
    # (o install_database.php acima deixa 'en' quando reinstala o schema).
    if db "SELECT 1 FROM mdl_config LIMIT 1"; then
        [ -d "$WORKSPACE/moodledata/lang/pt_br" ] || \
            php "$WORKSPACE/.devcontainer/moodle-langpack.php" pt_br || true
        php "$CLI/cfg.php" --name=lang --set=pt_br >/dev/null 2>&1 || true
    fi

    # Ambiente PHPUnit: reinstala se as tabelas phpu_ sumiram (mesmo motivo).
    if grep -q phpunit_prefix "$MOODLE_DIR/config.php" \
       && db "SELECT 1 FROM mdl_config LIMIT 1" \
       && ! db "SELECT 1 FROM phpu_config LIMIT 1"; then
        php "$MOODLE_DIR/public/admin/tool/phpunit/cli/init.php" >/dev/null 2>&1 || true
    fi
fi

# Servidor web embutido do PHP (suportado oficialmente pelo Moodle para dev).
# PHP_CLI_SERVER_WORKERS=4 permite requisições concorrentes (o AJAX de uma página).
if ! pgrep -f "php -S 0.0.0.0:8000" >/dev/null 2>&1; then
    PHP_CLI_SERVER_WORKERS=4 nohup php -S 0.0.0.0:8000 -t "$MOODLE_DIR/public" \
        >"$WORKSPACE/moodledata/phpserver.log" 2>&1 &
    disown || true
fi

echo "Moodle no ar: porta 8000  ·  admin / Sandbox123!"
