# Exercício 1 — o bloco "Saudação" (`block_greeting`)

Objetivo: **sentir o fluxo completo** de desenvolvimento de um plugin Moodle — criar
arquivos, commitar, passar nas verificações, ver funcionando no Moodle, publicar, CI verde.
Não é sobre o código (é minúsculo) — é sobre o ciclo.

Trabalhe na **janela padrão do Codespace** (raiz `moodle-plugin-lab`). Leva ~15 minutos.

---

## 1. Criar o esqueleto

No terminal:

```
plugin-new block greeting
cp docs/exemplo/SCOPE-greeting.md moodle/public/blocks/greeting/SCOPE.md
```

Isso cria `moodle/public/blocks/greeting/` com `version.php`, `lang/`, `db/upgrade.php`,
`.github/`, e agora o `SCOPE.md` do exercício.

Abra a pasta no explorador e **leia o `SCOPE.md`** — ele descreve exatamente o que construir.

> **O que são esses comandos?**
>
> - `plugin-new block greeting` é o comando **de sempre**: você vai usá-lo de novo no seu
>   plugin principal (`plugin-new <tipo> <nome>`, ex.: `plugin-new local meuplugino`). Ele
>   sempre cria o esqueleto e já deixa um `SCOPE.md` **em branco** (o modelo de
>   `docs/TEMPLATE_SCOPE.md`) para você preencher.
> - O `cp ... SCOPE-greeting.md ...` é **só deste aquecimento**. Ele troca o `SCOPE.md` em
>   branco por um **já preenchido**, para você pular o planejamento agora e focar no ciclo
>   (código → verificação → CI). No seu plugin de verdade você **não** roda esse `cp`: abre o
>   `SCOPE.md` em branco e preenche você mesmo, com a ajuda do Copilot.
>
> **Atenção:** ao terminar, o `plugin-new` imprime "Próximos passos: abra o `SCOPE.md` e
> preencha o planejamento". **Neste exercício ignore os passos 1 e 2 dessa mensagem** — o
> `cp` já deixou o `SCOPE.md` preenchido. Vá direto para a seção 2 (Construir).

> **Dica: acompanhe os arquivos sendo criados.** No Explorer (barra lateral), expanda
> `moodle` → `public` → `blocks` → `greeting`: cada arquivo que o Copilot criar aparece ali.
> Se preferir ver só o plugin, use o menu **Arquivo → Adicionar Pasta ao Workspace…** e
> escolha `/workspaces/moodle-plugin-lab/moodle/public/blocks/greeting` (a janela recarrega
> uma vez; a raiz continua aberta ao lado, então o Copilot segue enxergando toda a
> documentação do laboratório). Não abra o plugin como uma janela separada — o Copilot
> perderia acesso às regras e ao `docs/`.

---

## 2. Construir, com o Copilot

Abra o **Copilot Chat** (modelo Claude Sonnet ou GPT-4.1). Peça, **um de cada vez**, os 10
comandos abaixo. **Antes de colar cada um, leia a explicação embaixo dele**: o comando é curto,
mas a IA vai fazer mais do que ele diz, e você precisa saber o quê para conferir o resultado.
O Copilot já conhece as regras do laboratório (`.github/`) — mesmo assim, você é o revisor:
se o que ele gerou não bate com a explicação, peça para corrigir.

### 2.1 `version.php` — a identidade do plugin

> *"Ajuste o `version.php` do block_greeting: `requires` para Moodle 5.2 (2026042000), `release` 1.0.0 e some 1 ao número de `version`. Mantenha a maturity ALPHA como está."*

**O que a IA vai fazer:** o `version.php` é o arquivo que apresenta o plugin ao Moodle. Ele tem
o `component` (`block_greeting`, o nome técnico), o `version` (um número no formato de data — o
Moodle compara esse número para saber se precisa rodar um *upgrade*), o `requires` (a versão
mínima do Moodle; em versões mais antigas o plugin se recusa a instalar), a `maturity` (rótulo
de estabilidade, já vem `ALPHA`) e o `release` (a versão "para humanos"). A IA altera três
valores: `requires`, `release` e o `version` (soma 1). **Esse último é o que importa:** o
`plugin-new` já instalou o esqueleto do bloco no Moodle; o Moodle só *atualiza* um plugin —
lendo o `db/access.php` novo, por exemplo — quando o número `version` **sobe**. Sem isso o
`plugin-upgrade` diz "nenhuma atualização necessária" e as permissões do bloco nunca são
registradas.

