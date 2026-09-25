# 🗄️ ACTA Database

Banco de dados relacional do ACTA para sustentar o ciclo **PDCA** (*Plan, Do, Check, Act*): centraliza dados operacionais, regras de negócio, auditoria, indicadores e estruturas analíticas para BI.

## 📌 Visão geral

O `acta-database` é a base PostgreSQL do ecossistema ACTA. O projeto organiza empresas, usuários e colaboradores; ciclos PDCA, problemas e causas-raiz; planos de ação, 5W2H, tarefas, metas, treinamentos, verificações, alertas e anexos.

Além do modelo transacional, o repositório reúne a carga de dados para desenvolvimento, a migração do banco do primeiro ano, rotinas PL/pgSQL, trilhas de auditoria, catálogo de metadados e views preparadas para análise e monitoramento.

## ✨ Capacidades

- Modelo relacional normalizado com chaves primárias, estrangeiras, restrições e tabelas associativas.
- Massa de dados verossímil superior a 500 registros, gerada com Faker para testes de volume e integração.
- Migração do banco do primeiro ano com transformação, saneamento e remapeamento de identificadores.
- Functions, procedures e triggers para regras críticas do ciclo PDCA.
- Auditoria de inserções, alterações, exclusões, mudanças de status e acessos.
- Views analíticas com CTEs, CTEs recursivas e Window Functions.
- Camada dimensional com dimensões e fatos para consumo por ferramentas de BI.
- Catálogo técnico de dados e monitoramento de usuários ativos por dia.
- Índices acompanhados de consultas com `EXPLAIN ANALYZE` para análise de desempenho.

## 🧱 Modelo de dados

O banco está dividido em três schemas:

| Schema | Responsabilidade |
| --- | --- |
| `public` | Empresas, usuários, colaboradores, convites e dados de contato |
| `pdca` | Ciclos, problemas, causas-raiz, planos, tarefas, metas, treinamentos, verificações, alertas e anexos |
| `auditoria` | Logs, atividade diária, catálogo de dados e views de monitoramento |

Os relacionamentos **1:N** são representados por chaves estrangeiras entre as entidades do domínio. Relações **N:N**, como usuários por ciclo, responsáveis por metas e participantes de treinamentos, utilizam tabelas associativas com chaves primárias compostas. O detalhamento 5W2H mantém uma relação **1:1** com o plano de ação por meio de uma chave estrangeira única.

Restrições `NOT NULL`, `UNIQUE`, `CHECK` e ações referenciais preservam formatos, estados permitidos, coerência de datas e integridade entre registros.

## 🛠️ Tecnologias

| Tecnologia | Uso |
| --- | --- |
| PostgreSQL 16 | Banco relacional e recursos avançados de SQL |
| SQL e PL/pgSQL | Modelo, índices, views, functions, procedures e triggers |
| Python | Carga de dados e migração do primeiro ano |
| Pandas e SQLAlchemy | Transformação e persistência dos dados |
| Faker | Geração de dados verossímeis em português do Brasil |
| Jupyter e Papermill | Execução parametrizada da carga inicial |

## ✅ Pré-requisitos e configuração

- PostgreSQL 16 acessível e cliente `psql` instalado.
- Python 3.12 ou superior para executar os scripts de dados.
- Banco de destino criado e credenciais com permissão para criar schemas e objetos.

Instale as dependências Python:

```powershell
python -m pip install -r .\python\requirements.txt
```

As conexões são informadas por variáveis de ambiente:

```env
FULL_URL=postgresql+psycopg2://usuario:senha@localhost:5432/acta
URL_PRIMEIRO_BANCO=postgresql+psycopg2://usuario:senha@localhost:5432/acta_primeiro
URL_SEGUNDO_BANCO=postgresql+psycopg2://usuario:senha@localhost:5432/acta
```

