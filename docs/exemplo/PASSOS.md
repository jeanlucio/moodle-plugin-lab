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

---

## 2. Construir, com o Copilot

Abra o **Copilot Chat** (modelo Claude Sonnet ou GPT-4.1). Peça, um de cada vez:

1. *"Ajuste o `version.php` do block_greeting: `requires` para Moodle 5.2, `release` 1.0.0, maturity ALPHA."*
2. *"Crie `lang/en/block_greeting.php` e `lang/pt_br/block_greeting.php` com as strings da seção 9 do SCOPE.md, em ordem alfabética."*
3. *"Crie `db/access.php` com as capabilities `block/greeting:addinstance` e `block/greeting:myaddinstance`."*
4. *"Crie `classes/local/greeting_text.php` conforme a seção 4 do SCOPE.md."*
5. *"Crie `block_greeting.php` conforme a seção 4 do SCOPE.md — chamando `greeting_text::get_message()` e registrando o módulo AMD."*
6. *"Crie `templates/content.mustache` conforme a seção 8."*
7. *"Crie `styles.css` com a regra escopada da seção 8."*
8. *"Crie `amd/src/greeting.js` conforme a seção 8 do SCOPE.md."*
9. *"Crie `classes/privacy/provider.php` com o `null_provider`."*
10. *"Crie `tests/greeting_test.php` conforme a seção 14."*

O Copilot já conhece as regras do laboratório (`.github/`). Confira cada arquivo antes de
aceitar — você é o revisor.

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

Se a notificação não aparecer depois de editar o `.js`, você provavelmente esqueceu o
`npx grunt amd` (passo 3) ou o cache do navegador está com o build antigo — rode
`plugin-upgrade` de novo (ele já purga os caches) e recarregue a página.

---

## 5. Publicar e ver o CI

```
plugin-publish
```

(Primeira vez: ele pede `gh auth login` no navegador — uma vez só.)

Abra `https://github.com/<sua-conta>/moodle-block_greeting` → aba **Actions** → o workflow
**Moodle Plugin CI** deve rodar e ficar **verde** (phplint, phpcs, phpdoc, phpunit, ...).

Se ficar vermelho, leia o log do passo que falhou, corrija, `git commit` + `git push`, e o
CI roda de novo.

---

## Terminou? Nível 2 (opcional)

Torne a frase **configurável por instância** (seção 3.2 do SCOPE): `edit_form.php` com um
campo de texto, `get_content()` lê `$this->config->text` e passa por `format_string()`.
Peça ao Copilot e siga o mesmo ciclo.
