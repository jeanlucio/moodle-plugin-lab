# Escopo do Projeto — [Nome de exibição do Plugin] (`[type_name]`)

> Copie este arquivo para `SCOPE.md` na raiz do seu plugin e preencha. É um documento
> **interno** de planejamento (em pt-BR) — não confundir com o `README.md` público.
> Liste `SCOPE.md` no `.gitignore` do plugin (o `plugin-new` já faz isso).

> [!NOTE]
> **Frankenstyle** (`type_name`): curto, em **inglês**, minúsculo, de preferência um único
> token, **verificado livre no Moodle Plugins Directory** antes de fixar (página 404 +
> `download.moodle.org/api/1.3/pluginfo.php?plugin=type_name` retorna "não encontrado").
> Renomear depois é caro (cascateia em tabelas, capabilities, chaves de lang, caminhos).
> O **Nome de exibição** (string `pluginname`) é separado e **localizável** — pode ser em
> português.

- **Versão do documento:** 1.0
- **Data:** [DD/MM/AAAA]
- **Autor:** [Seu nome]
- **Tipo de plugin:** [`block_` / `mod_` / `local_` / `filter_` / `report_` / ...]
- **Compatibilidade alvo:** Moodle [5.x / 4.5+]
- **PHP mínimo:** [8.2 / 8.3]
- **Licença:** GPL v3+

> [Uma frase concisa: o que o plugin faz, para quem, em que versões do Moodle.]

---

## 1. Contextualização e Objetivos

- **Problema:** [Qual lacuna no Moodle o plugin resolve?]
- **Solução:** [Como resolve? Fluxo de alto nível.]
- **Público-alvo:** [Professores, estudantes, gestores, TI...]
- **Justificativa:** [Ganho pedagógico, de gestão ou técnico. Quando o benefício é limitado?]
- **Distribuição:** [GPL v3+, Moodle Plugins Directory, uso interno...]

---

## 2. Análise de Alternativas (Estado da Arte)

> Preencher **antes** de detalhar o escopo. Se algo já resolve bem o problema, a decisão
> certa pode ser usar/estender, não construir do zero. Fontes: Plugins Directory,
> funcionalidades do core, plugins já instalados, processo manual atual.

| Solução existente | Tipo | O que faz | Limitação / lacuna |
|---|---|---|---|
| [nome] | Directory / core / manual / pago | [...] | [por que não basta] |

- **Diferencial do plugin:** [1–3 pontos que nenhuma alternativa entrega.]
- **Veredito (build vs. reuse):** [construir / estender X / contribuir no core]. [1 frase.]

---

## 3. Escopo, Versionamento e Limites

### 3.1. Escopo da V1 (MVP publicável)

[Conjunto mínimo de funcionalidades do primeiro release estável. MVP enxuto.]
- [Funcionalidade essencial 1]
- [Funcionalidade essencial 2]

### 3.2. Roadmap futuro (opcional)

| Versão | Funcionalidade | Por que adiar |
|---|---|---|
| V2 | [...] | [reduz risco do MVP, etc.] |

### 3.3. Fora de escopo (todas as versões)

[Itens **explicitamente** descartados — principal defesa contra *scope creep*.]
- [Item 1]
- [Item 2]

---

## 4. Requisitos Funcionais e Mecânicas

[Regras de negócio detalhadas, fórmulas de cálculo, comportamento sob diferentes
configurações.]
- **Funcionalidade A:** [lógica, parâmetros]
- **Funcionalidade B:** [...]

---

## 5. Arquitetura de Dados (Banco)

> [!NOTE]
> **Sem tabelas próprias?** Se a persistência for só cache MUC e/ou configurações de admin
> (`config_plugins`), não há `db/install.xml` — declare isso aqui em uma linha e pule as
> regras XMLDB abaixo.

