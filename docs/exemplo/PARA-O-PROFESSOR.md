# Exercício 1 + `mod_codereview` — o ciclo completo dos dois sistemas

O laboratório e o `mod_codereview` são **complementares**:

- **Moodle Plugin Lab** (Codespace) — onde o aluno desenvolve. Produz um **repositório
  GitHub público** com o plugin e um workflow de CI.
- **`mod_codereview`** — atividade instalada **no seu Moodle** (o do curso, onde estão os
  alunos e as notas). Lê o repositório, os resultados do CI, roda revisão por IA, verifica
  autoria, e você aprova a nota.

## Montando a demonstração

1. **Aluno** faz o exercício 1 (`docs/exemplo/PASSOS.md`) e publica:
   ```
   plugin-publish        # cria moodle-block_greeting PÚBLICO
   ```

2. **Você** instala o `mod_codereview` no seu Moodle e cria uma atividade **CodeReview**:

   | Campo | Valor sugerido |
   |---|---|
   | Repositório-molde (`templaterepourl`) | `https://github.com/jeanlucio/moodle-block_greeting-template` |
   | Rubrica (lida pela IA) | os critérios da seção 15 do `SCOPE-greeting.md` |
   | Peso das checagens automáticas | 60 |
   | Peso da revisão por IA | 40 |
   | Token do GitHub | seu PAT fine-grained, somente leitura (preferências do professor) |

3. **Aluno** submete a URL do repo dele + o SHA do commit.

4. **`mod_codereview`** então:
   - lê os **7 check-runs** do CI (o `ci.yml` do molde tem um job por critério — phplint,
     phpcs, phpdoc, savepoints, mustache, grunt, phpunit)
   - pede à IA uma revisão comparando o código com o `SCOPE.md` (que está no repo)
   - compara os blobs contra o `moodle-block_greeting-template` (linha de base) — o
     boilerplate comum é subtraído, só a lógica do aluno entra na verificação de autoria
   - **você aprova** a nota final

## O repositório-molde

`jeanlucio/moodle-block_greeting-template` é **só o esqueleto** — `version.php`, a classe do
bloco vazia, as strings, o CI, o `SCOPE.md`. **Não tem a implementação.** Um aluno que o
encontrar ganha nada: é o mesmo que o `plugin-new block greeting` gera pra ele. O
`tests/greeting_test.php` já está lá e **falha** até o bloco renderizar a saudação — é o
alvo concreto do exercício.

Serve para duas coisas:
- **`templaterepourl`** da atividade (linha de base de integridade).
- **"Use this template"** para o aluno que prefere começar do esqueleto em vez do `plugin-new`.

## Gabarito

Se quiser uma solução funcionando para comparar durante a correção, faça um `block_greeting`
completo uma vez e guarde num **repositório privado seu** — não vai no `templaterepourl`
nem em lugar público.