### 2.2 `lang/` — todo texto visível fica em arquivos de idioma

> *"Crie `lang/en/block_greeting.php` e `lang/pt_br/block_greeting.php` com as strings da seção 9 do SCOPE.md, em ordem alfabética."*

**O que a IA vai fazer:** no Moodle **nenhum texto é escrito direto no código**: cada frase
visível é uma *string* de idioma (`$string['chave'] = 'texto';`), guardada em um arquivo por
idioma — inglês (`en`) e português (`pt_br`). São 6 chaves: `greeting` (a frase do bloco),
`greeting:addinstance` e `greeting:myaddinstance` (nomes das permissões, que aparecem na tela de
papéis), `jsloaded` (a mensagem do JavaScript), `pluginname` (o nome do bloco) e
`privacy:metadata` (o texto da privacidade). As chaves precisam estar em **ordem alfabética
estrita** e os dois arquivos **em sincronia** — o hook confere.

### 2.3 `db/access.php` — as permissões do bloco

> *"Crie `db/access.php` com as capabilities `block/greeting:addinstance` e `block/greeting:myaddinstance`."*

**O que a IA vai fazer:** *capability* é uma permissão do Moodle. Todo bloco precisa de duas:
`addinstance` (permite adicionar o bloco a uma página de curso) e `myaddinstance` (permite
adicionar ao Painel do usuário). Sem elas, o Moodle **não mostra o bloco** no menu "Adicionar um
bloco". O arquivo também diz quais papéis (professor, gestor, usuário comum) recebem cada
permissão por padrão. Os nomes precisam ter uma string correspondente no passo 2.2 — o hook
(`capability-strings`) confere.

### 2.4 `classes/local/greeting_text.php` — sua primeira classe

> *"Crie `classes/local/greeting_text.php` conforme a seção 4 do SCOPE.md."*

**O que a IA vai fazer:** cria uma classe pequena com **um método estático**,
`get_message(): string`, que devolve `get_string('greeting', 'block_greeting')`. O importante
é onde e como ela é escrita: a pasta `classes/` é **carregada automaticamente** pelo Moodle
(*autoload*), desde que o *namespace* bata com o caminho — `classes/local/greeting_text.php`
→ `namespace block_greeting\local;`. Por isso não existe `require` em lugar nenhum. Ela separa
"de onde vem a frase" de "como o bloco se comporta"; no seu plugin de verdade, é nessas classes
que a lógica vai crescer.

### 2.5 `block_greeting.php` — a classe principal do bloco

> *"Crie `block_greeting.php` conforme a seção 4 do SCOPE.md — chamando `greeting_text::get_message()` e registrando o módulo AMD."*

**O que a IA vai fazer:** esse é o "controlador" do bloco, e fica na **raiz** do plugin porque o
Moodle exige esse nome e lugar. Dois métodos: `init()` define o título do bloco, e
`get_content()` monta o conteúdo — pega a frase da classe do passo 2.4, renderiza o template
Mustache (passo 2.6) e registra o módulo JavaScript (passo 2.8) com `js_call_amd`. Ele decide
**o que** mostrar; não contém HTML nem texto. ⚠️ **Confira:** só o `get_content()` leva
`#[\Override]`. Se a IA colocar isso no `init()`, o PHP dá erro fatal (o `block_base` não tem
um `init()` para sobrescrever).

### 2.6 `templates/content.mustache` — o HTML, separado do PHP

> *"Crie `templates/content.mustache` conforme a seção 8."*

**O que a IA vai fazer:** o HTML do bloco **não** fica dentro do PHP: fica num *template*
Mustache. O arquivo tem **dois** comentários de cabeçalho no topo: o primeiro só com a
licença GPL, e o segundo com o `@template block_greeting/content` e um contexto de exemplo em
JSON (o verificador exige) e uma linha de HTML,
`<p class="block_greeting-message">{{greeting}}</p>`. O `{{greeting}}` é um espaço reservado que
o PHP preenche; as **chaves duplas** escapam o conteúdo, o que protege contra HTML malicioso.

### 2.7 `styles.css` — a aparência

> *"Crie `styles.css` com a regra escopada da seção 8."*