> [!IMPORTANT]
> **Regras XMLDB (se houver tabelas):**
> - Nomes: só `a-z 0-9 _`, começam com letra. Máx. **53 chars** (tabela) / **63** (campo),
>   incluindo o prefixo Frankenstyle.
> - **Auditoria temporal:** toda tabela com `timecreated` e `timemodified` (`INT`, NOTNULL)
>   desde o início — adicionar depois custa um `db/upgrade.php`.
> - **Campos de código/hash** (shortcodes, tokens): `NOTNULL` + índice `UNIQUE`. Gerar com
>   loop `do/while` checando colisão antes de gravar.
> - **`install.xml` canônico:** todo campo não-autonumber com `SEQUENCE="false"` explícito;
>   raiz `<XMLDB>` com `xmlns:xsi` + `xsi:noNamespaceSchemaLocation`. Use um `install.xml`
>   do core como referência.
> - **Limpeza ao excluir (decidir por tabela):** chave de instância própria
>   (`blockinstanceid`, id do `mod_*`) → limpa em `instance_delete()` /
>   `<modname>_delete_instance()`; chave `courseid` → observer de `\core\event\course_deleted`.
>   O Moodle **não** cascateia tabela de plugin; `KEY TYPE="foreign"` é só documentação.

```sql
-- mdl_[type_name]_[tabela]  — [propósito]
  id            BIGINT PK AUTO_INCREMENT
  [campo]       [TIPO] [RESTRIÇÕES]
  timecreated   BIGINT NOTNULL
  timemodified  BIGINT NOTNULL
  UNIQUE([campo_a], [campo_b])  -- se aplicável
```

---

## 6. Estrutura de Diretórios e Arquivos

> Marcações: `✅` implementado e validado · `🛠️` em desenvolvimento · `❌` pendente/não criado.
> **Escale para baixo:** plugins simples nascem com a maioria dos arquivos `❌` permanente —
> isso é esperado. Remova da árvore o que não se aplica.
> **Tipos especiais** (`format_`, `filter_`, `qtype_`, `theme_`, `auth_`, `enrol_`) têm
> arquivos de entrada e estrutura de `classes/` próprios — monte a árvore a partir de um
> plugin do mesmo tipo no core, não force esta.

