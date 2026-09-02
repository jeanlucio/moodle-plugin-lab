---
applyTo: "**/classes/privacy/**"
---

# Privacy API

Todo plugin tem `classes/privacy/provider.php`. Três casos:

- **Sem dado pessoal e sem chamada externa** → `\core_privacy\local\metadata\null_provider`.
- **Sem dado pessoal MAS com chamada a serviço de terceiros** (IA, SaaS) →
  `\core_privacy\local\metadata\provider` só com
  `$collection->add_external_location_link('host', ..., 'descrição')` — mesmo sem persistir
  dado de usuário. Descrição em string de lang.
- **Com dado pessoal** → `get_metadata()`, `get_contexts_for_userid()`, `export_user_data()`,
  `delete_data_for_user()`, `delete_data_for_users()`. Preferências em
  `export_user_preferences()`. APIs externas também via `add_external_location_link()`.

## Regras

- Retornar dados do **próprio usuário** a um cliente autenticado (app mobile) pelo token
  dele **não** é localização externa — é o dono acessando os próprios dados.
- **Coluna adicionada a uma tabela já declarada** em `add_database_table()` precisa de
  decisão explícita: entra no array de campos (com string de lang nova) **ou** ganha um
  comentário de uma linha explicando por que não carrega dado pessoal. Nunca ficar
  indefinida por omissão.
- Teste de regressão: afirmar que as chaves declaradas são **iguais** às colunas reais
  (via `$DB->get_columns()`, menos `id`) — não afirmar chave por chave.
- Plugin que chama IA/serviço externo **diretamente** DEVE declarar cada provider aqui e a
  disclosure no README (o Directory exige). Se só consome via um hub (`local_aihub`), o
  Privacy Provider do hub já cobre — pode usar `null_provider`.
