---
applyTo: "**/amd/**,**/templates/**,**/*.mustache,**/*.css,**/*.scss"
---

# Front-end — JavaScript (AMD), Mustache, CSS

## JavaScript (`amd/src/`)

- Nunca `<script>` em PHP/HTML. Só módulos AMD em `amd/src/`, carregados via
  `$PAGE->requires->js_call_amd()`. Recompilar `amd/build/` com `npx grunt amd` (de dentro
  da pasta do plugin) e **commitar o build**.
- `const` por padrão, `let` só se reatribui, **nunca** `var`. `===`/`!==` sempre.
  `async/await` (não cadeia de `.then()`). Arrow function para callback. Template literal
  em vez de concatenação. Destructuring ao ler múltiplas propriedades.
- APIs do core: `core/ajax` (nunca `jQuery.ajax`), `core/str`, `core/notification`,
  `core/modal` (nunca `core/modal_factory`, removido no 5.2),
  `core/copy_to_clipboard` (nunca `execCommand`).
- Preferir vanilla JS a jQuery (`document.querySelector`) — jQuery não é garantido no 5.x.
- **Dados PHP→JS** (`js_call_amd` limita ~1024 chars): scalars no 3º argumento; strings de
  UI via `$PAGE->requires->strings_for_js()`; mapas/listas do banco via atributo `data-*`
  ou `<script type="application/json">`; dados grandes via Web Service com `core/ajax`.
- Quando o PHP lança `moodle_exception` deliberado, o `.catch()` mostra via
  `Notification.alert(title, error.message)`, não `Notification.exception()`.

## Mustache (`templates/*.mustache`)

- Todo template tem `@template component/nome` no **segundo** bloco `{{! ... }}` e o rótulo
  exato `Example context (json):` (sem `@`).
- Toda `<img>` no JSON de exemplo com `alt="..."`. Nunca `<h1>`–`<h6>` vazio.
- `{{{valor}}}` só para markup **confiável e estático**. Campo armazenado (input do usuário,
  config de admin, conteúdo de IA) usa `{{valor}}` e é sanitizado na escrita. Se o campo
  aparece em mais de uma view, auditar **todas**.
- Modal: botão de fechar com `data-bs-dismiss="modal"` **e** `data-dismiss="modal"`.

## CSS / SCSS

- **Nunca** `!important`. Resolver conflito aumentando a especificidade do seletor.
- Todo seletor escopado com a classe de página do plugin:
  `.path-<tipo>-<nome> .minha-classe` ou `#page-<caminho> .minha-classe`.
- Sem `style="..."` estático (dinâmico por render, ex. largura de barra, é aceitável).
- Cores via `var(--nome, #fallback)` — nunca hex fixo solto. RTL: `margin-inline-start`,
  `text-align: start`.
- **`.visually-hidden` definido pelo próprio plugin**, escopado à sua classe de página —
  nunca `.sr-only`, nunca depender da utilitária do Bootstrap. Nunca `.visually-hidden`
  dentro de `.table-responsive .table` nem sozinha em `.activity-item`.
- Bootstrap 4 (Moodle 4.5) vs 5 (5.x): não usar classe só-BS5 que quebre no 4.5
  (`gap-*`, `visually-hidden` puro, `text-bg-*`). Badge: seletor duplo `.badge.sua-classe`.