**O que a IA vai fazer:** cria o CSS do bloco, com um cabeçalho duplo (licença + descrição) e
**uma** regra, cujo seletor começa com `.block_greeting` — isso é o *escopo*: garante que o
estilo só vale dentro deste bloco e não vaza para o resto do Moodle. A cor usa a variável do
tema (`var(--primary, ...)`) em vez de um valor fixo, e não usa `!important`. Você não precisa
"ligar" o CSS em lugar nenhum: o Moodle carrega o `styles.css` de todo plugin sozinho.

### 2.8 `amd/src/greeting.js` — o JavaScript

> *"Crie `amd/src/greeting.js` conforme a seção 8 do SCOPE.md."*

**O que a IA vai fazer:** cria um módulo JavaScript no padrão do Moodle (*AMD*). O arquivo
começa com o **cabeçalho de licença** (comentários `//`) e um bloco de documentação com
`@module block_greeting/greeting` — confira que ele existe, é a omissão mais comum. Ele exporta uma
função `init`, que o PHP chama pelo `js_call_amd` do passo 2.5. Dentro dela, busca a string
`jsloaded` com `core/str` (de novo: nenhum texto fixo no código) e mostra com
`core/notification`. **Atenção:** esse é o arquivo *fonte*. O Moodle serve a versão compilada,
em `amd/build/` — que só existe depois do `npx grunt amd` do passo 3. Escrever o `.js` e não
compilar é o erro mais comum aqui.

### 2.9 `classes/privacy/provider.php` — privacidade

> *"Crie `classes/privacy/provider.php` com o `null_provider`."*

**O que a IA vai fazer:** todo plugin do Moodle precisa declarar **quais dados pessoais
guarda** (é uma exigência de proteção de dados, tipo LGPD). Este bloco não guarda nenhum, então
a declaração é a mais simples possível: uma classe que implementa `null_provider` e tem um único
método, `get_reason()`, que devolve a string `privacy:metadata` (criada no passo 2.2). Sem esse
arquivo, o plugin falha nas verificações de privacidade do Moodle.

### 2.10 `tests/greeting_test.php` — o teste automatizado

> *"Crie `tests/greeting_test.php` conforme a seção 14."*

**O que a IA vai fazer:** cria um teste PHPUnit que adiciona o bloco, chama `get_content()` e
verifica se o texto da string `greeting` aparece no resultado. Ele testa o **resultado
visível**, não o jeito como o código foi escrito. O cabeçalho da classe de teste tem duas
linhas `@covers` (o bloco e a classe do passo 2.4), que dizem ao PHPUnit quais classes o teste
cobre. Você roda com `moodle-phpunit` (passo 3) e o CI roda de novo depois, no GitHub.

Confira cada arquivo antes de aceitar — você é o revisor.

---

## 3. Verificar

```
cd moodle/public/blocks/greeting
npx grunt amd
```

Isso compila `amd/src/greeting.js` em `amd/build/greeting.min.js` — o Moodle serve o build,
nunca a fonte. **Nunca edite `amd/build` à mão**; rode `npx grunt amd` de novo sempre que
mexer no `.js`.

### Veja o hook bloquear (de propósito)

Antes do commit de verdade, quebre alguma coisa: apague um `;` no fim de uma linha do
`greeting.js`, ou troque aspas simples por duplas em qualquer lugar do PHP. Depois:

```
git add -A && git commit -m "teste"
```

O hook deve **recusar** o commit e apontar o erro — PHPCS se foi no PHP, ESLint se foi no JS.
Desfaça a quebra (`phpcbf <arquivo>` resolve boa parte do lado PHP sozinho) antes de seguir.
É assim que o hook te protege de verdade nos seus próprios plugins, não só um exemplo.

### Commit de verdade

```
moodle-check version.php block_greeting.php db/access.php classes/local/greeting_text.php classes/privacy/provider.php
git add -A && git commit -m "block_greeting: hello world"
```

No `git commit`, o hook roda: `php -l` → PHPCS → get_string → capability-strings → ESLint →
Mustache → ... **Se bloquear, corrija o que ele apontou.** Não use `--no-verify`.

```
moodle-phpunit blocks/greeting
```

---

## 4. Ver funcionando no Moodle

```
plugin-upgrade
```

No navegador (porta 8000, `admin` / `Sandbox123!`):

1. O Moodle deve oferecer instalar o `block_greeting` (ou vá em *Administração do site →
   Notificações*).
2. Vá ao **Painel** → botão **Personalizar esta página** → **Adicionar um bloco** →
   **Saudação**.
