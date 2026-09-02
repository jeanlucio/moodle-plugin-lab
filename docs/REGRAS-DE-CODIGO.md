# Regras de código — desenvolvimento de plugins Moodle

Referência completa. A versão curta e acionável (a que o Copilot carrega em todo prompt)
está em `.github/copilot-instructions.md`. Tudo aqui segue o
[Coding style](https://moodledev.io/general/development/policies/codingstyle) oficial do
Moodle e o
[Plugin contribution checklist](https://moodledev.io/general/community/plugincontribution/checklist).

---

## 1. Estrutura de arquivos

### PHP

- Sempre `<?php` longo. **Nunca** o `?>` de fechamento.
- Todo arquivo novo começa com o cabeçalho GPL v3+ **imediatamente** após `<?php` (sem linha
  em branco), seguido do bloco PHPDoc:

  ```php
  <?php
  // This file is part of Moodle - https://moodle.org/
  //
  // Moodle is free software: you can redistribute it and/or modify
  // it under the terms of the GNU General Public License as published by
  // the Free Software Foundation, either version 3 of the License, or
  // (at your option) any later version.
  //
  // Moodle is distributed in the hope that it will be useful,
  // but WITHOUT ANY WARRANTY; without even the implied warranty of
  // MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  // GNU General Public License for more details.
  //
  // You should have received a copy of the GNU General Public License
  // along with Moodle.  If not, see <https://www.gnu.org/licenses/>.

  /**
   * Short one-line description of the file.
   *
   * @package    local_example
   * @copyright  <ano> <seu nome>
   * @license    https://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
   */
  ```

- `defined('MOODLE_INTERNAL') || die();` **apenas** em arquivos com efeito colateral em
  escopo global (`db/access.php`, `db/tasks.php`, `db/events.php`, `db/hooks.php`,
  `settings.php`, arquivos de `lang/`). **Não** em arquivos que só definem uma classe/trait/
  interface. **Não** em `lib.php` (só declara funções — o guard ali faz o PHPCS reclamar
  "Unexpected MOODLE_INTERNAL check. No side effects").
- Nenhuma linha de PHP acima de **132 caracteres**. Exceção: o **valor** de uma string em
  `lang/` pode ocupar uma linha de qualquer tamanho.
- Zero espaço em branco no fim de linha. Arquivo termina com **um único** `\n` (sem `\r`,
  sem linha em branco extra).

### CSS (`styles.css`)

Cabeçalho duplo: bloco de licença GPL em `/** ... */`, imediatamente seguido do bloco JSDoc
com `@package`, `@copyright`, `@license`, sem linha em branco entre eles.

---

## 2. Nomenclatura

- **Frankenstyle:** componente **em inglês**, minúsculo, curto (idealmente um token, sem
  `_` na parte do nome). Verificar livre no Plugins Directory antes de fixar. Renomear
  depois cascateia em tabelas, capabilities, chaves de lang e caminhos.
- **Nome de exibição** (string `pluginname`): separado do Frankenstyle e **localizável** —
  pode ser em português.
- **Arquivos:** minúsculas, palavras em inglês. Extensões `.php`, `.js`, `.css`, `.mustache`,
  `.xml`.
- **Classes:** minúsculas com underscore. Sempre `()` ao instanciar, mesmo sem argumentos.
- **Funções/métodos:** minúsculas com underscore. Função global tem prefixo Frankenstyle
  (`local_example_do_something()`).
- **Variáveis:** minúsculas, sem underscore (concatene as palavras). Plural para arrays.
  Nomes positivos (`$allowsomething`, não `$preventsomething`).
- **Constantes:** MAIÚSCULAS com underscore, prefixo Frankenstyle
  (`LOCAL_EXAMPLE_MAX_ITEMS`).
- **`true`/`false`/`null`** sempre minúsculos.
- **Web Services:** `{type_name}_{verbo}_{substantivo}` (`local_example_get_items`).

---

## 3. PHP — estilo e APIs

- Type hints e return types **obrigatórios** em toda posição possível, em função/método novo.
- `[$a, $b] = ...` nunca `list()`. `[]` nunca `array()`.
- `else if` nunca `elseif`. Chaves sempre, mesmo em bloco de uma linha. Chave de abertura na
  mesma linha da declaração. `return` sem parênteses.
- `new stdClass()` ou cast `(object)['k' => 'v']` — nunca `object` (depreciado).
- Visibilidade sempre explícita (`private`/`protected`/`public`). `var` proibido. Preferir
  getters/setters a propriedade pública.
- Métodos mágicos (`__get`/`__set`) fortemente desencorajados.
- Ternário só para expressão curta. Preferir `??`.
- Aspas simples para string literal e HTML; duplas ao interpolar variável; SQL complexo
  sempre em duplas.
- `#[\Override]` em método que sobrescreve sem mudar semântica — **sem** repetir o docblock.
  `@inheritdoc` é proibido.

### Autoloading e includes

- Classes novas em `classes/` com namespace correto (`namespace local_example\local;`) — o
  Moodle faz autoload. **Nunca** `require_once`/`include` para algo em `classes/`.
- `require_once` só para bibliotecas de função global / scripts legados (`lib.php`).
- Entry point via navegador começa com `require(__DIR__ . '/../../config.php');`. CLI define
  `CLI_SCRIPT` **antes** do `config.php`. Nunca caminho relativo com `../` para `config.php`
  em CLI.
- `require_once` com `__DIR__` ou caminho absoluto (`$CFG->dirroot`, `$CFG->libdir`). Nunca
  `../`.
- Includes no topo do arquivo ou dentro de funções — nunca no meio do escopo global.

### `lib.php` e `locallib.php`

- `lib.php` é arquivo-**ponte** legado. Use só para callbacks/hooks sem equivalente
  autoloadable (ex.: `<frankenstyle>_extend_navigation_*`, que o core descobre
  exclusivamente via `get_plugins_with_function('<fn>', 'lib.php')`). O Moodle carrega
  **todos** os `lib.php` em muitas requisições — mantenha mínimo.
- `locallib.php` é **depreciado**. Nunca criar um. Lógica de suporte global vai em classe
  autoloaded em `classes/`.

### Namespaces

- Nível 1 (obrigatório): componente Frankenstyle (`\local_example`) ou `\core`.
- Nível 2 (opcional): nome curto de API do core (`\event`, `\external`, `\privacy`, `\task`,
  `\output`) ou `\local` para classes internas.
- Um `use` por linha. Não importar namespace inteiro. Sem alias sem conflito real. `use` em
  ordem alfabética, uma linha em branco depois do último. Nunca prefixar `namespace`/`use`
  com `\`.
- `@package` no PHPDoc é **sempre** o Frankenstyle puro (`local_example`) — nunca com sufixo
  de namespace.

---

## 4. PHPDoc

- Todas as classes, métodos, funções, propriedades e constantes com PHPDoc completo.
- `@param`: tipo, depois `$nome`, depois descrição (sem traço entre nome e descrição).
- `@return`: obrigatório se a função tem `return`.
- `@var`: obrigatório em toda propriedade de classe.
- `@throws` recomendado. `@since` ao adicionar a core. `@deprecated` com referência e `@see`
  ao substituto.
- Tipos: nomes curtos (`int`, `bool`, `string`), `tipo[]` para array tipado, `|` para
  múltiplos, tudo minúsculo exceto nome de classe. Preferir um único tipo de retorno.
- **Sintaxe genérica quebra o `local_moodlecheck`:** use `array` simples e descreva a forma
  na prosa (`@param array $x Keyed by "..."`), não `array<string, string>`.
- Comentário inline: só `// ` (duas barras + espaço). Primeira letra maiúscula (ou dígito).
  Termina com `.`, `?` ou `!`. Nunca `/* */` para uma linha, nunca `#`.
- Todos os comentários em **inglês**. Comente lógica complexa, comportamento não óbvio,
  contrato de função, workaround — nunca reafirme o que o nome do código já diz.

---

## 5. Banco de dados

### Performance

- **Nunca** `$DB->get_record`/`get_records`/`get_field` dentro de `foreach`/`for`/`while`
  (antipadrão N+1). Carregue em massa antes (`$DB->get_in_or_equal()`,
  `$DB->get_records_sql()`), agrupe em array PHP, então itere.
- Deleção em lote: `$DB->delete_records_select()`.
- Nunca `$DB->execute()` para UPDATE/INSERT/DELETE do dia a dia (ignora caches). Ciclo:
  `get_record()` → validar/calcular em PHP (`max(0, $v)` em vez de `GREATEST` no SQL) →
  atualizar propriedades → `update_record()`.
- Contador de loop vindo do cliente (`optional_param` usado como número de repetições)
  precisa de teto explícito (`min(MAX, ...)`) — `PARAM_INT` valida que é inteiro, não que é
  razoável.

### Segurança

- **Nunca** concatenar variável em string SQL. Sempre a DML API com `:nome` ou `?`.
- `get_record` que recebe ID externo (URL, form, WS): incluir JOIN ou filtro por
  `instanceid`/`contextid`/`courseid` já validado pela checagem de capability — nunca operar
  por PK isolada. **Validar posse antes de qualquer leitura de dado relacionado**, não só
  antes da escrita.

### Schema (XMLDB)

- Nomes de tabela/campo: só `a-z 0-9 _`, começam com letra. Máx. **53 chars** (tabela) /
  **63** (campo) no Moodle 4.3+, incluindo o prefixo Frankenstyle. Preferir nomes curtos.
- `install.xml` deve bater atributo-por-atributo com o que o editor XMLDB embutido geraria:
  todo campo não-autonumber com `SEQUENCE="false"` explícito (só o `id` tem `SEQUENCE="true"`);
  raiz `<XMLDB>` com `xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"` +
  `xsi:noNamespaceSchemaLocation="..."` (profundidade relativa ajustada ao aninhamento —
  ver um `install.xml` do core). Omitir isso não muda a tabela criada, mas reprova a
  checagem de round-trip do core.
- `db/upgrade.php` **sempre existe**, mesmo sem passo real
  (`function xmldb_<plugin>_upgrade(int $oldversion): bool { return true; }`) — o validador
  do Plugins Directory rejeita o zip sem ele. Nunca apagar para "limpar".
- `install.xml` sempre reflete o schema **após** todos os passos de `db/upgrade.php`.
- `db/install.php` roda uma vez após a instalação inicial — nunca no upgrade. Não colocar
  lógica de upgrade ali.

### Arquivos `db/` (todos)

Nunca `require_once`/`include`, nunca código com efeito colateral em tempo de include — o
Moodle os parseia em caminhos sensíveis a performance. `defined('MOODLE_INTERNAL') || die();`
quando populam array global.

---

## 6. Limpeza ao excluir

- **Tabela com id de instância própria** (`blockinstanceid` para `block_*`, id do módulo
  para `mod_*`): deletar em `block_base::instance_delete()` /
  `<modname>_delete_instance($id)`. Uma hook que apaga só a linha-pai e esquece uma tabela
  filha é o mesmo bug numa forma sutil — cruze **toda** tabela do `install.xml` contra o
  que a hook apaga.
- **Tabela com `courseid`** (dado do curso, que sobrevive à remoção do bloco/atividade mas
  não à do curso): observer de `\core\event\course_deleted` em `db/events.php` +
  `classes/observer.php`. O Moodle **não** cascateia tabela de plugin ao excluir curso;
  `KEY TYPE="foreign"` no XMLDB é só documentação.
- Vale para `local_*`/`report_*` também. **Não** vale para tabela puramente de log/auditoria
  (pode manter `courseid` órfão, se o código de leitura degrada graciosamente).
- Teste de regressão exercitando o `delete_course()`/`delete_instance()` **real**.

### `db/uninstall.php`

- O core já limpa sozinho: tabelas do `install.xml`, settings (`config_plugins`), eventos,
  tarefas, capabilities, logs, handlers de mensagem. **Nunca repetir** no hook.
- O core **não** limpa: linhas em `user_preferences` (deletar por prefixo:
  `$DB->delete_records_select('user_preferences', $DB->sql_like('name', ':p'), ['p' => '<frankenstyle>_%'])`),
  dado que o plugin escreveu em outras tabelas **core** (arquivos, notas, tags, eventos de
  calendário sem `component`), tabelas criadas dinamicamente fora do `install.xml`.
- Plugin cuja única persistência é `install.xml` + settings **não precisa** de
  `db/uninstall.php`.

---

## 7. Segurança

- **Nunca** `echo $var` em HTML/PHP. Use `s()` (texto puro), `format_string()` (nomes/
  títulos), `format_text($t, FORMAT_HTML, ['context' => $ctx])` (HTML rico) — nunca
  `['noclean' => true]`.
- Todo form POST: `require_sesskey()` / `confirm_sesskey()`.
- Todo entry point: `require_login()` + `require_capability()` no contexto correto
  (`context_course`, `context_module`, `context_system`). Web Service: verificar que a
  entidade pertence ao contexto informado antes de qualquer efeito colateral.
- Toda regra de negócio imposta na UI: re-validar no servidor antes de persistir.
- Proibido: `eval()` (exceto pacotes de lang), `preg_replace` com `/e` (use callback),
  backticks de shell, `goto` e labels, `unserialize()` com dado de usuário
  (use `unserialize_object()`).
- Segredos em settings: `admin_setting_configpasswordunmask`, nunca `admin_setting_configtext`.
- CLI com credencial: flag obrigatória (`--password`) + guarda de ambiente.
- `ORDER BY` com coluna variável: validar contra allow-list antes de interpolar.
- Sem função específica de engine (`FROM_UNIXTIME`, `IF()`, `GROUP_CONCAT`) — use helpers do
  Moodle.
- Toda capability em `db/access.php` tem string de lang. Editar `db/access.php` só afeta
  instalações **novas** — sites existentes não são atualizados (use `db/upgrade.php` ou
  documente a mudança manual).

### Consumir uma linha — soft-delete vs. hard-delete

Antes de um `delete_records()` numa linha que "gasta" algo (unidade de inventário, ticket,
crédito), verifique se outro caminho de código conta/lê linhas históricas dessa tabela para
rate limit, quota ou auditoria. Se sim, vire uma coluna de status (`status = 'consumed'`)
em vez de apagar.

---

## 8. Exceções

- Reportar erros com exceções, sobretudo em código de biblioteca. Não usar exceção para
  fluxo de controle normal.
- `throw new moodle_exception(...)` — nunca `print_error()` (depreciado desde Moodle 4.0).
- Classes: `moodle_exception` (geral), `coding_exception` (erro de programador),
  `dml_exception` (falha de query), `file_exception` (File API).
- **`coding_exception` é só para erro real de programador** (uso errado de API), **nunca**
  para invariante de regra de negócio que uma ação normal do usuário pode disparar (status
  errado para uma transição, "não pode aprovar a própria submissão"). Isso vira o diálogo
  genérico "contate um desenvolvedor" com stack trace — tom e informação errados. Use
  `moodle_exception` com string traduzida.
- **No AMD:** quando o PHP lança um `moodle_exception` deliberado para uma regra prevista, o
  `.catch()` da chamada `Ajax.call()` mostra via `Notification.alert(title, error.message)`,
  não `Notification.exception(error)` (este é o diálogo genérico de erro, para falha
  genuinamente inesperada).
- Exceções customizadas podem ficar em `classes/exception/` com namespace
  `<plugin>\exception\`.

---

## 9. Front-end — HTML, Mustache, CSS

### Templates

- HTML só em `.mustache` (ou renderers). Nunca HTML dentro do PHP.
- Todo template tem `@template component/nome` no **segundo** bloco `{{! ... }}` e o rótulo
  exato `Example context (json):` (sem `@`).
- Toda `<img>` no JSON de exemplo com `alt="..."`. Nunca `<h1>`–`<h6>` vazio (use variável
  ou `&nbsp;`).
- `{{{valor}}}` só para markup confiável e estático. Campo **armazenado** (input do usuário,
  config de admin, conteúdo gerado por IA) usa `{{valor}}` e é sanitizado
  (`strip_tags()`/`clean_param()`) na escrita. Se o campo aparece em mais de uma view,
  auditar **todas**.

### CSS

- Preferência: classe utilitária do Bootstrap → classe semântica no `styles.css` do plugin
  → `style` inline **só** para valor dinâmico por render (ex.: largura de barra de
  progresso — é o que o core faz em `lib/templates/progress_bar.mustache`).
- **Nunca** `!important`. Resolver conflito aumentando a especificidade do seletor.
- Todo seletor escopado com a classe de página do plugin: `.path-<tipo>-<nome> .minha-classe`
  ou `#page-<caminho> .minha-classe`. Exceção: markup injetado numa página que o plugin não
  possui (ex.: saída de `<modname>_cm_info_dynamic()`, modal içado ao `<body>`) — escopar
  pelo id/classe mais específico disponível e deixar um comentário CSS explicando.
- Variáveis CSS do Moodle com fallback: `var(--card-bg, #fff)`. Nunca hex fixo solto.
- Propriedades lógicas para RTL: `margin-inline-start`, `text-align: start` em vez de
  `left`/`right`/`float`.
- **`.visually-hidden` definido pelo próprio plugin**, escopado à sua classe de página —
  nunca `.sr-only`, nunca depender da utilitária do Bootstrap:

  ```css
  .path-local-example .visually-hidden {
      position: absolute; width: 1px; height: 1px; padding: 0; margin: -1px;
      overflow: hidden; clip: rect(0, 0, 0, 0); white-space: nowrap; border: 0;
  }
  ```

### Bootstrap 4/5 (Moodle 4.5 usa BS4, 5.x usa BS5)

| Necessidade | ❌ só-BS5 | ✅ compatível |
|---|---|---|
| Ocultar texto | `visually-hidden` (indefinido no BS4 puro) | regra própria `.visually-hidden` |
| Espaçamento flex | `gap-1`, `gap-2` | `gap:` no CSS escopado, ou `me-2` |
| Fundo + texto do header | `text-bg-primary` | `bg-primary` + `text-white` explícito |

- Badge: `--bs-badge-color: #fff` vem via custom property; para sobrescrever a cor use
  seletor duplo `.badge.sua-classe { color: X }` (especificidade 0,2,0).
- Modais: plugin novo usa `core/modal` (nunca `core/modal_factory`, removido no 5.2). Botão
  de fechar com `data-bs-dismiss="modal"` **e** `data-dismiss="modal"` (BS5 + BS4).

---

## 10. JavaScript

- Nunca `<script>` em PHP/HTML. Só módulos AMD em `amd/src/`, carregados via
  `$PAGE->requires->js_call_amd()`. Recompilar `amd/build/` com `npx grunt amd` (de dentro
  da pasta do plugin) e commitar o build.
- APIs do core: `core/ajax` (nunca `jQuery.ajax`), `core/copy_to_clipboard` (nunca
  `execCommand`), `core/notification`, `core/str`, `core/modal`.
- `const` por padrão, `let` só se reatribui, **nunca** `var`. `===`/`!==` sempre.
  `async/await` em vez de cadeia de `.then()`. Arrow function para callback. Template
  literal em vez de concatenação. Destructuring ao ler múltiplas propriedades.
- Preferir vanilla JS a jQuery (`document.querySelector`) — jQuery não é garantido no
  Moodle 5.x.
- **Dados PHP→JS** (`js_call_amd` tem limite de ~1024 chars no argumento em modo dev):
  strings de UI via `$PAGE->requires->strings_for_js()`; scalars (IDs, booleans) no 3º
  argumento; config estruturada pequena (< ~500 chars) no 3º argumento; mapas/listas que
  crescem com dados do banco via **atributo `data-*`** (preferência oficial) ou
  **`<script type="application/json">`** (para JSON com `&`/`"`); dados grandes/dinâmicos via
  Web Service com `core/ajax`.
- Código existente não-conforme: não refatorar por estilo por iniciativa própria. Converter
  `function(){}` para arrow **não** é cosmético (arrow herda `this` lexicalmente) — checar
  todo `this` antes.

---

## 11. Acessibilidade (WCAG AA)

- Ícone (`fa-*`) e emoji decorativos: `aria-hidden="true"`. `<img>` decorativa: `alt=""`.
- Botão/link só com ícone: `aria-label="..."` ou `<span class="visually-hidden">` (o
  atributo `title` sozinho não basta).
- Todo `<input>`/`<select>`/`<textarea>`: `<label>` associado ou `aria-label` — placeholder
  não é rótulo. Checkbox em tabela: `aria-label` direto no `<input>`.
- `<th>` com `scope="col"`/`scope="row"`.
- Evitar `text-muted` em informação crítica. Contraste ≥ 4.5:1. Nunca cor sozinha para
  transmitir estado — acompanhar de ícone/texto/padrão.
- Barra de progresso / medidor visual: texto legível oculto com `.visually-hidden`.
- **Nunca** `.sr-only` em template (o Boost aplica `outline: 3px dotted red` sob
  `themedesignermode` e falha o CI `--scss-deprecations`). Use `.visually-hidden`.
- **Nunca** `.visually-hidden` dentro de `.table-responsive .table` nem sozinha dentro de
  `.activity-item` (o Boost sobrescreve). Ali use `title` + ícone, ou
  `role="img" aria-label="..."` no `<i>`.

---

## 12. Internacionalização

- Zero texto hardcoded. `get_string()` no PHP; strings passadas ao JS.
- Toda string nova em `lang/en/` tem equivalente em `lang/pt_br/` no **mesmo commit**.
- Chaves em **ordem alfabética estrita** — inserir na posição certa, nunca no fim. Ao
  inserir muitas de uma vez, fazer programaticamente (ler linhas cruas, achar o ponto pelo
  prefixo da chave, inserir).
- Valores em **uma linha** (sem concatenação, heredoc, nowdoc). HTML e multi-parágrafo vão
  para Mustache.
- **Nenhum comentário inline** em arquivo de lang. Único permitido:
  `// phpcs:disable moodle.Files.LineLength` logo após a linha `defined()`.
- Capitalizar só a primeira palavra e nomes próprios. String completa e autônoma — nunca
  desenhada para concatenar na UI. Sem espaço no início/fim.
- pt-BR (padrão AMOS): **"estudante" / "estudantes"**. Nunca "aluno".
- Toda capability em `db/access.php` tem string
  (`tipo/nome:cap` → `$string['nome:cap']`).

---

## 13. Testes

### PHPUnit

- `tests/` espelha `classes/`. Namespace do teste espelha o da classe testada; classe
  sufixada `_test`. `@package` = Frankenstyle puro, mesmo em subpastas.
- **Metadados: anotações PHPDoc, nunca atributos PHP**, se o plugin suporta Moodle 4.5 **e**
  5.x (o PHPUnit 9 do 4.5 ignora atributos — `#[DataProvider]` faz o teste falhar por falta
  de dados). Migrar para atributos só ao **abandonar** o suporte a 4.5.
- `@covers \Nome\Completo\Da\Classe` no **nível da classe** de teste, sem `::metodo`. Um
  teste que exercita várias classes: uma linha `@covers` por classe. Nunca
  `@coversDefaultClass` + `@covers ::metodo` (sub-mede a cobertura em silêncio). Nunca
  escrever a substring `@covers` seguida de palavra em prosa de docblock.
- `$this->resetAfterTest()` quando o teste escreve no banco.
- **Arquitetura testável:** camada de request/render fina e intestável por design; lógica
  de negócio em `classes/local/` com parâmetros explícitos — é o que se testa. Mirar
  ~90–100% dos **métodos de negócio**, não o % da classe inteira.
- Conformidade obrigatória quando aplicável: `privacy_provider_test.php`,
  `backup_restore_test.php`, teste de isolamento entre instâncias.
- Numa faixa 4.5+5.x, o aviso "Metadata in doc-comments is deprecated" é inevitável e
  **inofensivo** — não perseguir contagem zero.

### Behat

- **Uma frase de step nova sempre identifica o plugin** (`I do X in the example plugin`) —
  o namespace de steps é global no site inteiro; duas frases idênticas de plugins diferentes
  quebram **todas** as features de **todos** os plugins.
- Um `Given`, um `When`, um `Then` por cenário; o resto com `And`/`But`.
- `Given` (setup) insere dado direto (`$DB` ou gerador de entidade em `tests/generator/`),
  não clica na UI.
- Step que só dá para escrever com XPath/CSS cru = bug de acessibilidade no markup, não
  limitação do Behat — corrigir o `aria-*`/label.
- Ação de UI num step customizado passa por `\behat_session_trait::execute(...)`, nunca
  `$node->click()` direto.

---

## 14. Integrações do core

### Gradebook (`gradepass`)

`grade_update()` (`lib/gradelib.php`) **descarta em silêncio** uma chave `gradepass` passada
em `$itemdetails`. Se `mod_form.php` mostra o campo "Nota para aprovação"
(`standard_grading_coursemodule_elements()`), o `*_grade_item_update()` do plugin precisa
buscar o `grade_item` direto e setar a propriedade nele (como o `mod_workshop` do core),
pulando isso num `'reset'` e escrevendo só quando difere. Teste de regressão deve afirmar o
valor no `grade_item` buscado, nunca só o retorno `GRADE_UPDATE_OK`.

### Conclusão customizada (`FEATURE_COMPLETION_HAS_RULES`)

Declarar o `_supports()` e o checkbox no `mod_form.php` não basta. As 3 peças (nenhuma pega
por ferramenta estática):

1. `classes/completion/custom_completion.php` estendendo
   `\core_completion\activity_custom_completion` (`get_state()`,
   `get_defined_custom_rules()`, `get_custom_rule_descriptions()`, `get_sort_order()`). O
   core não chama mais a função legada `<modname>_get_completion_state()`.
2. `<modname>_get_coursemodule_info()` em `lib.php` populando
   `$info->customdata['customcompletionrules'][$rulename]` quando
   `$coursemodule->completion == COMPLETION_TRACKING_AUTOMATIC` (adicionar a um `lib.php`
   existente exige purga de cache).
3. `completion_info::update_state($cm, ..., $userid)` no momento exato em que a condição
   muda — o Moodle não tem tarefa que recalcula conclusão automática.

Validar ao vivo (criar instância, satisfazer a condição, ver o selo na página).

### `mod_*` — renderização da página

- **Nunca** imprimir o nome da atividade manualmente em `view.php` — o layout `incourse`
  (`$PAGE->activityheader`) já renderiza ícone + nome + selo.
- `$PAGE->set_pagelayout('incourse')` em todo dispositivo. Não trocar para `'embedded'`
  (remove toda a navegação) para contornar um problema de UX cuja causa está em outro lugar.
- Declarar `FEATURE_MOD_PURPOSE` no `_supports()` (senão o plugin não aparece em nenhuma
  categoria do chooser). Assinatura do `_supports()`: `: mixed`, nunca `: ?bool`.
- Constante/função mais nova que o Moodle mínimo suportado (ex.: `FEATURE_MOD_OTHERPURPOSE`,
  Moodle 5.1+): proteger com `defined()`/`function_exists()`, nunca por checagem de versão
  hardcoded. Um teste genérico `assertNull(<modname>_supports('unknown_feature'))` pega isso
  em toda a matriz de CI.

### Backup e restore (moodle2)

Aplica-se a qualquer tipo de plugin com `backup/moodle2/` para tabelas próprias.

- Toda coluna do `install.xml` espelhada no `backup_nested_element(...)` correspondente —
  nada de PHPCS/moodlecheck/PHPStan pega uma coluna faltando; ela reverte ao default no
  restore. Verificação: diff de todo `<FIELD NAME>` contra as listas de atributos.
- Toda FK para tabela própria do plugin: remap no restore via
  `$this->get_mappingid('<chave>', $oldid)`.
- Coluna sobrecarregada (significado depende de coluna irmã): remap condicional.
- Referência restaurada por sibling XML posterior no mesmo step: adiar o fixup
  (`after_execute()`).
- ID de uma **task de restore posterior** (ex.: `course_module` cru numa coluna do plugin,
  em `block_*` de curso): usar `after_restore()` do structure step, não `after_execute()`.
- **`mod_*`:** `define_structure()` retorna `$this->prepare_activity_structure($paths)`,
  nunca `$paths` direto (senão "Duplicar atividade" e backup/restore falham com
  `unknown_context_mapping`).
- Não re-rodar o restore genérico de grade item (`restore_activity_grades_structure_step`
  já é adicionado automaticamente) — chamar `<modname>_grade_item_update()` de novo no
  `after_execute()` cria dois `grade_items`.

### Availability conditions (`availability_*`)

- Cada condição-folha é responsável por honrar o parâmetro `$not` (negação) — a base
  `check_available()` **não** inverte por você. Calcular o resultado numa variável e
  inverter num único ponto de saída: `$allow = <check>; if ($not) { $allow = !$allow; }
  return $allow;`. Nunca `return` de dentro de cada branch.
- `get_description()` também renderiza a variante negada quando `$not` é true.
- Testar **os dois** estados de `$not` para cada subtipo — cobertura de linha não pega um
  `if ($not)` que nunca foi escrito.

---

## 15. Privacy API

- Todo plugin tem `classes/privacy/provider.php`. Sem dado pessoal e sem chamada externa →
  `\core_privacy\local\metadata\null_provider`. Sem dado pessoal mas com chamada a
  terceiros → `metadata\provider` só com `add_external_location_link()`. Com dado pessoal →
  `get_metadata()`, `get_contexts_for_userid()`, `export_user_data()`,
  `delete_data_for_user()`, `delete_data_for_users()`; preferências em
  `export_user_preferences()`.
- Coluna adicionada a uma tabela **já declarada** em `add_database_table()` precisa de
  decisão explícita: entra no array de campos (com string nova) ou ganha um comentário de
  uma linha explicando por que não carrega dado pessoal. Teste de regressão: afirmar que as
  chaves declaradas são iguais às colunas reais (via `$DB->get_columns()`, menos `id`).
- Retornar dados do **próprio usuário** a um cliente autenticado (app mobile) pelo token
  dele **não** é localização externa.

---

## 16. Recursos de IA (`core_ai`, Moodle 4.5+)

- **Obrigatório** (o Directory exige): se o plugin chama serviço de IA externo **ele
  mesmo**, o Privacy Provider declara cada provider com `add_external_location_link()`
  (declarando o `prompt` transmitido) e o README carrega a disclosure. A chave de API é
  **opcional** — o plugin instala e funciona sem uma, degradando graciosamente. Chave de
  site em `admin_setting_configpasswordunmask`; chave de usuário nunca exposta.
- **Consumir `core_ai` via Manager:** `\core\di::get(\core_ai\manager::class)` + uma ação
  `\core_ai\aiactions\*` + `$manager->process_action()`. Não precisa ser um Placement.
- **Respeitar o toggle por curso/módulo** (`course.enableaitools`): chamar
  `$manager->is_action_enabled_in_context($context, $actionclass)` com o contexto **real**
  de curso/módulo (nunca `context_system`) antes de `process_action()`, e usar esse mesmo
  contexto como `contextid` da ação. O método não existe no Moodle 4.5 — proteger com
  `method_exists(...)` retornando `true` quando ausente.
- **Saída de IA é input não-confiável:** validar a estrutura e passar por `format_text`
  antes de exibir/persistir. Nunca injetar resposta de IA direto em HTML ou no banco.
- Alinhar com os princípios de IA do Moodle (transparência — rotular IA, humano no loop;
  configurabilidade — admin/professor pode desligar; anti-viés — sem PII no prompt;
  proteção de dados).

---

## 17. Bibliotecas de terceiros

- Toda biblioteca empacotada declarada em `thirdpartylibs.xml` (caminho relativo à raiz do
  plugin), licença compatível com GPL v3+, com `readme_moodle.txt` (URL, build, patches).
- **Biblioteca JS/CSS → empacotada no zip, NUNCA de CDN em runtime.** O Directory exige
  pacote autocontido.
- **Serviço externo** que você integra (player de vídeo via IFrame API, API de LLM, mapas) é
  inerentemente runtime e impossível de empacotar — permitido, **não** é entrada de
  `thirdpartylibs.xml`, mas **deve** ser declarado no Privacy Provider via
  `add_external_location_link()`.

---

## 18. `settings.php`

- Nome de setting: `plugintype_pluginname/settingname` (auto-armazena em `config_plugins`).
- **Sem query ao banco em tempo de include** — o Moodle inclui `settings.php` mesmo quando
  as settings não estão sendo exibidas. Listas de opções vindas do banco: confiar no
  lazy-load de `admin_setting_configselect` (só consulta ao renderizar/salvar).
- Sem `require_once` — código compartilhado vai em classe autoloaded.

---

## 19. `db/tasks.php`, `db/events.php`

- `db/tasks.php`: usar `R` (random) para `minute`/`hour`/`day`/`dayofweek` — espalha a carga
  do cron. Um agendamento editado só é aplicado no upgrade se o admin não customizou a
  tarefa.
- `db/events.php`: **nunca** assinar evento de **outro componente** sem declarar dependência
  formal dele. Assinar os próprios eventos é ok.

---

## 20. Commits e `CHANGES.md`

- Mensagem de commit: resumo curto (~72 chars), **sem** prefixo de componente (o repo já é
  do plugin), **sem** `MDL-xxxx` falso. Linha 2 em branco, depois explicação se necessário.
  Contar uma história limpa (código como se tivesse sido escrito certo de primeira) — não
  incluir bugs achados e corrigidos antes da integração.
- **Nunca** adicionar linha de co-autoria de IA (`Co-authored-by: ...`).
- `CHANGES.md` (não `CHANGELOG.md`) na raiz, desde o início, **vazio** até o primeiro
  release. Cabeçalho: `## [vX.Y.Z] — YYYY-MM-DD`. É artefato de release — nunca editar
  durante o desenvolvimento nem por commit.
- `$plugin->version` (datecode) pode e deve subir durante o desenvolvimento sempre que uma
  mudança exige upgrade/purga. `$plugin->release` (string humana) só muda ao publicar uma
  tag.
