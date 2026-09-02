---
applyTo: "**"
---

# Ambiente (Codespace do Moodle Plugin Lab)

Contexto de infraestrutura. Referência completa: `docs/AMBIENTE.md`.
Estes comandos existem **só neste Codespace** — não sugerir num contexto fora do lab.

- **Tudo roda nativo, sem Docker.** PHP, MariaDB e o servidor web estão no próprio
  container. **Nunca** usar `docker exec`.
- **Site:** servidor embutido do PHP na porta 8000, docroot `moodle/public`.
  Login `admin` / `Sandbox123!`. Banco: MariaDB, `moodle` / `moodle` / `moodle`, prefixo `mdl_`.
- **Plugins do aluno:** ficam em `moodle/public/<tipo>/<nome>/`, cada um seu próprio repo git.
- **Scripts CLI do Moodle 5.x ficam na raiz** do checkout (`moodle/admin/cli/`), não sob
  `public/`. O código web fica sob `moodle/public/`.

## Comandos do laboratório

| Ação | Comando |
|---|---|
| Criar plugin | `plugin-new <tipo> <nome>` |
| (Re)sincronizar as regras da IA num plugin | `plugin-rules` (de dentro do plugin) |
| Publicar o plugin no GitHub do aluno | `plugin-publish` (de dentro do plugin) |
| Moodle reconhecer mudança (novo `lib.php`, `db/`, bump de `version.php`) | `plugin-upgrade` |
| Rodar testes de um plugin | `moodle-phpunit <tipo/nome>` |
| Cobertura | `moodle-coverage <tipo/nome>` |
| Verificar PHPDoc (o mesmo do CI) | `moodle-check <arquivo.php>` |
| Análise estática de tipos | `moodle-phpstan <tipo/nome>` |
| Conferir árvore do SCOPE §6 | `moodle-scope-audit <tipo/nome>` |
| Compilar AMD (de dentro da pasta do plugin) | `npx grunt amd` (depois `plugin-upgrade`) |
| Purgar cache só | `php moodle/admin/cli/purge_caches.php` |

## Testes

- **PHPUnit** roda nativo (`moodle-phpunit`). Ambiente já inicializado (`phpu_` prefix).
- **Behat NÃO roda localmente** — sobe um segundo site + Selenium, estoura a memória de um
  Codespace padrão. Escreva os `.feature` e deixe o CI (GitHub Actions) executá-los.
- O hook de **pre-commit** roda PHPCS + gates automaticamente no `git commit` de um plugin.
  Bloqueia em warnings também, igual ao CI.
