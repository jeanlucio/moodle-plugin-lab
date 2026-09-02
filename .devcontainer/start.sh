#!/usr/bin/env bash
# postStartCommand — roda em todo boot. Leve: só sobe o banco e o servidor web.
set -euo pipefail

WORKSPACE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MOODLE_DIR="$WORKSPACE/moodle"

sudo service mariadb start

# Servidor web embutido do PHP — suportado oficialmente pelo Moodle para desenvolvimento.
# PHP_CLI_SERVER_WORKERS=4 permite requisições concorrentes (o AJAX de uma mesma página).
if ! pgrep -f "php -S 0.0.0.0:8000" >/dev/null 2>&1; then
    PHP_CLI_SERVER_WORKERS=4 nohup php -S 0.0.0.0:8000 -t "$MOODLE_DIR/public" \
        >"$WORKSPACE/moodledata/phpserver.log" 2>&1 &
    disown || true
fi

echo "Moodle no ar: porta 8000  ·  admin / Sandbox123!"
