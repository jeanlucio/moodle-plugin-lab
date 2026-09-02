#!/usr/bin/env bash
# Garante o servidor web de pé. Idempotente. Usa setsid para que o processo
# sobreviva ao fim do shell que o chamou (lifecycle command do Codespaces mata
# a sessão inteira quando termina — nohup/disown não bastam).
set -euo pipefail

WORKSPACE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MOODLE_DIR="$WORKSPACE/moodle"

sudo service mariadb start >/dev/null 2>&1 || true

if ! pgrep -f "php -S 0.0.0.0:8000" >/dev/null 2>&1; then
    mkdir -p "$WORKSPACE/moodledata"
    PHP_CLI_SERVER_WORKERS=4 setsid --fork \
        php -S 0.0.0.0:8000 -t "$MOODLE_DIR/public" \
        </dev/null >>"$WORKSPACE/moodledata/phpserver.log" 2>&1
    echo "servidor iniciado na porta 8000"
else
    echo "servidor já rodando na porta 8000"
fi
