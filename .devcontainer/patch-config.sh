#!/usr/bin/env bash
# Reescreve o wwwroot do config.php gerado pelo instalador para funcionar no Codespace.
# O GitHub Codespaces codifica a porta no subdomínio e manda o header Host com um
# ":8000" interno; sem normalizar isso, todas as URLs do Moodle ficam quebradas.
# Idempotente: pode rodar de novo para atualizar o bloco.
set -euo pipefail

CONFIG="${1:?uso: patch-config.sh <caminho/para/config.php>}"

python3 - "$CONFIG" <<'PY'
import re
import sys

path = sys.argv[1]
with open(path) as handle:
    src = handle.read()

block = """// >>> MOODLE_PLUGIN_LAB_WWWROOT >>>
$mplcs = getenv('CODESPACE_NAME');
$mpldom = getenv('GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN') ?: 'app.github.dev';
if ($mplcs) {
    $mplhost = $mplcs . '-8000.' . $mpldom;
    $_SERVER['HTTP_HOST'] = $mplhost;
    $_SERVER['SERVER_PORT'] = 443;
    $_SERVER['HTTPS'] = 'on';
    $CFG->wwwroot = 'https://' . $mplhost;
    $CFG->sslproxy = 1;
} else {
    $CFG->wwwroot = getenv('MOODLE_WWWROOT_FALLBACK') ?: 'http://localhost:8000';
}
// <<< MOODLE_PLUGIN_LAB_WWWROOT <<<
"""

marker = re.compile(
    r"// >>> MOODLE_PLUGIN_LAB_WWWROOT >>>.*?// <<< MOODLE_PLUGIN_LAB_WWWROOT <<<\n",
    re.S,
)
# Bloco antigo (formato anterior, sem os delimitadores >>> / <<<).
legacy = re.compile(
    r"// MOODLE_PLUGIN_LAB_DYNAMIC_WWWROOT.*?MOODLE_WWWROOT_FALLBACK[^\n]*\n\}\n",
    re.S,
)
if marker.search(src):
    new = marker.sub(block, src, count=1)
elif legacy.search(src):
    new = legacy.sub(block, src, count=1)
else:
    new, count = re.subn(r"\$CFG->wwwroot\s*=\s*'[^']*';\n", block, src, count=1)
    if count != 1:
        sys.exit("patch-config.sh: linha do wwwroot nao encontrada em " + path)

with open(path, 'w') as handle:
    handle.write(new)
PY