| Variável | Uso |
| --- | --- |
| `FULL_URL` | Conexão SQLAlchemy usada pelo `dataload.ipynb` |
| `URL_PRIMEIRO_BANCO` | [Banco do primeiro ano](https://github.com/AppActa/acta-primeiro/blob/main/src/main/resources/sql/script_banco.sql) usado como origem da migração |
| `URL_SEGUNDO_BANCO` | Banco do segundo ano normalizado usado como destino da migração |

Nunca versione senhas ou URLs reais de conexão. O [`.env.example`](.env.example) contém apenas valores de referência.

> [!CAUTION]
> O arquivo [`sql/001_script.sql`](sql/001_script.sql) executa `DROP SCHEMA ... CASCADE` antes de recriar a estrutura. Use a sequência completa somente em um banco descartável, vazio ou com restauração previamente planejada. Ela não é uma migração incremental para uma base com dados que precisam ser preservados.

## 🚀 Execução local

### 1. Aplicar a estrutura

Os arquivos SQL possuem dependências entre si e devem ser executados em ordem numérica:

```powershell
$env:DATABASE_URL = "postgresql://usuario:senha@localhost:5432/acta"

Get-ChildItem .\sql -Filter *.sql |
    Sort-Object Name |
    ForEach-Object {
        psql $env:DATABASE_URL -v ON_ERROR_STOP=1 -f $_.FullName
        if ($LASTEXITCODE -ne 0) {
            throw "Falha ao aplicar $($_.Name)"
        }
    }
```

### 2. Gerar a massa de dados

O notebook cria empresas, pessoas e registros relacionados ao ciclo PDCA, mantendo as dependências entre as tabelas:

```powershell
$env:FULL_URL = "postgresql+psycopg2://usuario:senha@localhost:5432/acta"
python -m papermill .\python\dataload.ipynb "$env:TEMP\acta-dataload-output.ipynb" --log-output
```

### 3. Migrar dados do banco do primeiro ano

O RPA lê o banco de origem, transforma os dados com Pandas, remapeia os identificadores e carrega o banco normalizado na ordem das dependências:

```powershell
$env:URL_PRIMEIRO_BANCO = "postgresql+psycopg2://usuario:senha@localhost:5432/acta_primeiro"
$env:URL_SEGUNDO_BANCO = "postgresql+psycopg2://usuario:senha@localhost:5432/acta"
python .\python\rpa.py
```

O destino deve conter a estrutura SQL antes da migração. A execução registra o andamento por tabela e encerra com erro quando uma etapa da carga falha.

## ⚙️ Regras, auditoria e otimização

As rotinas PL/pgSQL centralizam comportamentos que precisam permanecer consistentes independentemente do cliente que acessa o banco. Entre elas estão a validação do início de tarefas, o cálculo do avanço de ciclos, o encerramento de ciclos, a reabertura de tarefas e a geração de alertas de atraso.

Os triggers registram os estados anterior e posterior em JSONB e identificam operações `INSERT`, `UPDATE` e `DELETE`. Para associar a alteração ao usuário do ACTA, a aplicação deve definir `app.current_user_id` na mesma transação que realiza a operação:

```sql
SET LOCAL app.current_user_id = '42';
```

O arquivo [`sql/002_indices.sql`](sql/002_indices.sql) reúne consultas analisadas com `EXPLAIN ANALYZE` e os respectivos índices para filtros e relacionamentos frequentes.

## 📊 BI e monitoramento

A camada analítica combina modelagem dimensional e views de negócio:

| Camada | Conteúdo |
| --- | --- |
| Dimensões | Usuário, empresa, ciclo, plano de ação e data |
| Fatos | Tarefas, planos, treinamentos, alertas e logs de auditoria |
| Análises | Prazos, metas, desempenho, ranking de problemas e histórico de verificações |
| Monitoramento | DAU por empresa e usuário, acessos a ciclos, convites, anexos e auditoria |

CTEs organizam as transformações; CTEs recursivas percorrem hierarquias de problemas e dependências de tarefas; e Window Functions calculam rankings, acumulados, sequências e comparações temporais.

As principais views dimensionais e de fatos estão em [`sql/009_views.sql`](sql/009_views.sql). As análises com CTEs e Window Functions ficam nos scripts `004`, `005` e `006`.

## 🛡️ Governança e recuperação

O catálogo `auditoria.catalogo_dados` descreve schemas, tabelas, colunas, tipos, chaves, regras de negócio e níveis de acesso. Os comentários nativos do PostgreSQL complementam esse catálogo diretamente nos objetos do banco.

Antes de qualquer recriação de schemas, gere um backup fora do repositório:

```powershell
pg_dump $env:DATABASE_URL --format=custom --file=acta.backup
```

Valide a recuperação preferencialmente em outro banco:

```powershell
$env:RESTORE_DATABASE_URL = "postgresql://usuario:senha@localhost:5432/acta_restore"
pg_restore --dbname=$env:RESTORE_DATABASE_URL --exit-on-error acta.backup
```

O backup só deve ser considerado utilizável depois de uma restauração validada. Em produção, retenção, criptografia, acesso ao arquivo e objetivo de recuperação devem seguir a política do ambiente.

## 🏗️ Arquitetura dos scripts

```text
sql/
├── 001_script.sql                         # schemas, tabelas e restrições
├── 002_indices.sql                        # análise de consultas e índices
├── 003_functions_triggers_procedures.sql  # regras, auditoria e automações
├── 004_ctes.sql                           # views analíticas com CTEs
├── 005_recursive_ctes.sql                 # hierarquias e dependências
├── 006_window_function.sql                # cálculos analíticos por janela
├── 007_comments.sql                       # documentação dos objetos
├── 008_catalogo.sql                       # metadados e níveis de acesso
└── 009_views.sql                          # dimensões, fatos e monitoramento
```

A ordem numérica representa a dependência entre as camadas: primeiro o modelo, depois os objetos que o utilizam e, por fim, as estruturas de documentação e consulta.

## 📁 Estrutura

```text
.
├── .github/workflows/  # validação e aplicação automatizada dos scripts
├── python/
│   ├── dataload.ipynb  # geração e carga da massa de dados
│   ├── rpa.py          # migração do banco do primeiro ano
│   └── requirements.txt
├── sql/                # estrutura e objetos PostgreSQL versionados
└── README.md
```

## 🤝 Links e autoria

- [Repositório](https://github.com/AppActa/acta-database) · [Licença MIT](LICENSE) · `acta.institutojef@gmail.com`
- Contribuições: use *issues* e *pull requests*; há um [`PULL_REQUEST_TEMPLATE.md`](PULL_REQUEST_TEMPLATE.md).
- Autoria: Equipe ACTA.