3. A sua frase aparece no bloco, e uma notificação some no topo da página — essa parte vem
   do `amd/src/greeting.js`. 🎉

**Se o `plugin-upgrade` disser "Nenhuma atualização necessária"**, o `version` do
`version.php` não subiu (passo 2.1): some 1 ao número (ex.: `2026092900` → `2026092901`) e
rode `plugin-upgrade` de novo. Vale para o seu plugin de verdade também: sempre que mexer em
`db/` (permissões, tabelas), suba o `version`.

Se a notificação não aparecer depois de editar o `.js`, você provavelmente esqueceu o
`npx grunt amd` (passo 3) ou o cache do navegador está com o build antigo — rode
`plugin-upgrade` de novo (ele já purga os caches) e recarregue a página.

### 4.1 Mudou alguma coisa? O que fazer para o Moodle enxergar

O Moodle guarda em **cache** os textos de idioma, os templates e o CSS. Por isso, depois de
editar um arquivo, a página pode continuar mostrando a versão antiga. O que fazer depende do
que você mudou:

| O que você mudou | O que fazer |
|---|---|
| Uma frase (`lang/en/...` e `lang/pt_br/...`) | `plugin-upgrade` (ou só limpar os caches) e recarregar |
| `templates/*.mustache` ou `styles.css` | `plugin-upgrade` (ou só limpar os caches) e recarregar |
| `amd/src/*.js` | `npx grunt amd`, depois `plugin-upgrade` e recarregar |
| Lógica em `block_greeting.php` ou `classes/` | só recarregar a página (não usa cache) |
| `db/access.php` (permissões) ou qualquer coisa em `db/` | **suba o `version`** no `version.php` (some 1) e rode `plugin-upgrade` |

**Exemplo — trocar o texto da saudação:**

1. Edite a string `greeting` **nos dois arquivos**, `lang/en/block_greeting.php` e
   `lang/pt_br/block_greeting.php` (as duas línguas sempre em sincronia).
2. Rode `plugin-upgrade` (ele faz o upgrade **e** limpa os caches). Não precisa subir o
   `version` nesse caso — só mudou texto.
3. Recarregue a página do Moodle com `Ctrl+Shift+R`, para o navegador também largar a versão
   antiga.

**Só limpar os caches** (sem upgrade), de duas formas:

- No terminal: `php /workspaces/moodle-plugin-lab/moodle/admin/cli/purge_caches.php`
- No navegador: *Administração do site → Desenvolvimento → Limpar todos os caches*, e clique
  em **Limpar todos os caches**.

Se ainda aparecer a versão antiga depois de limpar, é o cache do **navegador**: recarregue com
`Ctrl+Shift+R`.

---

## 5. Publicar e ver o CI

```
plugin-publish
```

(Primeira vez: ele pede `gh auth login` no navegador — uma vez só.)

> **O `plugin-publish` serve para qualquer plugin**, não só para este: você vai usá-lo de novo
> no seu plugin principal.
>
> - **Como usar:** rode dentro da pasta do plugin, ou passe o caminho
>   (`plugin-publish blocks/greeting`). Ele lê o nome do componente no `version.php` e cria o
>   repositório `moodle-<componente>` **público** na sua conta (ex.: `moodle-block_greeting`,
>   `moodle-local_meuplugino`), com o primeiro push.
> - **Opções:** `--repo NOME` escolhe outro nome para o repositório; `--private` cria privado;
>   `--team login1,login2` adiciona colegas de grupo como colaboradores.
> - **Só uma vez por plugin, e só com tudo commitado.** Se o plugin já tem um repositório
>   remoto, ele recusa; se há alterações sem `git commit`, também recusa. Depois da primeira
>   vez, o envio de novas mudanças é o `git push` de sempre.

Abra `https://github.com/<sua-conta>/moodle-block_greeting` → aba **Actions** → o workflow
**Moodle Plugin CI** deve rodar e ficar **verde** (phplint, phpcs, phpdoc, phpunit, ...).

Se ficar vermelho, leia o log do passo que falhou, corrija, `git commit` + `git push`, e o
CI roda de novo.

---

## Terminou? Nível 2 (opcional)

Torne a frase **configurável por instância** (seção 3.2 do SCOPE): `edit_form.php` com um
campo de texto, `get_content()` lê `$this->config->text` e passa por `format_string()`.
Peça ao Copilot e siga o mesmo ciclo.
