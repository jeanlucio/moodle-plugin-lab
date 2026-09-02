# Moodle Plugin Lab

Ambiente de aula para desenvolver **plugins Moodle com apoio de IA** (GitHub Copilot),
pré-configurado como **GitHub Codespace**. O aluno abre o Codespace e já tem um Moodle 5.2
instalado e rodando — sem instalar nada localmente.

## Para o aluno

**[→ docs/GUIA-DO-ALUNO.md](docs/GUIA-DO-ALUNO.md)** — comece aqui.

Resumo: `Code → Codespaces → Create` · site na porta 8000 · login `admin` / `Sandbox123!` ·
`plugin-new local meuplugino` · preencher o `SCOPE.md` (primeiro trabalho).

## O que vem pronto

- **Moodle 5.2** (`MOODLE_502_STABLE`) + MariaDB, servidor na porta 8000, idioma pt-BR.
- **GitHub Copilot** com as regras de código do laboratório carregadas
  (`.github/copilot-instructions.md` + `.github/instructions/`).
- **`local_moodlecheck`** e **PHPCS** com o padrão Moodle.
- **Hook de pre-commit** (PHPCS + verificações de capability/get_string) — do
  [moodle-dev-tools](https://github.com/jeanlucio/moodle-dev-tools), conjunto curado.
- Comandos: `plugin-new`, `plugin-upgrade`, `moodle-check`, `moodle-phpunit`,
  `moodle-coverage`, `moodle-phpstan`, `moodle-scope-audit`, `set-author`.
- Ambiente PHPUnit já inicializado.

## Documentação

| Arquivo | Conteúdo |
|---|---|
| [docs/GUIA-DO-ALUNO.md](docs/GUIA-DO-ALUNO.md) | passo a passo do aluno |
| [docs/AMBIENTE.md](docs/AMBIENTE.md) | como o ambiente funciona por dentro |
| [docs/REGRAS-DE-CODIGO.md](docs/REGRAS-DE-CODIGO.md) | regras de código completas |
| [docs/TEMPLATE_SCOPE.md](docs/TEMPLATE_SCOPE.md) | modelo de planejamento de plugin |

## Para o professor

- **Distribuição:** repositório **público**; cada aluno abre um Codespace direto neste repo
  (a máquina e o Copilot são da conta do aluno). O trabalho de cada aluno vai para
  repositórios próprios dele. Não use fork nem template.
- **Ligar Prebuilds:** repositório → Settings → Codespaces → Set up prebuild (sem isso a
  primeira abertura leva ~4 min em vez de ~30 s). Em repo público os minutos de Actions do
  prebuild são gratuitos; só o snapshot conta na cota de storage de Codespaces do professor.
- **Versão do Moodle:** `MOODLE_BRANCH` em `.devcontainer/setup.sh`.
- **Revisão por IA no pre-commit:** desligada (`SKIP_AI=1` em `.devcontainer/devcontainer.json`).
  Para ligar numa turma, colocar chaves num Codespaces secret da organização e mudar para
  `SKIP_AI=0`.
- **Credenciais do site:** `admin` / `Sandbox123!` (em `.devcontainer/setup.sh`).

## Licença

GPL v3 ou posterior.
