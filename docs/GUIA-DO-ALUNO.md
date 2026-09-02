# Guia do aluno — Moodle Plugin Lab

Ambiente pronto para desenvolver plugins Moodle com apoio de IA (GitHub Copilot).
Você não instala nada: o Codespace já sobe com o Moodle 5.2 rodando.

---

## 0. O que você precisa antes

- Uma **conta no GitHub** (a sua — não a do professor).
- **GitHub Copilot** ativo nessa conta. Se você é estudante, ative o **GitHub Student
  Developer Pack** (github.com/education) — ele dá o **Copilot Pro de graça**.
- Nada para instalar no seu computador. Tudo roda no navegador.

Você **não** faz fork nem cópia deste repositório. Ele é a bancada compartilhada: você abre
um Codespace a partir dele (a máquina nasce **na sua conta**, com o **seu** Copilot) e o
código que você desenvolve vai para **repositórios seus** (passo 5).

## 1. Abrir o ambiente

1. Acesse o repositório do laboratório e clique em **Code → Codespaces →
   Create codespace on main**.
2. Espere o VS Code abrir no navegador (a primeira vez leva ~1 min; depois, segundos).
3. No primeiro terminal, confirme **seu nome completo** quando for perguntado — ele vai
   nos cabeçalhos de licença dos arquivos que você criar.
4. A aba do **Moodle** abre sozinha na porta 8000. Se não abrir, clique na aba **Ports**
   e no ícone de globo da porta 8000.

> O Codespace **para sozinho** após 30 min sem uso (não gasta cota parado). Para retomar:
> github.com/codespaces → clique no seu. Não crie um novo toda vez.

**Login do site:** usuário `admin`, senha `Sandbox123!`

---

## 2. Primeiro trabalho: o SCOPE

Antes de escrever qualquer código, todo plugin começa pelo **planejamento**. Crie o
esqueleto do seu plugin:

```
plugin-new local meuplugino
```

(`local` é o tipo; `meuplugino` é o nome curto, minúsculo, só letras.)

Isso cria a pasta `moodle/public/local/meuplugino/` já com um repositório git próprio e o
arquivo **`SCOPE.md`** copiado de `docs/TEMPLATE_SCOPE.md`. **Preencher esse `SCOPE.md` é o
primeiro trabalho.** Use o Copilot Chat para ajudar a pensar cada seção — ele já conhece as
regras do laboratório.

---

## 3. Desenvolver

- Escreva o código dentro da pasta do seu plugin.
- O **Copilot Chat** segue automaticamente as regras em `.github/copilot-instructions.md`.
  Selecione o modelo **Claude Sonnet** no seletor do Copilot se quiser.
- Sempre que o Moodle "não ver" uma mudança (novo arquivo de função, `db/`, `version.php`):

  ```
  plugin-upgrade
  ```

- Compilar JavaScript AMD (depois de editar `amd/src/*.js`), de dentro da pasta do plugin:

  ```
  npx grunt amd
  plugin-upgrade
  ```

---

## 4. Verificar antes de entregar

| O quê | Comando |
|---|---|
| Estilo (PHPCS) | roda **sozinho** no `git commit` (hook de pre-commit) |
| PHPDoc (o mesmo do CI) | `moodle-check local/meuplugino/version.php` |
| Tipos / API inexistente | `moodle-phpstan local/meuplugino` |
| Testes | `moodle-phpunit local/meuplugino` |
| Cobertura de testes | `moodle-coverage local/meuplugino` |
| Arquivos previstos no SCOPE §6 | `moodle-scope-audit local/meuplugino` |

Se o `git commit` for bloqueado pelo hook, **corrija o que ele apontou** — não tente
burlar. `phpcbf local/meuplugino/arquivo.php` conserta boa parte do estilo sozinho.

---

## 5. Versionar o seu plugin

A pasta do plugin é um repositório git **separado** do laboratório. Publique no seu próprio
GitHub:

```
cd moodle/public/local/meuplugino
gh repo create meuplugino --private --source=. --push
```

> O código do Moodle e os dados do site (`moodle/`, `moodledata/`) **não** são versionados
> aqui — só o seu plugin. Se você recriar o Codespace, só volta o que você tiver enviado
> para o seu repositório.

---

## 6. Problemas comuns

| Sintoma | O que fazer |
|---|---|
| **HTTP 401** ao abrir o Moodle | Abra pela aba **Portas → porta 8000 → globo**, não por URL salva. Se persistir, a porta já está configurada como pública — recarregue. |
| **"Could not register service worker" / erro de webview** | Afeta só webviews (preview de Markdown etc.) — terminal, edição, Copilot Chat e o Moodle funcionam. **Se o navegador mostrar um aviso pedindo permissão, clique em permitir.** Se não pedir e o erro persistir: é bloqueio de cookies de terceiros ou extensão de privacidade — libere `[*.]github.dev`, `[*.]vscode-cdn.net` e `[*.]visualstudio.com`, teste em janela anônima, ou use **`Ctrl+Shift+P` → "Open in VS Code Desktop"** (não tem esse problema). O Edge costuma pedir a permissão e resolver na hora; alguns Chrome com extensões, não. |
| Site fora do ar depois de reabrir o Codespace | `bash .devcontainer/start.sh` |
| Moodle não vê um plugin/mudança nova | `plugin-upgrade` |
| Commit bloqueado pelo hook | Corrija o que o PHPCS apontou (`phpcbf <arquivo>` conserta boa parte). Não burle. |
| Copilot não segue as regras | Troque o modelo para **Claude Sonnet** ou **GPT-4.1** no seletor do Copilot Chat. |

## 7. Referência

- `docs/REGRAS-DE-CODIGO.md` — regras de código completas e comentadas.
- `docs/AMBIENTE.md` — como o ambiente funciona por dentro (banco, servidor, caches).
- `docs/TEMPLATE_SCOPE.md` — o modelo de planejamento.
