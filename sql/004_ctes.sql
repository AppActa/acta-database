/*
VIEW: pdca.vw_resumo_ciclo
Objetivo principal: Essa view tem como principal objetivo fornecer um resumo das informações gerais de cada ciclo, como quantidade de problemas, causas, planos, tarefas e metas. Essa view pode ser utilizada em dashboards, filtradas pelo id_ciclo, id_empresa, status do ciclo, entre outros.
*/



CREATE OR REPLACE VIEW pdca.vw_resumo_ciclo AS
WITH problemas AS (
    SELECT
        id_ciclo,
        COUNT(*) AS qtd_problemas
    FROM pdca.problema
    WHERE status <> 'DESCARTADO'
    GROUP BY id_ciclo
),

causas AS (
    SELECT
        id_ciclo,
        COUNT(*) AS qtd_causas,
        COUNT(*) FILTER (WHERE principal = TRUE) AS qtd_causas_principais
    FROM pdca.causa_raiz
    GROUP BY id_ciclo
),

planos AS (
    SELECT
        id_ciclo,
        COUNT(*) AS qtd_planos,
        COUNT(*) FILTER (WHERE status = 'CONCLUIDO') AS planos_concluidos
    FROM pdca.plano_acao
    GROUP BY id_ciclo
),

tarefas AS (
    SELECT
        pa.id_ciclo,
        COUNT(t.id) AS qtd_tarefas,
        COUNT(t.id) FILTER (
            WHERE t.status = 'CONCLUIDA'
        ) AS tarefas_concluidas,
        COUNT(t.id) FILTER (
            WHERE t.status = 'ATRASADA'
               OR (
                   t.data_fim_prevista < CURRENT_DATE
                   AND t.status NOT IN ('CONCLUIDA', 'CANCELADA')
               )
        ) AS tarefas_atrasadas
    FROM pdca.plano_acao pa
    LEFT JOIN pdca.tarefa t
        ON t.id_plano_acao = pa.id
    GROUP BY pa.id_ciclo
),

metas AS (
    SELECT
        id_ciclo,
        COUNT(*) AS qtd_metas,
        COUNT(*) FILTER (
            WHERE status = 'ATINGIDA'
        ) AS metas_atingidas
    FROM pdca.meta
    GROUP BY id_ciclo
)

SELECT
    c.id AS id_ciclo,
    c.id_empresa,
    e.nome AS empresa,
    c.titulo,
    c.status,
    c.data_inicio,
    c.data_estimada_fim,
    c.data_fim_real,

    u.id AS id_responsavel,
    u.nome AS responsavel,

    COALESCE(p.qtd_problemas, 0) AS qtd_problemas,
    COALESCE(cr.qtd_causas, 0) AS qtd_causas,
    COALESCE(cr.qtd_causas_principais, 0) AS qtd_causas_principais,

    COALESCE(pa.qtd_planos, 0) AS qtd_planos,
    COALESCE(pa.planos_concluidos, 0) AS planos_concluidos,

    COALESCE(t.qtd_tarefas, 0) AS qtd_tarefas,
    COALESCE(t.tarefas_concluidas, 0) AS tarefas_concluidas,
    COALESCE(t.tarefas_atrasadas, 0) AS tarefas_atrasadas,

    CASE
        WHEN COALESCE(t.qtd_tarefas, 0) = 0 THEN 0
        ELSE ROUND(
            t.tarefas_concluidas::NUMERIC
            / t.qtd_tarefas * 100,
            2
        )
    END AS percentual_tarefas_concluidas,

    COALESCE(m.qtd_metas, 0) AS qtd_metas,
    COALESCE(m.metas_atingidas, 0) AS metas_atingidas

FROM pdca.ciclo c

JOIN empresa e
    ON e.id = c.id_empresa

JOIN usuario_sistema u
    ON u.id = c.id_responsavel

LEFT JOIN problemas p
    ON p.id_ciclo = c.id

LEFT JOIN causas cr
    ON cr.id_ciclo = c.id

LEFT JOIN planos pa
    ON pa.id_ciclo = c.id

LEFT JOIN tarefas t
    ON t.id_ciclo = c.id

LEFT JOIN metas m
    ON m.id_ciclo = c.id;

/*
VIEW: pdca.vw_tarefas_prazo
Objetivo principal: Essa view tem como principal objetivo fornecer informações detalhadas sobre as tarefas, principalmente os prazos delas.


*/

CREATE OR REPLACE VIEW pdca.vw_tarefas_prazo AS
WITH classificacao AS (
    SELECT
        t.*,

        CASE
            WHEN t.status = 'CONCLUIDA'
                THEN 'CONCLUIDA'

            WHEN t.status = 'CANCELADA'
                THEN 'CANCELADA'

            WHEN t.data_fim_prevista < CURRENT_DATE
                THEN 'ATRASADA'

            WHEN t.data_fim_prevista = CURRENT_DATE
                THEN 'VENCE_HOJE'

            WHEN t.data_fim_prevista <= CURRENT_DATE + 3
                THEN 'VENCE_EM_3_DIAS'

            WHEN t.data_fim_prevista <= CURRENT_DATE + 7
                THEN 'VENCE_EM_7_DIAS'

            ELSE 'NO_PRAZO'
        END AS situacao_prazo,

        t.data_fim_prevista - CURRENT_DATE AS dias_restantes

    FROM pdca.tarefa t
)

