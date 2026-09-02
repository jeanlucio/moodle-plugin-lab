---
applyTo: "**/availability/**"
---

# Condições de disponibilidade (`availability_*`)

- **Cada condição-folha é responsável por honrar o parâmetro `$not` (negação).** A base
  `\core_availability\condition::check_available()` devolve `is_available($not, ...)`
  verbatim — **não** inverte por você.
- Calcular o resultado numa **única variável** em todas as ramificações e inverter num
  **único ponto de saída**:
  ```php
  $allow = <check>;
  if ($not) {
      $allow = !$allow;
  }
  return $allow;
  ```
  Nunca `return` de dentro de cada branch — senão `$not` silenciosamente não tem efeito e
  a restrição "o estudante NÃO pode corresponder a..." libera exatamente quem devia barrar.
- **`get_description()` também renderiza a variante negada quando `$not` é true**
  (ex.: `requires_item` vs `requires_not_item`, espelhando o padrão de `availability_grade`).
  Nunca mostrar a redação afirmativa independente de `$not`.
- **Testar os DOIS estados de `$not` para cada subtipo/branch** — não é polimento opcional.
  Cobertura de linha não pega um `if ($not)` que nunca foi escrito. Para cada assertion com
  `$not=false`, adicionar a espelhada com `$not=true` afirmando o inverso booleano exato.

Referência: as condições irmãs do core (`availability_grade`, `availability_profile`,
`availability_completion`).