```
[plugin]/
├── .github/workflows/ci.yml          ❌ (CI a cada commit, desde o início)
├── amd/
│   ├── build/                        ❌ (bundles compilados via grunt — commitar)
│   └── src/[module].js               ❌ (módulos AMD/ESM)
├── backup/moodle2/                   ❌ (backup/restore nativo — se há dados relacionais)
│   ├── backup_[type_name]_stepslib.php
│   └── restore_[type_name]_stepslib.php
├── classes/
│   ├── completion/custom_completion.php  ❌ (se FEATURE_COMPLETION_HAS_RULES — ver §11)
│   ├── event/[event].php             ❌
│   ├── external/[ws].php             ❌ (endpoints: {type_name}_{verbo}_{substantivo})
│   ├── local/[dominio].php           ❌ (lógica de negócio autoloaded)
│   ├── output/renderer.php           ❌
│   ├── privacy/provider.php          ❌ (SEMPRE — null_provider se não há dado pessoal)
│   └── task/[task].php               ❌
├── db/
│   ├── access.php                    ❌ (capabilities)
│   ├── events.php                    ❌ (observers de eventos do core)
│   ├── install.xml                   ❌ (schema XMLDB)
│   ├── services.php                  ❌ (registro de Web Services)
│   ├── tasks.php                     ❌ (cron — usar 'R' no agendamento)
│   ├── uninstall.php                 ❌ (só se há user_preferences ou dado em tabela core)
│   └── upgrade.php                   ✅ (SEMPRE existe, mesmo vazio — o Directory exige)
├── lang/
│   ├── en/[type_name].php            ❌ (chaves em ordem alfabética estrita)
│   └── pt_br/[type_name].php         ❌ (em sincronia com en; "estudante" nunca "aluno")
├── pix/icon.svg                      ❌
├── templates/[nome].mustache         ❌ (com Example context (json):)
├── tests/
│   ├── behat/[nome].feature          ❌
│   ├── external/[nome]_test.php      ❌
│   ├── privacy_provider_test.php     ❌
│   └── local/[nome]_test.php         ❌
├── view.php / index.php / mod_form.php   ❌ (entrada — varia por tipo)
├── lib.php                           ❌ (SÓ para callbacks legados sem equivalente)
├── settings.php                      ❌ (config de admin)
├── styles.css                        ❌ (escopado com .path-[tipo]-[nome], dual-header)
├── version.php                       ❌
├── CHANGES.md                        ❌ (vazio até a 1ª tag; cabeçalho `## [vX.Y.Z] — YYYY-MM-DD`)
├── README.md                         ❌ (público, bilíngue)
└── SCOPE.md                          ✅ (este doc — no .gitignore)
```

> [!IMPORTANT]
> **`backup/moodle2/` em `mod_*`:** `restore_[type_name]_stepslib.php::define_structure()`
> deve retornar `$this->prepare_activity_structure($paths)`, nunca `$paths` direto — senão
> "Duplicar atividade" e backup/restore de curso falham com `unknown_context_mapping`.

---

## 7. Web Services (API AJAX)

> Nomeação: `{type_name}_{verbo}_{substantivo}`. Registrar em `db/services.php`, implementar
> estendendo `\core_external\external_api`.

| Web Service | Tipo | Descrição | Entrada | Retorno |
|---|---|---|---|---|
| `[type_name]_[verbo]_[nome]` | `read`/`write` | [...] | `[param]` ([tipo]) | [JSON] |

---

## 8. Interface, Templates e Acessibilidade

- **`view.php` de `mod_*`:** não imprimir o nome da atividade manualmente — o layout
  `incourse` já renderiza ícone + nome + selo de conclusão via `$PAGE->activityheader`.
  `$PAGE->set_pagelayout('incourse')` em todo dispositivo.
- **`mod_*` — declarar `FEATURE_MOD_PURPOSE`** no `_supports()` (senão o plugin não aparece
  em nenhuma categoria do chooser "Adicionar atividade"). Assinatura do `_supports()`:
  `: mixed`, nunca `: ?bool` (coage a string do propósito para `bool(true)` em silêncio).
- **Navegação e descoberta:** para cada página, declarar como cada papel chega até ela (nó
  de navegação, menu do usuário, Preferências, admin, bloco). `local_`/`report_` quase
  sempre precisam de callbacks `*_extend_navigation_*` em `lib.php` (bumpar `version.php` +
  purgar ao adicionar). Página alcançável só por URL direta = furo de descoberta ou é
  intencional — decida.
- **Mustache:** HTML só em `templates/`, com `@template component/nome` e
  `Example context (json):` no segundo bloco `{{! }}`. `{{{valor}}}` só para markup
  confiável e estático; campo armazenado ou vindo de IA usa `{{valor}}` e é sanitizado na
  escrita.
- **CSS:** escopado com `.path-[tipo]-[nome]`; sem `!important`; cores via `var(--nome, #fb)`.
- **Bootstrap 4/5:** não usar classe só-BS5 que quebre no 4.5. `core/modal` (nunca
  `core/modal_factory`). Botão de fechar com `data-bs-dismiss` + `data-dismiss`.
- **Acessibilidade (WCAG AA):** `aria-hidden` em ícone decorativo; `aria-label` em elemento
  interativo sem texto; contraste ≥ 4.5:1; nunca cor sozinha para transmitir estado; alvo
  de toque ≥ 44×44px. Validar com simulador de daltonismo + leitor de tela + só teclado.

---

## 9. Internacionalização — lista inicial de strings

[Enumerar as principais strings de UI, em **ordem alfabética da chave**. Toda chave em
`lang/en` tem equivalente em `lang/pt_br` no mesmo commit. Valores em uma linha.]

| Chave | EN | PT-BR |
|---|---|---|
| `pluginname` | "[Name]" | "[Nome]" |

---

## 10. Bibliotecas de Terceiros (opcional)

> Só se o plugin empacotar bibliotecas externas. Cada uma: declarada em `thirdpartylibs.xml`,
> licença compatível com GPL v3+, `readme_moodle.txt` com URL/build/patches.
>
> **Biblioteca (JS/CSS) → empacotar no zip, NUNCA carregar de CDN.** Um **serviço** externo
> que você integra (player de vídeo, API de IA, mapas) é outra coisa — não entra aqui, vai
> para a §12 (Privacidade) via `add_external_location_link`.

| Item | Versão | Fonte | Licença | Uso |
|---|---|---|---|---|
| [...] | [...] | [...] | [...] | [...] |

---

## 11. Dependências e Integrações Nativas

- **Dependências soft:** [outro plugin, com verificação `class_exists()` em runtime.]
- **APIs do core usadas:** DML, Completion, Gradebook, Privacy, Events, File API, ...

> [!IMPORTANT]
> **Regra de conclusão customizada (`FEATURE_COMPLETION_HAS_RULES`)** — declarar o
> `_supports()` e o checkbox no `mod_form.php` **não basta**. São necessárias 3 peças
> (nenhuma pega por ferramenta estática):
> 1. `classes/completion/custom_completion.php` estendendo
>    `\core_completion\activity_custom_completion`.
> 2. `<type_name>_get_coursemodule_info()` em `lib.php` populando
>    `customdata['customcompletionrules'][regra]`.
> 3. `completion_info::update_state($cm, ..., $userid)` chamado no momento exato em que a
>    condição rastreada muda (o Moodle não tem tarefa que recalcula conclusão automática).

> [!IMPORTANT]
> **Integração com `core_ai` (Manager consumer):** respeitar o toggle de IA por
> curso/módulo (`course.enableaitools`), não só o gate global. Passar o `\context` real
> (nunca `context_system`) e chamar `$manager->is_action_enabled_in_context($context,
> $actionclass)` antes de `process_action()`. Esse método não existe no Moodle 4.5 — se o
> plugin suporta 4.5+5.x, envolver em `method_exists(...)` retornando `true` quando ausente.

---

## 12. Privacidade — Mapa de Dados Pessoais

> Todo plugin tem Privacy Provider. Três casos:
> - Sem dado pessoal e sem chamada externa → `\core_privacy\local\metadata\null_provider`.
> - Sem dado pessoal mas **com** chamada a serviço de terceiros → `metadata\provider` só com
>   `$collection->add_external_location_link('host', ...)`.
> - Com dado pessoal → mapear abaixo e implementar `get_metadata()`,
>   `get_contexts_for_userid()`, `export_user_data()`, `delete_data_for_user()`,
>   `delete_data_for_users()`; preferências em `export_user_preferences()`.

| Tabela / local | Dados pessoais | Finalidade |
|---|---|---|
| `[type_name]_[tabela]` | `userid`, `[campo]` | [por que armazena] |

---

## 13. Checklist de Segurança e Boas Práticas

- [ ] Sem `$DB` dentro de loop (N+1) — bulk antes.
- [ ] Query por ID externo inclui filtro de contexto/curso/instância já validado.
- [ ] `require_sesskey()` / `confirm_sesskey()` em toda rota destrutiva ou POST.
- [ ] Sem `echo $var` — `s()`, `format_string()`, `format_text()`.
- [ ] JS só em `amd/src/`, carregado via `js_call_amd()`.
- [ ] SQL só com placeholders (`?` / `:nome`).
- [ ] pt-BR: "estudante", nunca "aluno". Chaves de lang em ordem alfabética. Sem comentário
      inline em lang.
- [ ] Nenhuma linha de PHP > 132 chars (exceto valores em `/lang`).
- [ ] Privacy Provider mapeando todos os dados pessoais e conexões externas.
- [ ] Evento de auditoria (`\core\event\base`) em toda ação que muda dados do estudante.
- [ ] `gradepass`: se `mod_form.php` mostra o campo "Nota para aprovação",
      `*_grade_item_update()` aplica o valor direto no `grade_item` (o `grade_update()` do
      core descarta a chave em silêncio).
- [ ] Backup/restore com remapeamento de IDs, se há dados relacionais.
- [ ] Limpeza ao excluir instância/curso (ver §5).
- [ ] Conclusão customizada: as 3 peças da §11 existem e foram validadas ao vivo.
- [ ] Constante/função mais nova que o Moodle mínimo suportado: protegida com `defined()` /
      `function_exists()`, nunca por checagem de versão hardcoded.

---

## 14. Plano de Testes

> **Arquitetura testável:** camada de request/render **fina** (lê `required_param`, faz
> `require_login`/`require_capability`/`require_sesskey`, chama o método de negócio,
> renderiza) — intestável por design. **Lógica de negócio** em `classes/local/`, com
> parâmetros explícitos — é o que o PHPUnit exercita. Mirar ~90–100% dos métodos de negócio.

- **PHPUnit:** `tests/` espelha `classes/`. Testes de conformidade obrigatórios quando
  aplicável: `privacy_provider_test.php`, `backup_restore_test.php`, isolamento entre
  instâncias. Anotações PHPDoc (`@covers`, `@dataProvider`), nunca atributos, se suporta
  4.5+5.x.
- **Behat:** cenário fim-a-fim do fluxo do estudante/professor. Frase de step identifica o
  plugin. Um `Given`/`When`/`Then` por cenário.

---

## 15. Critérios de Aceite

| ID | Critério | Status |
|---|---|---|
| CA01 | Usuário sem a capability não vê o recurso nem acessa a URL direta. | ❌ |
| CA02 | [Funcionalidade principal] opera conforme a §4 sob config padrão. | ❌ |
| CA03 | [Caso de borda / config alternativa]. | ❌ |
| CA04 | Nenhuma string visível hardcoded — todas via `get_string()`. | ❌ |
| CA05 | Passa no `moodle-plugin-ci` e no Moodle Plugin Check sem erros. | ❌ |
| CA06 | Backup e Restore preservam dados e mapeamento de IDs (se aplicável). | ❌ |
| CA07 | Privacy API exporta e deleta todos os dados pessoais (se aplicável). | ❌ |

---

## 16. Roteiro de Implementação (Ordem de Construção)

> **Ordem de engenharia** (sequência de criação dos arquivos) — não confundir com a §3
> (o que entra em cada release). Substitua as 6 fases genéricas abaixo pelo roadmap real
> orientado a funcionalidade quando ele existir. Fases inteiras podem não se aplicar.
>
> **Antes de marcar qualquer fase `✅`:** rodar `moodle-scope-audit <tipo/nome>` e confirmar
> zero pendências daquela fase (diff mecânico entre a árvore do §6 e o disco). Toda fase que
> introduz uma tela de cadastro de dados precisa de um critério de aceite escrito como
> **jornada real do usuário** (cadastrar pela UI, sem insert manual no banco) — e esse
> critério só conta como cumprido após validação ao vivo, não só PHPUnit passando.

| Fase | Arquivos | Definition of Done | Status |
|:--:|:--|:--|:--:|
| **1: Core & infra** | `.gitignore`, `ci.yml`, `version.php`, `db/install.xml`, `db/access.php`, `lang/en` + `lang/pt_br`, `classes/local/`, `tests/local/`, `tests/fixtures/` | Banco instala sem erro, capabilities criadas, PHPUnit da lógica de domínio passando 100% | ❌ |
| **2: Telas estáticas & admin** | `settings.php`, `lib.php` (se aplicável), `classes/completion/` (se aplicável), `styles.css`, `pix/`, `classes/output/`, entrada (`view.php`/`index.php`/`mod_form.php`), strings de lang | Instalação limpa pelo admin, criar/editar instância sem erro PHP nem de render | ❌ |
| **3: UI dinâmica & Web Services** | `db/services.php`, `classes/external/`, `tests/external/`, `templates/`, `amd/src/` + `amd/build/`, telas de cadastro, strings de lang | Mustache renderiza, WS testados, AJAX sem script inline; tela de cadastro validada ao vivo | ❌ |
| **4: Tasks, events & mensagens** | `db/tasks.php`, `db/events.php`, `db/messages.php`, `classes/task/`, `classes/event/`, strings de lang | Cron roda e testado, eventos do core escutados, notificação entregue | ❌ |
| **5: Portabilidade, privacidade & segurança** | `backup/moodle2/`, `db/upgrade.php`, `db/uninstall.php` (se aplicável), `classes/privacy/provider.php`, testes de backup/privacy/isolamento, strings de lang | Backup/restore preservam IDs, Privacy API exporta/deleta, isolamento validado | ❌ |
| **6: Homologação & deploy** | `CHANGES.md`, `README.md`, `tests/behat/` + pipeline de release | Behat passando, lang em sincronia, `moodle-plugin-ci` local sem erro, pronto para publicar | ❌ |

---

## 17. Decisões de Arquitetura e Trade-offs

| Decisão | Justificativa / compromisso |
|:--|:--|
| [ex.: Cron vs. processamento on-demand] | [ex.: processamento pesado no cron para não pesar nas requisições do usuário] |

---

## 18. Histórico do Documento

| Data | Versão doc | Alteração |
|---|---|---|
| [DD/MM/AAAA] | 1.0 | Escopo inicial. |