SELECT
    c.id AS id_ciclo,
    c.titulo AS ciclo,

    pa.id AS id_plano,
    pa.nome AS plano_acao,

    cl.id AS id_tarefa,
    cl.titulo AS tarefa,
    cl.prioridade,
    cl.status,
    cl.situacao_prazo,
    cl.data_fim_prevista,
    cl.dias_restantes,

    u.id AS id_responsavel,
    u.nome AS responsavel,

    u.id_empresa

FROM classificacao cl

JOIN pdca.plano_acao pa
    ON pa.id = cl.id_plano_acao

JOIN pdca.ciclo c
    ON c.id = pa.id_ciclo

JOIN usuario_sistema u
    ON u.id = cl.id_responsavel;



/*
VIEW: pdca.vw_desempenho_responsavel
Objetivo principal: Essa view tem como principal objetivo fornecer informações detalhadas sobre o desempenho de cada responsável, como quantidade de ciclos, tarefas e taxa de conclusão. Essa view pode ser utilizada em dashboards.


*/

CREATE OR REPLACE VIEW pdca.vw_desempenho_responsavel AS
WITH tarefas_usuario AS (
    SELECT
        t.id_responsavel,

        COUNT(*) AS total_tarefas,

        COUNT(*) FILTER (
            WHERE t.status = 'CONCLUIDA'
        ) AS concluidas,

        COUNT(*) FILTER (
            WHERE t.status = 'EM_ANDAMENTO'
        ) AS em_andamento,

        COUNT(*) FILTER (
            WHERE t.status = 'BLOQUEADA'
        ) AS bloqueadas,

        COUNT(*) FILTER (
            WHERE t.status = 'ATRASADA'
               OR (
                   t.data_fim_prevista < CURRENT_DATE
                   AND t.status NOT IN ('CONCLUIDA', 'CANCELADA')
               )
        ) AS atrasadas

    FROM pdca.tarefa t
    GROUP BY t.id_responsavel
),

ciclos_usuario AS (
    SELECT
        id_responsavel,
        COUNT(*) AS ciclos_responsavel
    FROM pdca.ciclo
    GROUP BY id_responsavel
)

SELECT
    u.id AS id_usuario,
    u.id_empresa,
    u.nome,

    COALESCE(c.ciclos_responsavel, 0) AS ciclos_responsavel,

    COALESCE(t.total_tarefas, 0) AS total_tarefas,
    COALESCE(t.concluidas, 0) AS tarefas_concluidas,
    COALESCE(t.em_andamento, 0) AS tarefas_em_andamento,
    COALESCE(t.bloqueadas, 0) AS tarefas_bloqueadas,
    COALESCE(t.atrasadas, 0) AS tarefas_atrasadas,

    CASE
        WHEN COALESCE(t.total_tarefas, 0) = 0 THEN 0
        ELSE ROUND(
            t.concluidas::NUMERIC / t.total_tarefas * 100,
            2
        )
    END AS taxa_conclusao

FROM usuario_sistema u

LEFT JOIN tarefas_usuario t
    ON t.id_responsavel = u.id

LEFT JOIN ciclos_usuario c
    ON c.id_responsavel = u.id;



/*
VIEW: pdca.vw_acompanhamento_metas
Objetivo principal: Essa view tem como principal objetivo fornecer informações detalhadas sobre as metas, principalmente os prazos delas. Essa view pode ser utilizada em dashboards, filtradas pelo id_ciclo.


*/

CREATE OR REPLACE VIEW pdca.vw_acompanhamento_metas AS
WITH metas_classificadas AS (
    SELECT
        m.*,

        m.prazo - CURRENT_DATE AS dias_para_prazo,

        CASE
            WHEN m.status = 'ATINGIDA'
                THEN 'ATINGIDA'

            WHEN m.status = 'CANCELADA'
                THEN 'CANCELADA'

            WHEN m.prazo < CURRENT_DATE
                THEN 'ATRASADA'

            WHEN m.prazo <= CURRENT_DATE + 7
                THEN 'PRAZO_PROXIMO'

            ELSE 'NO_PRAZO'
        END AS situacao_prazo

    FROM pdca.meta m
)

SELECT
    m.*,
    c.titulo AS ciclo,
    pa.nome AS plano_acao

FROM metas_classificadas m

JOIN pdca.ciclo c
    ON c.id = m.id_ciclo

JOIN pdca.plano_acao pa
    ON pa.id = m.id_plano_acao;

/*
VIEW: pdca.vw_ranking_problemas
Objetivo principal: Essa view tem como principal objetivo fornecer informações detalhadas sobre o ranking de problemas, considerando a quantidade de avaliadores, posição média e peso médio. Essa view pode ser utilizada em dashboards, filtradas pelo id_ciclo, id_empresa, status do problema, entre outros.    


*/


CREATE OR REPLACE VIEW pdca.vw_ranking_problemas AS
WITH votos AS (
    SELECT
        id_problema,
        COUNT(*) AS qtd_avaliadores,
        AVG(posicao) AS posicao_media,
        AVG(peso_calculado) AS peso_medio
    FROM pdca.priorizacao_problema_usuario
    GROUP BY id_problema
)

SELECT
    p.id,
    p.id_ciclo,
    p.titulo,
    p.status,
    p.peso AS peso_original,
    p.persistente,

    COALESCE(v.qtd_avaliadores, 0) AS qtd_avaliadores,
    ROUND(v.posicao_media, 2) AS posicao_media,
    ROUND(v.peso_medio, 2) AS peso_medio,

    ROUND(
        (
            p.peso * 0.40
            +
            COALESCE(v.peso_medio, 0) * 0.60
        ),
        2
    ) AS score_prioridade

FROM pdca.problema p

LEFT JOIN votos v
    ON v.id_problema = p.id;