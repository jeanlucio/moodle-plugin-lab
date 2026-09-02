---
applyTo: "**/backup/**"
---

# Backup e restore (moodle2)

Aplica-se a qualquer plugin com `backup/moodle2/` para tabelas próprias.

- **Toda coluna do `install.xml` espelhada no `backup_nested_element(...)` correspondente.**
  Nada em PHPCS/moodlecheck/PHPStan pega uma coluna faltando — ela reverte ao default no
  restore. Verificação: diff de todo `<FIELD NAME>` contra as listas de atributos.
- **Toda FK para tabela própria do plugin:** remap no restore via
  `$this->get_mappingid('<chave>', $oldid)` — nunca inserir o ID cru.
- **Coluna sobrecarregada** (significado depende de coluna irmã): remap **condicional**
  ramificando nessa coluna, não um `get_mappingid()` único.
- **Referência restaurada por sibling XML posterior no mesmo step:** adiar o fixup — zerar o
  campo no insert, guardar `newid => oldid` num array privado, resolver em `after_execute()`.
- **ID de uma task de restore posterior** (ex.: `course_module` cru numa coluna, em
  `block_*` de curso): usar `after_restore()` do structure step (não `after_execute()`) —
  roda no fim do plano inteiro, quando os mapeamentos de `course_module` já existem.
- **`mod_*`:** `restore_<frankenstyle>_stepslib.php::define_structure()` retorna
  `$this->prepare_activity_structure($paths)`, **nunca** `$paths` direto — senão "Duplicar
  atividade" e backup/restore de curso falham com `unknown_context_mapping`.
- **Não re-rodar o restore genérico de grade item.**
  `restore_activity_grades_structure_step` já é adicionado automaticamente; chamar
  `<modname>_grade_item_update()` de novo no `after_execute()` cria dois `grade_items`.
- Teste: exercitar o `delete_course()`/`duplicate` **real** da UI, não só a suite PHPUnit.
