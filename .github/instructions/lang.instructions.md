---
applyTo: "**/lang/**/*.php"
---

# Arquivos de idioma

- Chaves em **ordem alfabética estrita**. Nova string entra na posição ordenada certa,
  **nunca** no fim do arquivo.
- Valor sempre em **uma única linha** (sem concatenação, heredoc ou nowdoc). HTML e
  parágrafos vão para template Mustache, não para a string.
- **Nenhum comentário inline** (`// ...`). O único permitido é
  `// phpcs:disable moodle.Files.LineLength` logo após a linha `defined()`.
- `lang/en/` e `lang/pt_br/` andam juntos: toda chave adicionada em uma existe na outra,
  no mesmo commit, na mesma posição alfabética.
- Capitalize só a primeira palavra e nomes próprios. String completa e autônoma — nunca
  pensada para concatenar na UI. Sem espaço no início/fim.
- Vocabulário pt-BR (padrão AMOS): **"estudante" / "estudantes"**. Nunca "aluno".
- Toda capability de `db/access.php` tem string aqui (`tipo/nome:cap` → `$string['nome:cap']`).
