---
applyTo: "**/db/**"
---

# Arquivos `db/` e schema (XMLDB)

## Todos os arquivos `db/`

- **Nunca** `require_once`/`include`, **nunca** código com efeito colateral em tempo de
  include — o Moodle os parseia em caminhos sensíveis a performance.
- `defined('MOODLE_INTERNAL') || die();` quando populam array global (`access.php`,
  `tasks.php`, `events.php`, `hooks.php`). **Não** em `upgrade.php` (só declara uma função).

## `db/install.xml`

- Nomes de tabela/campo: só `a-z 0-9 _`, começam com letra. Máx. **53 chars** (tabela) /
  **63** (campo), incluindo o prefixo Frankenstyle.
- Toda tabela com `timecreated` e `timemodified` (`INT`, NOTNULL) desde o início.
- **Formato canônico** (bate com o editor XMLDB embutido): todo campo não-autonumber com
  `SEQUENCE="false"` explícito (só o `id` tem `SEQUENCE="true"`); raiz `<XMLDB>` com
  `xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"` +
  `xsi:noNamespaceSchemaLocation="..."` (profundidade relativa ao aninhamento do plugin —
  ver um `install.xml` do core como referência).
- `install.xml` sempre reflete o schema **após** todos os passos de `db/upgrade.php`.

## `db/upgrade.php`

- **Sempre existe**, mesmo sem passo real:
  `function xmldb_<plugin>_upgrade(int $oldversion): bool { return true; }`. O validador do
  Plugins Directory rejeita o zip sem ele. Nunca apagar para "limpar".
- Único lugar para migração de schema/dados. Bump de `version.php` para cada passo.

## `db/access.php`

- Editar o config inicial só afeta instalações **novas** — sites existentes não são
  atualizados. Mudança de permissão em site instalado → passo de `upgrade.php` ou doc manual.
- Toda capability tem string de lang correspondente (`tipo/nome:cap` → `$string['nome:cap']`).

## `db/events.php` e limpeza ao excluir

- **Nunca** assinar evento de **outro componente** sem declarar dependência formal dele.
- **Tabela com `courseid`** (dado do curso): observer de `\core\event\course_deleted` aqui +
  `classes/observer.php` que deleta. O Moodle **não** cascateia tabela de plugin ao excluir
  curso; `KEY TYPE="foreign"` no XMLDB é só documentação. Exceção: tabela puramente de
  log/auditoria pode manter `courseid` órfão se a leitura degrada graciosamente.
- **Tabela com id de instância própria** (`blockinstanceid`, id do `mod_*`): deletar em
  `block_base::instance_delete()` / `<modname>_delete_instance()` — **todas** as tabelas
  filhas, não só a linha-pai.

## `db/tasks.php`

- Usar `R` (random) para `minute`/`hour`/`day`/`dayofweek` — espalha a carga do cron.

## `db/uninstall.php`

- Criar **apenas** se há `user_preferences` (deletar por prefixo do Frankenstyle) ou dado
  em tabela **core**. O core já limpa as tabelas do `install.xml` + settings sozinho —
  nunca repetir.
