# Regras de desenvolvimento de plugins Moodle

Instruções para a IA (Copilot Chat) neste repositório. Ao gerar, alterar ou revisar
código PHP, JS, CSS, Mustache ou SQL de um plugin Moodle, siga estas regras. A
referência completa e comentada está em `docs/REGRAS-DE-CODIGO.md`.

> **Idioma:** responda ao aluno em **português do Brasil**. Comentários no código: **inglês**.

## Estrutura de arquivo PHP

- Sempre `<?php` longo. Nunca fechar com `?>`.
- Todo arquivo novo começa com o cabeçalho GPL v3+ do Moodle, seguido do bloco PHPDoc
  com `@package` (Frankenstyle puro, ex.: `local_gradeboard`), `@copyright <ano> <autor>`,
  `@license https://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later`.
- `defined('MOODLE_INTERNAL') || die();` em arquivos com efeito colateral em escopo global
  (`db/*.php` que populam arrays, `settings.php`). **Não** em arquivos que só definem uma
  classe, nem em `lib.php` (só funções).
- Nenhuma linha de PHP acima de **132 caracteres** (exceção: valores de string em `lang/`).
- Zero espaço em branco no fim de linha. Arquivo termina com um único `\n`.

## PHP — estilo e APIs

- Type hints e return types **obrigatórios** em toda função/método novo.
- `[$a, $b] = ...` nunca `list()`. Arrays sempre `[]` nunca `array()`.
- `else if` nunca `elseif`. Sempre chaves, mesmo em bloco de uma linha.
- `new stdClass()` ou cast `(object)[...]`, nunca `object`.
- Classes novas em `classes/` com namespace (`namespace local_gradeboard\local;`) — o Moodle
  faz autoload. **Nunca** `require_once` para algo em `classes/`.
- `lib.php` só para callbacks legados sem equivalente (ex.: `*_extend_navigation_*`).
  Nunca criar `locallib.php` (depreciado).
- Exceções: `throw new moodle_exception(...)`. `coding_exception` só para erro de
  programador, nunca para regra de negócio que o usuário pode disparar.

## Banco de dados

- **Nunca** `$DB->get_record`/`get_records` dentro de `foreach`/`for`/`while` (N+1).
  Carregue em massa antes (`$DB->get_in_or_equal()`, `get_records_sql()`).
- **Nunca** concatenar variável em SQL. Placeholders `:nome` ou `?`, sempre.
- `$DB->update_record()`/`insert_record()`, nunca `$DB->execute()` para DML do dia a dia.
- Tabelas: `a-z 0-9 _`, começam com letra, máx. **53 caracteres** (nome de tabela) /
  **63** (campo), incluindo o prefixo Frankenstyle.
- `install.xml` hand-made deve ter `SEQUENCE="false"` explícito em todo campo não-autonumber
  e os atributos `xmlns:xsi`/`xsi:noNamespaceSchemaLocation` na raiz `<XMLDB>`.
- `db/upgrade.php` **sempre existe**, mesmo vazio (`return true;`) — o Directory rejeita o
  zip sem ele.

## Segurança

- **Nunca** `echo $var`. Use `s()` (texto puro), `format_string()` (nomes/títulos),
  `format_text($t, FORMAT_HTML, ['context' => $ctx])` (HTML rico) — nunca `['noclean' => true]`.
- Todo POST: `require_sesskey()`. Todo entry point: `require_login()` + `require_capability()`
  no contexto certo (`context_course`, `context_module`, `context_system`).
- `get_record` que recebe ID externo: filtre também por `instanceid`/`courseid`/`contextid`
  já validado — nunca opere por PK isolada.
- Proibido: `eval()`, `goto`, backticks de shell, `preg_replace` com `/e`,
  `unserialize()` com dado de usuário (use `unserialize_object()`).
- Toda capability em `db/access.php` tem string de lang correspondente.
- Plugin que chama serviço externo (IA, API): declarar em `classes/privacy/provider.php`
  via `$collection->add_external_location_link()`. Todo plugin tem Privacy Provider —
  se não guarda dado pessoal nem chama fora, use `null_provider`.

## Limpeza ao excluir

- Tabela com id de instância própria (`blockinstanceid`, id do `mod_*`): limpar em
  `block_base::instance_delete()` / `<modname>_delete_instance()` — **todas** as tabelas
  filhas, não só a principal.
- Tabela com `courseid`: observer de `\core\event\course_deleted` em `db/events.php` +
  `classes/observer.php`.

## Front-end

- **Zero texto hardcoded.** `get_string()` no PHP; strings passadas ao JS.
- HTML só em `.mustache` (ou renderers), nunca em PHP. Todo template tem
  `@template component/nome` no segundo bloco `{{! ... }}` e o rótulo `Example context (json):`.
- Bootstrap 5: `ms-`/`me-`/`text-end`/`data-bs-dismiss`. Nunca BS4 (`ml-`/`mr-`/`text-right`).
- CSS: sem `!important`; sem `style="..."` estático (dinâmico por render, ex. largura de
  barra, é aceitável); todo seletor escopado com `.path-<tipo>-<nome>`; cores via
  `var(--nome, #fallback)`.
- `.visually-hidden` definido pelo próprio plugin, nunca `.sr-only`.

## JavaScript

- Só módulos AMD em `amd/src/`, carregados via `$PAGE->requires->js_call_amd()`. Nunca
  `<script>` em PHP/HTML.
- `const` por padrão, `let` só se reatribui, nunca `var`. `===`/`!==` sempre.
  `async/await`, arrow functions, template literals, destructuring.
- Dados PHP→JS: scalars no 3º arg de `js_call_amd`; mapas/listas do banco via atributo
  `data-*` ou `<script type="application/json">`.
- `core/modal` (nunca `core/modal_factory`, removido no 5.2). `core/ajax`, `core/str`,
  `core/notification`. Nunca `jQuery.ajax` nem `execCommand`.

## Acessibilidade

- Ícone/emoji decorativo: `aria-hidden="true"`. `<img>` decorativa: `alt=""`.
- Botão/link só com ícone: `aria-label` ou `<span class="visually-hidden">`.
- Todo `<input>`/`<select>`/`<textarea>`: `<label>` ou `aria-label` (placeholder não conta).
- `<th>` com `scope="col"`/`scope="row"`. Contraste mínimo 4.5:1. Nunca cor sozinha para
  transmitir estado.

## i18n

- `lang/en/` e `lang/pt_br/` sempre em sincronia (mesma chave, mesmo commit).
- Chaves em **ordem alfabética estrita** — inserir na posição certa, nunca no fim.
- Valores em **uma linha**. Sem comentário inline em arquivo de lang.
- pt-BR: "estudante(s)", **nunca** "aluno(s)".

## Testes

- Suporta Moodle 4.5 **e** 5.x → anotações PHPDoc (`@covers`, `@dataProvider`), nunca
  atributos PHP (`#[CoversClass]`).
- `@covers \Classe` no nível da classe de teste, sem `::metodo`.
- Lógica de negócio em `classes/local/` (testável); camada de request/render fina e
  separada.

## Commits

- Mensagem: resumo curto (~72 chars), sem prefixo de componente, sem `MDL-xxxx` falso.
- **Nunca** adicionar linha de co-autoria de IA.
