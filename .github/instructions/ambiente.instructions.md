---
applyTo: "**"
---

# Ambiente (Codespace do Moodle Plugin Lab)

Complementa a seção "Ambiente" do `copilot-instructions.md`. Referência completa:
`docs/AMBIENTE.md`. **Nada aqui existe fora deste Codespace.**

- **Site:** servidor embutido do PHP na porta 8000, docroot `moodle/public`.
  Login `admin` / `Sandbox123!`. Banco: MariaDB, `moodle` / `moodle` / `moodle`, prefixo `mdl_`.
- **Scripts CLI do Moodle 5.x ficam na raiz** do checkout (`moodle/admin/cli/`), não sob
  `public/`. O código web fica sob `moodle/public/`. `$CFG->dirroot` = `moodle/public`.
- **Plugins do aluno:** `moodle/public/<tipo>/<nome>/`, cada um seu próprio repo git.

## Comandos além dos do copilot-instructions

| Ação | Comando |
|---|---|
| Criar plugin | `plugin-new <tipo> <nome>` |
| (Re)sincronizar as regras da IA num plugin | `plugin-rules` (de dentro do plugin) |
| Cobertura de testes | `moodle-coverage <tipo/nome>` |
| Análise estática de tipos | `moodle-phpstan <tipo/nome>` |
| Conferir árvore do SCOPE §6 | `moodle-scope-audit <tipo/nome>` |
| Purgar cache só | `php moodle/admin/cli/purge_caches.php` |

- O hook de **pre-commit** roda PHPCS + gates no `git commit` de um plugin; bloqueia em
  warnings também, igual ao CI.
- Após editar `amd/src/*.js`: `npx grunt amd` (de dentro do plugin) e depois `plugin-upgrade`.
