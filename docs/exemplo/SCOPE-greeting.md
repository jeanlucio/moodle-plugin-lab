# Escopo do Projeto — Saudação (`block_greeting`)

> **Exercício do laboratório.** SCOPE pré-preenchido: seu trabalho é **construir** este
> plugin seguindo o documento, com a ajuda do Copilot. Copie este arquivo para a raiz do seu
> plugin como `SCOPE.md`.

- **Versão do documento:** 1.0
- **Autor:** [Seu nome]
- **Tipo de plugin:** `block_`
- **Compatibilidade alvo:** Moodle 5.x
- **PHP mínimo:** 8.3
- **Licença:** GPL v3+

> Bloco que exibe uma frase de saudação. Serve para exercitar o fluxo completo de
> desenvolvimento (criar arquivos, commitar, verificações, CI, ver funcionando no Moodle).

---

## 1. Contextualização e Objetivos

- **Problema:** exercício — praticar o ciclo de criação de um plugin Moodle.
- **Solução:** um bloco mínimo que renderiza uma saudação num template Mustache.
- **Público-alvo:** o próprio estudante.
- **Distribuição:** não será publicado (é exercício). Para um plugin real, o Frankenstyle
  precisaria ser verificado livre no Plugins Directory.

---

## 2. Análise de Alternativas

N/A — exercício.

---

## 3. Escopo, Versionamento e Limites

### 3.1. V1

- Bloco que mostra uma frase fixa, vinda de uma string de idioma, num template Mustache.
- Adicionável ao Dashboard e a páginas de curso.

### 3.2. Nível 2 (opcional, depois de terminar a V1)

- Tornar a frase **configurável** por instância: `edit_form.php` com um campo de texto,
  `get_content()` lê `$this->config->text` e passa por `format_string()`.

### 3.3. Fora de escopo

- Configuração global de admin. Múltiplas frases. Qualquer persistência em banco.

---

## 4. Requisitos Funcionais

- `init()` define o título do bloco com `get_string('pluginname', 'block_greeting')`.
- `get_content()`:
  - retorna cedo se `$this->content` já existe;
  - monta `$this->content->text` com
    `$OUTPUT->render_from_template('block_greeting/content', ['greeting' => get_string('greeting', 'block_greeting')])`;
  - `$this->content->footer = ''`.
- `applicable_formats()` retorna `['all' => true]`.
- Métodos que sobrescrevem `block_base` sem mudar semântica usam `#[\Override]`.

---

## 5. Arquitetura de Dados

Sem tabelas próprias. Sem cache. Sem configuração persistida (na V1). Não há `db/install.xml`.

---

## 6. Estrutura de Diretórios e Arquivos

```
blocks/greeting/
├── .github/workflows/ci.yml           ✅ (vem do plugin-new)
├── .github/copilot-instructions.md    ✅ (vem do plugin-new)
├── .github/instructions/              ✅ (vem do plugin-new)
├── block_greeting.php                 ❌ classe do bloco
├── db/
│   ├── access.php                     ❌ capabilities
│   └── upgrade.php                    ✅ (vem do plugin-new, no-op)
├── lang/
│   ├── en/block_greeting.php          ❌
│   └── pt_br/block_greeting.php       ❌
├── templates/content.mustache         ❌
├── tests/greeting_test.php            ❌
├── styles.css                         ❌
├── version.php                        ✅ (vem do plugin-new — ajustar release/requires)
├── .gitattributes / .gitignore / README.md   ✅ (vem do plugin-new)
└── SCOPE.md                           ✅ (este documento)
```

---

## 7. Web Services

Nenhum.

---

## 8. Interface, Templates e Acessibilidade

- **`templates/content.mustache`:**
  ```
  {{!
      @template block_greeting/content

      Example context (json):
      {
          "greeting": "Hello!"
      }
  }}
  <p class="block_greeting-message">{{greeting}}</p>
  ```
  Chave dupla `{{greeting}}` (a string é conteúdo renderizado, não markup confiável).
