# O ambiente por dentro

Referência de infraestrutura do Moodle Plugin Lab — como o Codespace está montado
(banco, servidor, ciclo de vida, ferramentas).

## Topologia

Tudo roda **nativo no próprio Codespace** — PHP, MariaDB e o servidor web. Não use
`docker` nem `docker exec` (as ferramentas de bancada rodam PHP direto).

```
/workspaces/moodle-plugin-lab/
├── .devcontainer/      build da imagem + scripts de setup/boot
├── .github/            instruções para o Copilot
├── bin/                comandos do laboratório (no PATH)
├── docs/               esta documentação
├── moodle/             código do Moodle 5.2  (git próprio, NÃO versionado no lab)
│   ├── config.php      gerado no setup; wwwroot dinâmico
│   ├── public/         docroot do servidor web
│   │   ├── local/<seus plugins>/   cada um seu próprio repositório git
│   │   ├── blocks/ mod/ filter/ report/ ...
│   │   └── local/moodlecheck/      verificador de PHPDoc (o mesmo do CI)
│   └── node_modules/   dependências do grunt/eslint/stylelint
├── moodledata/         dados do site  (NÃO versionado)
├── phpunitdata/        dados do ambiente de teste  (NÃO versionado)
└── tools/              moodle-dev-tools clonado no setup  (NÃO versionado)
```

`.gitignore` do laboratório ignora `moodle/`, `moodledata/`, `phpunitdata/`, `tools/`.

## Banco de dados

- **MariaDB** no próprio container. Sobe no boot (`sudo service mariadb start`).
- Banco `moodle`, usuário `moodle`, senha `moodle`, prefixo `mdl_`.
- Acesso: `mysql -umoodle -pmoodle moodle` ou porta 3306 encaminhada.

## Servidor web

- **Servidor embutido do PHP** (`php -S 0.0.0.0:8000 -t moodle/public`), suportado
  oficialmente pelo Moodle para desenvolvimento.
- `PHP_CLI_SERVER_WORKERS=4` — permite requisições concorrentes (o AJAX de uma página).
- `wwwroot` é calculado em runtime a partir do header `Host` (o domínio do Codespace é
  diferente para cada aluno), com `$CFG->sslproxy = 1` sob o proxy TLS do GitHub.
- Log do servidor: `moodledata/phpserver.log`.
- Reiniciar: `pkill -f 'php -S 0.0.0.0:8000' ; bash .devcontainer/start.sh`

## Ciclo de vida do Codespace

| Gatilho | Script | Quando |
|---|---|---|
| `onCreateCommand` | `.devcontainer/setup.sh` | uma vez, no prebuild — clona Moodle, instala site, clona ferramentas |
| `postCreateCommand` | `.devcontainer/seed-author.sh` | quando o Codespace nasce — adivinha seu nome |
| `postStartCommand` | `.devcontainer/start.sh` | todo boot — sobe MariaDB e o servidor |
| primeiro terminal | `.devcontainer/first-run.sh` | uma vez — confirma seu nome |

**Rebuild do container** re-executa o `setup.sh`: o site volta ao estado limpo. Seus
plugins só sobrevivem se você tiver feito `git push` para o repositório de cada um.

## Purgar caches

Sempre que:
- adicionar/remover arquivo de função de plugin (`lib.php`, callbacks, hooks);
- bumpar `version.php` ou mexer em `db/`;
- editar `amd/src/*.js` (depois do `npx grunt amd`).

```
plugin-upgrade          # roda o upgrade do banco + purga os caches
```

ou, só a purga:

```
php moodle/public/admin/cli/purge_caches.php
```

## PHPUnit

Ambiente de teste preparado no prebuild (`$CFG->phpunit_prefix = 'phpu_'`). Rodar a suíte
de um plugin:

```
moodle-phpunit local/meuplugino
```

Recriar o ambiente (após DB limpo ou erro estranho):

```
php moodle/public/admin/tool/phpunit/cli/init.php
```

## Ferramentas (`bin/` + moodle-dev-tools curado)

| Comando | O que faz |
|---|---|
| `plugin-new <tipo> <nome>` | cria o esqueleto de um plugin + SCOPE.md + regras da IA + git init |
| `plugin-rules [tipo/nome]` | (re)copia `.github/copilot-instructions.md` + `instructions/` para um plugin |
| `plugin-upgrade` | `admin/cli/upgrade.php` + `purge_caches.php` |
| `set-author "Nome"` | muda o nome dos cabeçalhos `@copyright` |
| `moodle-check <arquivo.php>` | `local_moodlecheck` (PHPDoc, o mesmo gate do CI) |
| `moodle-phpunit <tipo/nome>` | suíte PHPUnit de um plugin |
| `moodle-coverage <tipo/nome>` | cobertura de testes (Xdebug) |
| `moodle-phpstan <tipo/nome>` | análise estática de tipos |
| `moodle-scope-audit <tipo/nome>` | confere árvore do SCOPE §6 contra o disco |
| `git commit` | dispara o hook: PHPCS + gates (capability, get_string, ...) |

**Fora do laboratório** (dependem de múltiplos containers): `moodle-upgrade`,
`moodle-check-schema`, `moodle-security-audit`, monitores Telegram. A revisão por IA no
pre-commit está **desligada** (`SKIP_AI=1`) — a camada de IA aqui é o Copilot Chat.

## Behat

**Não roda localmente** neste ambiente (subir um segundo site + Selenium estoura a
memória de um Codespace padrão). Escreva os `.feature` e deixe o **CI** (GitHub Actions)
executá-los.
