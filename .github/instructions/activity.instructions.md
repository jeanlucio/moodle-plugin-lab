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

Declarar o `_supports()` e o checkbox no `mod_form.php` **não basta**: a regra não é
avaliada, ou não dá para desligá-la depois, sem as 5 peças (nenhuma pega por ferramenta
estática):

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
4. **No `mod_form.php`: sufixo e regra desmarcada.**
   - Todo elemento da regra leva `$this->get_suffix()` no nome (campo, grupo, retorno de
     `add_completion_rules()` e toda chave lida em `completion_rule_enabled()`, `validation()`
     e `data_preprocessing()`). A página "Conclusão padrão da atividade" mostra o mesmo
     formulário com o sufixo `_<modname>` e **apaga** a regra cujo nome não o tem — sem erro
     na tela, só um aviso de desenvolvedor.
   - O navegador **não envia** checkbox desmarcada nem campo desativado por `disabledIf()`;
     sem tratamento, o `update_record()` mantém o valor antigo, a caixa volta marcada e o
     estudante continua preso a uma regra que o professor tirou. Implemente
     `data_postprocessing($data)` (modelo: `mod/forum/mod_form.php`): chame
     `parent::data_postprocessing($data)` e, se `!empty($data->completionunlocked)`, grave 0
     na regra quando a caixa estiver vazia **ou** quando
     `$data->{'completion' . $suffix}` não for `COMPLETION_TRACKING_AUTOMATIC`.
5. `<modname>_get_completion_active_rule_descriptions(stdClass|cm_info $cm)` recebe **só** o
   `$cm` e lê `customdata['customcompletionrules']` (o core a chama com um único argumento).

Validar ao vivo: criar instância, satisfazer a condição, ver o selo na página — e **desmarcar
a regra e salvar** para conferir que ela some. No teste, afirme a coluna no banco depois de
`<modname>_update_instance()` sem a chave, e chame `set_suffix('_<modname>')` antes de
`add_completion_rules()` (com o sufixo vazio padrão, a falta dele é invisível).

## Gradebook (`gradepass`)

Se `mod_form.php` chama `standard_grading_coursemodule_elements()` (mostra "Nota para
aprovação"), o `*_grade_item_update()` precisa buscar o `grade_item` direto
(`grade_item::fetch([...])`) e setar `gradepass` nele — o `grade_update()` do core
**descarta em silêncio** essa chave passada em `$itemdetails`. Teste afirma o valor no
`grade_item` buscado, nunca só o retorno `GRADE_UPDATE_OK`.
