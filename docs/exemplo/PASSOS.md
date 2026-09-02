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

---

## 2. Construir, com o Copilot

Abra o **Copilot Chat** (modelo Claude Sonnet ou GPT-4.1). Peça, um de cada vez:

1. *"Ajuste o `version.php` do block_greeting: `requires` para Moodle 5.2, `release` 1.0.0, maturity ALPHA."*
2. *"Crie `lang/en/block_greeting.php` e `lang/pt_br/block_greeting.php` com as strings da seção 9 do SCOPE.md, em ordem alfabética."*
3. *"Crie `db/access.php` com as capabilities `block/greeting:addinstance` e `block/greeting:myaddinstance`."*
4. *"Crie `block_greeting.php` conforme a seção 4 do SCOPE.md."*
5. *"Crie `templates/content.mustache` conforme a seção 8."*
6. *"Crie `styles.css` com a regra escopada da seção 8."*
7. *"Crie `classes/privacy/provider.php` com o `null_provider`."*
8. *"Crie `tests/greeting_test.php` conforme a seção 14."*

O Copilot já conhece as regras do laboratório (`.github/`). Confira cada arquivo antes de
aceitar — você é o revisor.

---

## 3. Verificar

```
cd moodle/public/blocks/greeting

moodle-check version.php block_greeting.php db/access.php classes/privacy/provider.php
git add -A && git commit -m "block_greeting: hello world"
```

No `git commit`, o hook roda: `php -l` → PHPCS → get_string → capability-strings → ...
**Se bloquear, corrija o que ele apontou** (`phpcbf <arquivo>` conserta boa parte do estilo).
Não use `--no-verify`.

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
3. A sua frase aparece no bloco. 🎉

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
