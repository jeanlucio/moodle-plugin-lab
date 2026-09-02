---
applyTo: "**/lib.php,**/view.php,**/mod_form.php,**/classes/completion/**"
---

# Módulo de atividade (`mod_*`) — renderização, conclusão, gradebook

## `view.php`

- **Nunca** imprimir o nome da atividade manualmente — o layout `incourse`
  (`$PAGE->activityheader`) já renderiza ícone + nome + selo de conclusão. Um
  `$OUTPUT->heading($instance->name)` extra duplica o título.
- `$PAGE->set_pagelayout('incourse')` em **todo** dispositivo. Não trocar para `'embedded'`
  (remove toda a navegação) para contornar problema de UX cuja causa está em outro lugar.

## `<modname>_supports()` (em `lib.php`)

- Assinatura: `: mixed`, **nunca** `: ?bool` — com `?bool`, `FEATURE_MOD_PURPOSE =>
  MOD_PURPOSE_X` (uma string) é coagido para `bool(true)` em silêncio e o selo some do chooser.
- Declarar `FEATURE_MOD_PURPOSE` (senão o plugin não aparece em nenhuma categoria de
  "Adicionar atividade").
- Constante/função mais nova que o Moodle mínimo suportado (ex.: `FEATURE_MOD_OTHERPURPOSE`,
  5.1+): proteger com `defined('CONST')` / `function_exists('fn')`, **nunca** checagem de
  versão hardcoded. Testar em **toda** leg da matriz de CI.

## Conclusão customizada (`FEATURE_COMPLETION_HAS_RULES`)

Declarar o `_supports()` e o checkbox no `mod_form.php` **não basta**. As 3 peças (nenhuma
pega por ferramenta estática):

1. `classes/completion/custom_completion.php` estendendo
   `\core_completion\activity_custom_completion` (`get_state()`,
   `get_defined_custom_rules()`, `get_custom_rule_descriptions()`, `get_sort_order()`). O
   core não chama mais a função legada `<modname>_get_completion_state()`.
2. `<modname>_get_coursemodule_info()` em `lib.php` populando
   `$info->customdata['customcompletionrules'][$rulename]` (o valor cru) quando
   `$coursemodule->completion == COMPLETION_TRACKING_AUTOMATIC`. Adicionar a um `lib.php`
   existente exige purgar cache.
3. `completion_info::update_state($cm, ..., $userid)` no momento exato em que a condição
   rastreada muda — o Moodle não tem tarefa que recalcula conclusão automática.

Validar ao vivo: criar instância, satisfazer a condição, ver o selo na página.

## Gradebook (`gradepass`)

Se `mod_form.php` chama `standard_grading_coursemodule_elements()` (mostra "Nota para
aprovação"), o `*_grade_item_update()` precisa buscar o `grade_item` direto
(`grade_item::fetch([...])`) e setar `gradepass` nele — o `grade_update()` do core
**descarta em silêncio** essa chave passada em `$itemdetails`. Teste afirma o valor no
`grade_item` buscado, nunca só o retorno `GRADE_UPDATE_OK`.
