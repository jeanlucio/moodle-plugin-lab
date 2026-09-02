---
applyTo: "**/tests/**/*.php"
---

# Testes automatizados

## PHPUnit

- Namespace do teste espelha o da classe testada; classe sufixada com `_test`; árvore de
  `tests/` espelha a de `classes/`.
- `@package` no PHPDoc é o Frankenstyle puro (`local_gradeboard`), mesmo em subpastas de
  `tests/`.
- **Anotações PHPDoc, nunca atributos PHP.** Se o plugin suporta Moodle 4.5 e 5.x ao mesmo
  tempo, `#[CoversClass]`/`#[DataProvider]` quebram no PHPUnit 9 (Moodle 4.5). Use
  `@covers`, `@dataProvider`, `@group`.
- `@covers \Nome\Completo\Da\Classe` no **nível da classe** de teste, sem `::metodo`. Para
  um teste que exercita várias classes, uma linha `@covers` por classe. Nunca
  `@coversDefaultClass` + `@covers ::metodo`.
- Use `$this->resetAfterTest()` quando o teste escreve no banco.
- Mire a cobertura nos **métodos de negócio** (`classes/local/`), não no % da classe
  inteira — a cola de request/render é intestável por design.
- Testes obrigatórios quando aplicável: `privacy_provider_test.php`,
  `backup_restore_test.php` (se há `backup/moodle2/`), isolamento entre instâncias.

## Behat

- Toda frase de step nova **identifica o plugin** (`I do X in the gradeboard plugin`), nunca
  um nome genérico — o namespace de steps é global no site inteiro.
- Um `Given`, um `When`, um `Then` por cenário; o resto com `And`/`But`.
- Setup (`Given`) insere dado direto (gerador/`$DB`), não clica na UI.
- Preferir gerador de entidade (`tests/generator/`) a step `Given` escrito à mão.