- **`styles.css`:** cabeçalho duplo (GPL + JSDoc). Uma regra, escopada pela classe do bloco:
  ```css
  .block_greeting .block_greeting-message {
      font-weight: 600;
      color: var(--primary, #0f6cbf);
  }
  ```
- Sem ícone decorativo, sem imagem, sem input — nada de a11y extra nesta V1.

---

## 9. Internacionalização — strings

Chaves em **ordem alfabética estrita**. `lang/en` e `lang/pt_br` em sincronia.

| Chave | EN | PT-BR |
|---|---|---|
| `greeting` | "Hello! Welcome to Moodle plugin development." | "Olá! Bem-vindo ao desenvolvimento de plugins Moodle." |
| `greeting:addinstance` | "Add a new greeting block" | "Adicionar um novo bloco de saudação" |
| `greeting:myaddinstance` | "Add a new greeting block to the Dashboard" | "Adicionar um novo bloco de saudação ao Painel" |
| `pluginname` | "Greeting" | "Saudação" |

---

## 10. Bibliotecas de Terceiros

Nenhuma.

---

## 11. Dependências e Integrações

- APIs do core: Output (`render_from_template`), String Manager (`get_string`).
- Sem dependência de outros plugins.

---

## 12. Privacidade

Não armazena nenhum dado pessoal e não faz chamada externa →
`classes/privacy/provider.php` implementa `\core_privacy\local\metadata\null_provider`
(retorna a string `privacy:metadata`).

> Adicione a chave `privacy:metadata` nas duas línguas (na posição alfabética: entre
> `pluginname` e o resto, se houver).

---

## 13. Checklist de Segurança

- [ ] Sem `echo` de variável — o template renderiza via `{{greeting}}`.
- [ ] `db/access.php`: as duas capabilities têm string de lang.
- [ ] Nenhuma linha de PHP > 132 caracteres.
- [ ] pt-BR e en em sincronia, chaves em ordem alfabética, sem comentário inline em lang.
- [ ] Privacy Provider (`null_provider`).

---

## 14. Plano de Testes

- **PHPUnit** — `tests/greeting_test.php`, namespace `block_greeting`, classe
  `greeting_test` (`final`, estende `\advanced_testcase`), docblock com
  `@covers \block_greeting`.
  - Teste: a string `greeting` (via `get_string`) aparece no HTML que o template produz.
    Renderize o template diretamente com `$PAGE->get_renderer('core')->render_from_template(...)`
    ou compare `get_string('greeting', 'block_greeting')` com o resultado — o Copilot ajuda
    a achar a forma mais limpa.
- **Behat** — não obrigatório neste exercício.

---

## 15. Critérios de Aceite

| ID | Critério |
|---|---|
| CA01 | O plugin instala pelo painel do Moodle sem erro. |
| CA02 | O bloco pode ser adicionado ao Dashboard e mostra a frase da string `greeting`. |
| CA03 | Nenhuma string visível está hardcoded — tudo via `get_string()`. |
| CA04 | `git commit` passa nos gates (`php -l`, PHPCS, get_string, capability-strings...). |
| CA05 | `moodle-check` roda sem `<error>` nos arquivos PHP. |
| CA06 | `moodle-phpunit blocks/greeting` passa. |
| CA07 | O CI (GitHub Actions) fica verde depois do `plugin-publish`. |

---

## 16. Roteiro de Implementação

Ver `docs/exemplo/PASSOS.md`. Ordem sugerida: `version.php` → `lang/` → `db/access.php` →
`block_greeting.php` → `templates/content.mustache` → `styles.css` →
`classes/privacy/provider.php` → `tests/greeting_test.php`.

---

## 17. Trade-offs

Frase fixa em vez de configurável na V1 — reduz a superfície (sem `edit_form.php`, sem
`format_string` de config) para focar no fluxo. A versão configurável fica como Nível 2.

---

## 18. Histórico do Documento

| Data | Versão | Alteração |
|---|---|---|
| [hoje] | 1.0 | Escopo do exercício. |
