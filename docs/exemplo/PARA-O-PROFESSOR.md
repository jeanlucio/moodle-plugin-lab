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

   **Por que a rubrica importa aqui:** o CI fica verde mesmo num plugin vazio (sem `tests/`, o job
   `phpunit` não tem o que falhar), então a parte de "checagens automáticas" da nota pode dar
   máximo para um plugin incompleto. Quem corrige isso é a rubrica: a IA recebe a descrição da
   atividade, a rubrica, os resultados dos checks e o código, e pode ser instruída a penalizar o
   que o CI não vê. Rubrica sugerida (cole no campo; ajuste os pesos):

   ```
   Avalie o plugin Moodle block_greeting contra o SCOPE.md do repositório.
   - Completude (40%): todos os arquivos da seção 6 do SCOPE.md existem e têm conteúdo real.
     Arquivo previsto ausente, ou bloco que não renderiza a frase, vale nota baixa nesse
     critério, MESMO que os checks automáticos estejam verdes.
   - Testes (20%): existe tests/greeting_test.php com @covers na classe de teste. Sem testes, 0.
   - Convenções (20%): cabeçalho de licença em TODOS os arquivos (PHP, JS, CSS, Mustache),
     @copyright com o nome real do estudante (nunca "[Seu nome]" nem outro autor), strings em
     ordem alfabética e iguais em en e pt_br, nenhum texto fixo fora de lang/.
   - Arquitetura (20%): lógica na classe de classes/local/, bloco sem HTML, JS em amd/src com
     build em amd/build.
   Escreva o feedback em português, apontando o arquivo e o que corrigir.
   ```

   O que a rubrica **não** muda: a parcela dos checks automáticos continua sendo a proporção de
   jobs verdes. Para um exercício assim, vale baixar o peso das checagens (por exemplo 30/70) e
   confiar na revisão por IA + sua aprovação final, que é sempre manual.

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
