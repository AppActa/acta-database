/*
NOVAS VIEWS COM CTEs E WINDOW FUNCTIONS

Estas views nao utilizam nenhuma das views criadas anteriormente.
Todas as analises partem diretamente das tabelas-base do banco.
Banco: PostgreSQL
*/


/* =====================================================================
VIEW: pdca.vw_aderencia_prazo_ciclo

Objetivo principal:
Analisar se os ciclos estao cumprindo o prazo planejado, comparar cada
ciclo com o ciclo anterior da mesma empresa e calcular a tendencia dos
ultimos tres ciclos.

Window functions utilizadas:
- ROW_NUMBER
- LAG
- AVG OVER com frame ROWS
- RANK




===================================================================== */
CREATE OR REPLACE VIEW pdca.vw_aderencia_prazo_ciclo AS
WITH ciclos_calculados AS (
    SELECT
        c.id AS id_ciclo,
        c.id_empresa,
        e.nome AS empresa,
        c.id_responsavel,
        u.nome AS responsavel,
        c.titulo,
        c.status,
        c.data_inicio,
        c.data_estimada_fim,
        c.data_fim_real,

        c.data_estimada_fim - c.data_inicio AS dias_planejados,

        COALESCE(c.data_fim_real, CURRENT_DATE) - c.data_inicio
            AS dias_reais_ou_decorridos,

        COALESCE(c.data_fim_real, CURRENT_DATE) - c.data_estimada_fim
            AS desvio_prazo_dias,

        CASE
            WHEN c.data_fim_real IS NOT NULL
                 AND c.data_fim_real <= c.data_estimada_fim
                THEN 'CONCLUIDO_NO_PRAZO'
            WHEN c.data_fim_real IS NOT NULL
                 AND c.data_fim_real > c.data_estimada_fim
                THEN 'CONCLUIDO_COM_ATRASO'
            WHEN c.data_fim_real IS NULL
                 AND CURRENT_DATE > c.data_estimada_fim
                THEN 'EM_ATRASO'
            ELSE 'DENTRO_DO_PRAZO'
        END AS situacao_prazo

    FROM pdca.ciclo c
    JOIN empresa e
        ON e.id = c.id_empresa
    JOIN usuario_sistema u
        ON u.id = c.id_responsavel
    WHERE c.status <> 'CANCELADO'
),
comparativo AS (
    SELECT
        cc.*,

        ROW_NUMBER() OVER (
            PARTITION BY cc.id_empresa
            ORDER BY cc.data_inicio, cc.id_ciclo
        ) AS sequencia_ciclo_empresa,

        LAG(cc.desvio_prazo_dias) OVER (
            PARTITION BY cc.id_empresa
            ORDER BY cc.data_inicio, cc.id_ciclo
        ) AS desvio_ciclo_anterior_dias,

        AVG(cc.desvio_prazo_dias) OVER (
            PARTITION BY cc.id_empresa
            ORDER BY cc.data_inicio, cc.id_ciclo
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS media_desvio_ultimos_3_ciclos,

        RANK() OVER (
            PARTITION BY cc.id_empresa
            ORDER BY cc.desvio_prazo_dias, cc.id_ciclo
        ) AS ranking_aderencia_prazo

    FROM ciclos_calculados cc
)
SELECT
    cp.*,
    cp.desvio_prazo_dias - cp.desvio_ciclo_anterior_dias
        AS variacao_desvio_ciclo_anterior_dias,
    ROUND(cp.media_desvio_ultimos_3_ciclos, 2)
        AS media_desvio_ultimos_3_ciclos_arredondada
FROM comparativo cp;


/* =====================================================================
VIEW: pdca.vw_engajamento_treinamento

Objetivo principal:
Avaliar a adesao aos treinamentos de cada ciclo, comparar a taxa de
conclusao entre treinamentos e identificar os de menor engajamento.

Window functions utilizadas:
- RANK
- AVG OVER
- SUM OVER
===================================================================== */
CREATE OR REPLACE VIEW pdca.vw_engajamento_treinamento AS
WITH resumo_treinamento AS (
    SELECT
        c.id_empresa,
        e.nome AS empresa,
        c.id AS id_ciclo,
        c.titulo AS ciclo,
        tr.id AS id_treinamento,
        tr.titulo AS treinamento,
        tr.data_treinamento,
        tr.obrigatorio AS treinamento_obrigatorio,
        tr.id_responsavel,
        ur.nome AS responsavel,

        COUNT(ut.id_usuario) AS total_convocados,

        COUNT(ut.id_usuario) FILTER (
            WHERE ut.obrigatorio = TRUE
        ) AS total_obrigatorios,

        COUNT(ut.id_usuario) FILTER (
            WHERE ut.status = 'CONCLUIDO'
        ) AS total_concluidos,

        COUNT(ut.id_usuario) FILTER (
            WHERE ut.status = 'PENDENTE'
        ) AS total_pendentes,

        COUNT(ut.id_usuario) FILTER (
            WHERE ut.status = 'DISPENSADO'
        ) AS total_dispensados

    FROM pdca.treinamento tr
    JOIN pdca.ciclo c
        ON c.id = tr.id_ciclo
    JOIN empresa e
        ON e.id = c.id_empresa
    JOIN usuario_sistema ur
        ON ur.id = tr.id_responsavel
    LEFT JOIN pdca.usuario_treinamento ut
        ON ut.id_treinamento = tr.id
    GROUP BY
        c.id_empresa,
        e.nome,
        c.id,
        c.titulo,
        tr.id,
        tr.titulo,
        tr.data_treinamento,
        tr.obrigatorio,
        tr.id_responsavel,
        ur.nome
),
taxas AS (
    SELECT
        rt.*,
        CASE
            WHEN rt.total_convocados = 0 THEN 0::NUMERIC
            ELSE ROUND(
                rt.total_concluidos::NUMERIC
                    / rt.total_convocados * 100,
                2
            )
        END AS taxa_conclusao_pct
    FROM resumo_treinamento rt
),
comparativo AS (
    SELECT
        tx.*,

        RANK() OVER (
            PARTITION BY tx.id_ciclo
            ORDER BY
                tx.taxa_conclusao_pct DESC,
                tx.total_convocados DESC,
                tx.id_treinamento
        ) AS ranking_engajamento_no_ciclo,

        AVG(tx.taxa_conclusao_pct) OVER (
            PARTITION BY tx.id_ciclo
        ) AS media_conclusao_treinamentos_ciclo,

        SUM(tx.total_pendentes) OVER (
            PARTITION BY tx.id_ciclo
        ) AS total_pendencias_treinamento_ciclo

    FROM taxas tx
)
SELECT
    cp.*,
    ROUND(cp.media_conclusao_treinamentos_ciclo, 2)
        AS media_conclusao_ciclo_arredondada,
    ROUND(
        cp.taxa_conclusao_pct - cp.media_conclusao_treinamentos_ciclo,
        2
    ) AS diferenca_para_media_ciclo_pp
FROM comparativo cp;


/* =====================================================================
VIEW: auditoria.vw_evolucao_atividade_usuario

Objetivo principal:
Analisar a evolucao diaria de uso do sistema por usuario, comparando a
atividade com o dia anterior e calculando media movel de sete dias.

Window functions utilizadas:
- LAG
- AVG OVER com frame RANGE
- SUM OVER com acumulado
- DENSE_RANK
===================================================================== */
CREATE OR REPLACE VIEW auditoria.vw_evolucao_atividade_usuario AS
WITH atividade_diaria AS (
    SELECT
        a.id_usuario,
        COALESCE(a.data_atv, a.hora_inicio::DATE) AS data_atividade,
        SUM(a.qnt_acoes) AS total_acoes_dia,
        COUNT(*) AS total_sessoes_dia,
        ROUND(
            SUM(
                EXTRACT(EPOCH FROM (a.hora_fim - a.hora_inicio)) / 60
            ),
            2
        ) AS minutos_atividade_dia
    FROM auditoria.atv_usuario_dia a
    WHERE a.id_usuario IS NOT NULL
    GROUP BY
        a.id_usuario,
        COALESCE(a.data_atv, a.hora_inicio::DATE)
),
evolucao AS (
    SELECT
        ad.*,

        LAG(ad.data_atividade) OVER (
            PARTITION BY ad.id_usuario
            ORDER BY ad.data_atividade
        ) AS data_atividade_anterior,

        LAG(ad.total_acoes_dia) OVER (
            PARTITION BY ad.id_usuario
            ORDER BY ad.data_atividade
        ) AS total_acoes_dia_anterior,

        AVG(ad.total_acoes_dia) OVER (
            PARTITION BY ad.id_usuario
            ORDER BY ad.data_atividade
            RANGE BETWEEN INTERVAL '6 DAYS' PRECEDING AND CURRENT ROW
        ) AS media_movel_acoes_7_dias,

        SUM(ad.total_acoes_dia) OVER (
            PARTITION BY ad.id_usuario
            ORDER BY ad.data_atividade
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS total_acoes_acumuladas,

        DENSE_RANK() OVER (
            PARTITION BY ad.id_usuario
            ORDER BY ad.total_acoes_dia DESC
        ) AS ranking_dia_mais_ativo

    FROM atividade_diaria ad
)
SELECT
    u.id_empresa,
    e.empresa,
    u.id AS id_usuario,
    u.nome AS usuario,
    ev.data_atividade,
    ev.total_acoes_dia,
    ev.total_sessoes_dia,
    ev.minutos_atividade_dia,
    ev.data_atividade_anterior,
    ev.data_atividade - ev.data_atividade_anterior
        AS dias_desde_ultima_atividade,
    ev.total_acoes_dia_anterior,
    ev.total_acoes_dia - ev.total_acoes_dia_anterior
        AS variacao_acoes_dia_anterior,
    ROUND(ev.media_movel_acoes_7_dias, 2)
        AS media_movel_acoes_7_dias,
    ev.total_acoes_acumuladas,
    ev.ranking_dia_mais_ativo
FROM evolucao ev
JOIN usuario_sistema u
    ON u.id = ev.id_usuario
JOIN (
    SELECT id, nome AS empresa
    FROM empresa
) e
    ON e.id = u.id_empresa;


/* =====================================================================
VIEW: pdca.vw_historico_verificacao_ciclo

Objetivo principal:
Exibir a sequencia das verificacoes de resultado de cada ciclo, mostrar
a mudanca de status e identificar a verificacao mais recente.

Window functions utilizadas:
- ROW_NUMBER
- LAG
- COUNT OVER
===================================================================== */
CREATE OR REPLACE VIEW pdca.vw_historico_verificacao_ciclo AS
WITH sequencia AS (
    SELECT
        c.id_empresa,
        c.id AS id_ciclo,
        c.titulo AS ciclo,
        vr.id AS id_verificacao,
        vr.status,
        vr.resumo,
        vr.observacao,
        vr.criado_por,
        u.nome AS criado_por_nome,
        vr.criado_em,

        ROW_NUMBER() OVER (
            PARTITION BY vr.id_ciclo
            ORDER BY vr.criado_em, vr.id
        ) AS numero_verificacao,

        ROW_NUMBER() OVER (
            PARTITION BY vr.id_ciclo
            ORDER BY vr.criado_em DESC, vr.id DESC
        ) AS ordem_mais_recente,

        COUNT(*) OVER (
            PARTITION BY vr.id_ciclo
        ) AS total_verificacoes_ciclo,

        LAG(vr.status) OVER (
            PARTITION BY vr.id_ciclo
            ORDER BY vr.criado_em, vr.id
        ) AS status_verificacao_anterior,

        LAG(vr.criado_em) OVER (
            PARTITION BY vr.id_ciclo
            ORDER BY vr.criado_em, vr.id
        ) AS data_verificacao_anterior

    FROM pdca.verificacao_resultado vr
    JOIN pdca.ciclo c
        ON c.id = vr.id_ciclo
    JOIN usuario_sistema u
        ON u.id = vr.criado_por
)
SELECT
    sq.*,
    sq.criado_em - sq.data_verificacao_anterior
        AS tempo_desde_verificacao_anterior,
    (sq.ordem_mais_recente = 1) AS verificacao_atual,
    CASE
        WHEN sq.status_verificacao_anterior IS NULL
            THEN 'PRIMEIRA_VERIFICACAO'
        WHEN sq.status = sq.status_verx ificacao_anterior
            THEN 'STATUS_MANTIDO'
        ELSE 'STATUS_ALTERADO'
    END AS tipo_movimentacao
FROM sequencia sq;

