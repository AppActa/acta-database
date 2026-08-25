/*
CTEs Recursivas ACTA
Essas são as CTEs que pensamos e que fazem sentido considerando o nosso script.sql:

1. listar árvore de problema
 - Lista todos os problemas relacionados. 
    Ex:
       - Problema principal
            - Causa ou subproblema 1
                - Subproblema do item 1
            - Causa ou subproblema 2
        ...
2. Encontrar dependência de tarefas
 - Mostra todas as tarefas que precisam ser feitas antes de fazer a tarefa X.
    Ex:
      - Tarefa escolhida (id=5)
        - Tarefa anterior (id=4)
        ...

3. Encontrar tarefas dependentes a partir de uma tarefa Y
 - O inverso da CTE acima. Essa busca as tarefas que dependem de uma tarefa Y
    Ex:
      - Tarefa escolhida (id=5)
        - Tarefa que depende da tarefa acima (id=6)
        ...

4. Ciclos nas tarefas
 - Basicamente, se resume em: "Existe uma tarefa A que depende da tarefa B que depende da C. Mas a C depende da A" -> procura por ciclos assim.
 


Detalhe que yo encontré enquanto observava el script.sql:
Un problema permite ser padre de un problema de outro ciclo.
entao, pode ser que tenha um problema pai do ciclo x que tem um problema filho no ciclo Y.
Como resolver: Talvez uma FK composta, com ID e_problmema_pai e id_ciclo

parte em que isso aparece:

CREATE TABLE IF NOT EXISTS pdca.problema (
    id BIGSERIAL PRIMARY KEY,
    id_ciclo BIGINT NOT NULL REFERENCES pdca.ciclo(id) ON DELETE CASCADE,
    id_problema_pai BIGINT REFERENCES pdca.problema(id) ON DELETE CASCADE, --> aqui, ele so garante que existe, mas nn verifica se ele é do mesmo ciclo... 
    criado_por BIGINT NOT NULL REFERENCES usuario_sistema(id),
    titulo VARCHAR(160) NOT NULL,
    descricao TEXT NOT NULL,
    peso NUMERIC(3,2) NOT NULL CHECK (peso BETWEEN 0 AND 1),
    status VARCHAR(40) NOT NULL CHECK (status IN ('ABERTO', 'EM_ANALISE', 'PRIORIZADO', 'RESOLVIDO', 'DESCARTADO')),
    origem VARCHAR(40) NOT NULL CHECK (origem IN ('MANUAL', 'IA', 'FORMULARIO', 'IMPORTACAO', 'SISTEMA')),
    persistente BOOLEAN NOT NULL DEFAULT FALSE,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ
);

possivel resolucao:
ALTER TABLE pdca.problema
ADD CONSTRAINT problema_id_ciclo_unique   -> pra  garantir que nn tenha um par igual a esse ja
UNIQUE (id, id_ciclo);

ALTER TABLE pdca.problema
ADD CONSTRAINT problema_pai_mesmo_ciclo_fk
FOREIGN KEY (id_problema_pai, id_ciclo)  -> cria a FK 
REFERENCES pdca.problema (id, id_ciclo);

*/

-- 1. Árvore de problemas
CREATE OR REPLACE VIEW pdca.vw_arvore_problemas AS
WITH RECURSIVE arvore AS (
    SELECT
        p.id AS id_problema,
        p.id_ciclo,
        p.id_problema_pai,
        p.titulo,
        p.descricao,
        p.status,
        p.peso,
        p.origem,
        p.persistente,
        p.id AS id_problema_raiz,
        0 AS nivel,
        ARRAY[p.id]::BIGINT[] AS caminho
    FROM pdca.problema p
    WHERE p.id_problema_pai IS NULL

    UNION ALL

    SELECT
        filho.id,
        filho.id_ciclo,
        filho.id_problema_pai,
        filho.titulo,
        filho.descricao,
        filho.status,
        filho.peso,
        filho.origem,
        filho.persistente,
        arvore.id_problema_raiz,
        arvore.nivel + 1,
        arvore.caminho || filho.id
    FROM arvore
    JOIN pdca.problema filho
      ON filho.id_problema_pai = arvore.id_problema
      AND filho.id_ciclo = arvore.id_ciclo
    WHERE NOT filho.id = ANY(arvore.caminho)
)
SELECT
    id_problema_raiz,
    id_problema,
    id_ciclo,
    id_problema_pai,
    repeat('    ', nivel) || titulo AS problema_hierarquico,
    titulo,
    descricao,
    status,
    peso,
    origem,
    persistente,
    nivel,
    caminho
FROM arvore;


--uso
SELECT *
FROM pdca.vw_arvore_problemas
WHERE id_ciclo = 1
ORDER BY id_problema_raiz, caminho;


/*
Possível Retorno:

"DL - Problema principal"
"    DL - Causa ou subproblema 1"
"        DL - Subproblema do item 1"
"    DL - Causa ou subproblema 2"

*/

