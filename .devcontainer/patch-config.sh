#!/usr/bin/env bash
# Troca o wwwroot fixo do config.php gerado pelo instalador por um bloco que deriva
# o endereço do header Host — o domínio do Codespace é diferente para cada aluno.
set -euo pipefail

CONFIG="${1:?uso: patch-config.sh <caminho/para/config.php>}"

if grep -q 'MOODLE_PLUGIN_LAB_DYNAMIC_WWWROOT' "$CONFIG"; then
    exit 0
fi

python3 - "$CONFIG" <<'PY'
import re
import sys

path = sys.argv[1]
with open(path) as handle:
    src = handle.read()

block = """// MOODLE_PLUGIN_LAB_DYNAMIC_WWWROOT: o host do Codespace muda por aluno.
if (!empty($_SERVER['HTTP_HOST'])) {
    $forwardedhttps = !empty($_SERVER['HTTP_X_FORWARDED_PROTO'])
        && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https';
    $directhttps = !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off';
    $scheme = ($forwardedhttps || $directhttps) ? 'https' : 'http';
    $CFG->wwwroot = $scheme . '://' . $_SERVER['HTTP_HOST'];
    if ($scheme === 'https') {
        $CFG->sslproxy = 1;
    }
} else {
    $CFG->wwwroot = getenv('MOODLE_WWWROOT_FALLBACK') ?: 'http://localhost:8000';
}
"""

new, count = re.subn(r"\$CFG->wwwroot\s*=\s*'[^']*';\n", block, src, count=1)
if count != 1:
    sys.exit("patch-config.sh: linha do wwwroot nao encontrada em " + path)

with open(path, 'w') as handle:
    handle.write(new)
PY