-- 2. Dependências anteriores de cada tarefa
CREATE OR REPLACE VIEW pdca.vw_dependencias_tarefas AS
WITH RECURSIVE dependencias AS (
    SELECT
        t.id AS id_tarefa_origem,
        t.id AS id_tarefa,
        t.titulo,
        t.descricao,
        t.status,
        t.prioridade,
        0 AS nivel,
        ARRAY[t.id]::BIGINT[] AS caminho
    FROM pdca.tarefa t

    UNION ALL

    SELECT
        d.id_tarefa_origem,
        anterior.id,
        anterior.titulo,
        anterior.descricao,
        anterior.status,
        anterior.prioridade,
        d.nivel + 1,
        d.caminho || anterior.id
    FROM dependencias d
    JOIN pdca.tarefa_dependencia td
      ON td.id_tarefa = d.id_tarefa
    JOIN pdca.tarefa anterior
      ON anterior.id = td.id_tarefa_dependencia
    WHERE NOT anterior.id = ANY(d.caminho)
)
SELECT
    id_tarefa_origem,
    id_tarefa,
    titulo,
    descricao,
    status,
    prioridade,
    nivel,
    caminho
FROM dependencias;

--uso

SELECT *
FROM pdca.vw_dependencias_tarefas
WHERE id_tarefa_origem = 5
ORDER BY caminho;

/*
Possível Retorno:
id_tarefa      Tarefa
5	            "Integrar suite ao CI"
4	            "Automatizar login e autenticacao"
3	            "Mapear fluxos criticos"

*/

-- 3. Tarefas que dependem de outra tarefa
CREATE OR REPLACE VIEW pdca.vw_tarefas_dependentes AS
WITH RECURSIVE dependentes AS (
    SELECT
        t.id AS id_tarefa_origem,
        t.id AS id_tarefa,
        t.titulo,
        t.descricao,
        t.status,
        t.prioridade,
        0 AS nivel,
        ARRAY[t.id]::BIGINT[] AS caminho
    FROM pdca.tarefa t

    UNION ALL

    SELECT
        d.id_tarefa_origem,
        posterior.id,
        posterior.titulo,
        posterior.descricao,
        posterior.status,
        posterior.prioridade,
        d.nivel + 1,
        d.caminho || posterior.id
    FROM dependentes d
    JOIN pdca.tarefa_dependencia td
      ON td.id_tarefa_dependencia = d.id_tarefa
    JOIN pdca.tarefa posterior
      ON posterior.id = td.id_tarefa
    WHERE NOT posterior.id = ANY(d.caminho)
)
SELECT
    id_tarefa_origem,
    id_tarefa,
    titulo,
    descricao,
    status,
    prioridade,
    nivel,
    caminho
FROM dependentes;

--uso

SELECT *
FROM pdca.vw_tarefas_dependentes
WHERE id_tarefa_origem = 5
ORDER BY caminho;


/*
Possível Retorno:
id_tarefa      Tarefa
10	           "DL - Tarefa A - Preparar diagnóstico"
11	           "DL - Tarefa B - Analisar causas"
12	           "DL - Tarefa C - Executar plano"

*/

-- 4. Ciclos nas dependências das tarefas
CREATE OR REPLACE VIEW pdca.vw_ciclos_tarefas AS
WITH RECURSIVE caminhos AS (
    SELECT
        td.id_tarefa AS id_tarefa_inicio,
        td.id_tarefa_dependencia AS id_tarefa_atual,
        ARRAY[
            td.id_tarefa,
            td.id_tarefa_dependencia
        ]::BIGINT[] AS caminho,
        FALSE AS encontrou_ciclo
    FROM pdca.tarefa_dependencia td

    UNION ALL

    SELECT
        c.id_tarefa_inicio,
        td.id_tarefa_dependencia,
        c.caminho || td.id_tarefa_dependencia,
        td.id_tarefa_dependencia = ANY(c.caminho)
    FROM caminhos c
    JOIN pdca.tarefa_dependencia td
      ON td.id_tarefa = c.id_tarefa_atual
    WHERE NOT c.encontrou_ciclo
)
SELECT DISTINCT
    c.id_tarefa_inicio,
    c.caminho AS caminho_ids,
    ARRAY(
        SELECT t.titulo
        FROM unnest(c.caminho) WITH ORDINALITY AS x(id, ordem)
        JOIN pdca.tarefa t
          ON t.id = x.id
        ORDER BY x.ordem
    ) AS caminho_titulos
FROM caminhos c
WHERE c.encontrou_ciclo;


--uso

SELECT *
FROM pdca.vw_ciclos_tarefas;

/*
Possível Retorno

10	{10,12,11,10}	"{""DL - Tarefa A - Preparar diagnóstico"",""DL - Tarefa C - Executar plano"",""DL - Tarefa B - Analisar causas"",""DL - Tarefa A - Preparar diagnóstico""}"
11	{11,10,12,11}	"{""DL - Tarefa B - Analisar causas"",""DL - Tarefa A - Preparar diagnóstico"",""DL - Tarefa C - Executar plano"",""DL - Tarefa B - Analisar causas""}"
12	{12,11,10,12}	"{""DL - Tarefa C - Executar plano"",""DL - Tarefa B - Analisar causas"",""DL - Tarefa A - Preparar diagnóstico"",""DL - Tarefa C - Executar plano""}"


*/