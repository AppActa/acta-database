--  ######################
--  CAMADA DE DIMENSÕES
--  ######################

-- 1 (dimensão de usuários)
CREATE OR REPLACE VIEW public.vw_dim_usuario AS
SELECT
    u.id AS id_dim_usuario,
    u.nome AS nome_usuario,
    u.email_login,
    u.tipo_usuario,
    u.status AS status_usuario
FROM public.usuario_sistema u;

-- 2 (dimensão de empresas)
CREATE OR REPLACE VIEW public.vw_dim_empresa AS
SELECT
    e.id AS id_dim_empresa,
    e.nome AS nome_empresa,
    e.setor_empresa,
    e.tamanho_empresa
FROM public.empresa e;

-- 3 (dimensão de ciclos)
CREATE OR REPLACE VIEW pdca.vw_dim_ciclo AS
SELECT
    c.id AS id_dim_ciclo,
    c.id_empresa AS id_dim_empresa,
    c.titulo AS titulo_ciclo,
    c.status AS status_ciclo,
    c.data_inicio,
    c.data_estimada_fim
FROM pdca.ciclo c;

-- 4 (dimensão de planos de ação)
CREATE OR REPLACE VIEW pdca.vw_dim_plano_acao AS
SELECT
    pa.id AS id_dim_plano_acao,
    pa.id_ciclo AS id_dim_ciclo,
    pa.nome AS nome_plano_acao,
    pa.status AS status_plano_acao,
    pa.prioridade AS prioridade_plano_acao
FROM pdca.plano_acao pa;

-- 5 (dimensão de datas)
CREATE OR REPLACE VIEW public.vw_dim_data AS
SELECT
    d::DATE AS id_dim_data,
    EXTRACT(YEAR FROM d)::INT AS ano,
    EXTRACT(MONTH FROM d)::INT AS mes,
    TO_CHAR(d, 'TMMonth') AS nome_mes,
    EXTRACT(QUARTER FROM d)::INT AS trimestre,
    TO_CHAR(d, 'TMDay') AS dia_semana,
    EXTRACT(ISODOW FROM d)::INT AS num_dia_semana,
    EXTRACT(DAY FROM d)::INT AS dia_mes,
    CASE WHEN EXTRACT(ISODOW FROM d) IN (6, 7) THEN TRUE ELSE FALSE END AS eh_fim_semana
FROM generate_series(
    '2022-01-01'::DATE,
    '2030-12-31'::DATE,
    '1 day'::INTERVAL
) AS d;


--  ######################
--  CAMADA DE FATOS
--  ######################

-- 1 (fato de tarefas)
CREATE OR REPLACE VIEW pdca.vw_fato_tarefas AS
SELECT
    t.id AS id_tarefa,
    t.id_responsavel AS id_dim_usuario,
    pa.id AS id_dim_plano_acao,
    pa.id_ciclo AS id_dim_ciclo,
    u.id_empresa AS id_dim_empresa,
    t.data_fim_prevista AS id_dim_data,
    t.status AS status_tarefa,
    t.prioridade AS prioridade_tarefa,
    1 AS qtd_tarefas,

    CASE WHEN t.status = 'CONCLUIDA' THEN 1 ELSE 0 END AS qtd_concluidas,
    CASE WHEN t.status = 'EM_ANDAMENTO' THEN 1 ELSE 0 END AS qtd_em_andamento,
    CASE WHEN t.status = 'BLOQUEADA' THEN 1 ELSE 0 END AS qtd_bloqueadas,
    CASE WHEN t.data_fim_prevista < CURRENT_DATE AND t.status NOT IN ('CONCLUIDA', 'CANCELADA') THEN 1 ELSE 0 END AS qtd_atrasadas,

    CASE WHEN
        t.data_inicio_real IS NOT NULL AND t.data_fim_prevista IS NOT NULL THEN (t.data_fim_prevista - t.data_inicio_real)
        ELSE NULL
    END AS dias_planejados_duracao

FROM pdca.tarefa t
LEFT JOIN pdca.plano_acao pa ON pa.id = t.id_plano_acao
LEFT JOIN pdca.ciclo c ON c.id = pa.id_ciclo
LEFT JOIN public.usuario_sistema u ON u.id = t.id_responsavel;

-- 2 (fato de planos de ação)
CREATE OR REPLACE VIEW pdca.vw_fato_planos_acao AS
SELECT
    pa.id AS id_plano_acao,
    pa.id_ciclo AS id_dim_ciclo,
    c.id_empresa AS id_dim_empresa,
    pa.criado_em::DATE AS id_dim_data,
    1 AS qtd_planos_acao,

    COUNT(t.id) AS total_tarefas,
    SUM(CASE WHEN t.status = 'CONCLUIDA' THEN 1 ELSE 0 END) AS qtd_tarefas_concluidas,
    SUM(CASE WHEN t.status = 'EM_ANDAMENTO' THEN 1 ELSE 0 END) AS qtd_tarefas_em_andamento,
    SUM(CASE WHEN t.status = 'BLOQUEADA' THEN 1 ELSE 0 END) AS qtd_tarefas_bloqueadas,
    SUM(CASE WHEN t.data_fim_prevista < CURRENT_DATE AND t.status NOT IN ('CONCLUIDA', 'CANCELADA') THEN 1 ELSE 0 END) AS qtd_tarefas_atrasadas

FROM pdca.plano_acao pa
JOIN pdca.ciclo c ON c.id = pa.id_ciclo
LEFT JOIN pdca.tarefa t ON t.id_plano_acao = pa.id
GROUP BY pa.id, pa.id_ciclo, c.id_empresa;

-- 3 (fato de treinamentos)
CREATE OR REPLACE VIEW pdca.vw_fato_treinamentos AS
SELECT
    ut.id_usuario AS id_dim_usuario,
    tr.id_ciclo AS id_dim_ciclo,
    u.id_empresa AS id_dim_empresa,
    tr.id AS id_treinamento,
    tr.data_treinamento AS id_dim_data,

    1 AS qtd_inscricoes,
    CASE WHEN ut.status IN ('CONFIRMADO', 'CONCLUIDO') THEN 1 ELSE 0 END AS qtd_realizados,
    CASE WHEN ut.status = 'PENDENTE' THEN 1 ELSE 0 END AS qtd_pendentes,
    CASE WHEN tr.obrigatorio THEN 1 ELSE 0 END AS flag_obrigatorio

FROM pdca.usuario_treinamento ut
JOIN pdca.treinamento tr ON tr.id = ut.id_treinamento
JOIN public.usuario_sistema u ON u.id = ut.id_usuario;

-- 4 (fato de alertas)
CREATE OR REPLACE VIEW pdca.vw_fato_alertas AS
SELECT
    a.id AS id_alerta,
    a.id_usuario_destino AS id_dim_usuario,
    u.id_empresa AS id_dim_empresa,
    pa.id_ciclo AS id_dim_ciclo,
    a.id_tarefa,
    a.enviado_em AS id_dim_data,

    1 AS qtd_alertas,
    CASE WHEN a.lido_em IS NULL THEN 1 ELSE 0 END AS qtd_nao_lidos,
    CASE WHEN a.lido_em IS NOT NULL THEN 1 ELSE 0 END AS qtd_lidos

FROM pdca.alerta_prazo a
JOIN pdca.tarefa t ON t.id = a.id_tarefa
LEFT JOIN pdca.plano_acao pa ON pa.id = t.id_plano_acao
JOIN public.usuario_sistema u ON u.id = a.id_usuario_destino;

-- 5 (fato de logs de auditoria)
CREATE OR REPLACE VIEW auditoria.vw_fato_logs_auditoria AS
SELECT
    la.id_usuario AS id_dim_usuario,
    u.id_empresa AS id_dim_empresa,
    la.data_log::DATE AS id_dim_data,
    la.tabela,

    COUNT(*) AS total_operacoes,
    SUM(CASE WHEN la.operacao = 'INSERT' THEN 1 ELSE 0 END) AS qtd_insercoes,
    SUM(CASE WHEN la.operacao = 'UPDATE' THEN 1 ELSE 0 END) AS qtd_atualizacoes,
    SUM(CASE WHEN la.operacao = 'DELETE' THEN 1 ELSE 0 END) AS qtd_exclusoes

FROM auditoria.log_auditoria la
JOIN public.usuario_sistema u ON u.id = la.id_usuario
GROUP BY la.id_usuario, u.id_empresa, la.data_log::DATE, la.tabela;

--  ######################
--  VIEWS DE DAU
--  ######################

-- 1 (monitoramento DAU por empresa)
CREATE OR REPLACE VIEW auditoria.vw_dau_por_empresa AS
SELECT
    e.id AS id_empresa,
    e.nome AS nome_empresa,
    COALESCE(a.data_atv, a.hora_inicio::DATE) AS data_atv,
    COUNT(DISTINCT a.id_usuario) AS dau,
    SUM(a.qnt_acoes) AS total_acoes_dia,
    COUNT(*) AS total_sessoes_dia

FROM auditoria.atv_usuario_dia a
JOIN public.usuario_sistema u ON u.id = a.id_usuario
JOIN public.empresa e ON e.id = u.id_empresa
GROUP BY e.id, e.nome, COALESCE(a.data_atv, a.hora_inicio::DATE);

-- 2 (monitoramento DAU por colaborador)
CREATE OR REPLACE VIEW auditoria.vw_dau_detalhado_usuario AS
SELECT
    COALESCE(a.data_atv, a.hora_inicio::DATE) AS data_atv,
    u.id AS id_usuario,
    u.nome AS nome_usuario,
    u.email_login,
    u.tipo_usuario,
    e.id AS id_empresa,
    e.nome AS nome_empresa,
    SUM(a.qnt_acoes) AS total_acoes,
    MIN(a.hora_inicio) AS primeiro_acesso,
    MAX(a.hora_fim) AS ultimo_acesso
FROM auditoria.atv_usuario_dia a
JOIN public.usuario_sistema u ON u.id = a.id_usuario
JOIN public.empresa e ON e.id = u.id_empresa
GROUP BY COALESCE(a.data_atv, a.hora_inicio::DATE), u.id, u.nome, u.email_login, u.tipo_usuario, e.id, e.nome;

-- 3 (monitoramento de interacao dos ciclos)
CREATE OR REPLACE VIEW auditoria.vw_dau_interacao_ciclos AS
SELECT
    lau.acessado_em::DATE AS data_acesso,
    e.id AS id_empresa,
    e.nome AS nome_empresa,
    COUNT(DISTINCT lau.id_usuario) AS dau_ciclos,
    COUNT(*) AS total_interacoes_ciclo
FROM auditoria.log_acesso_usuario lau
JOIN public.usuario_sistema u ON u.id = lau.id_usuario
JOIN public.empresa e ON e.id = u.id_empresa
WHERE lau.id_ciclo IS NOT NULL
GROUP BY lau.acessado_em::DATE, e.id, e.nome;

-- 4 (monitoramento de interacao dos ciclos por usuario)
CREATE OR REPLACE VIEW auditoria.vw_dau_interacao_ciclos_por_usuario AS
SELECT
    lau.acessado_em::DATE AS data_acesso,
    e.id AS id_empresa,
    e.nome AS nome_empresa,
    u.id AS id_usuario,
    u.nome AS nome_usuario,
    COUNT(*) AS total_interacoes_usuario
FROM auditoria.log_acesso_usuario lau
JOIN public.usuario_sistema u ON u.id = lau.id_usuario
JOIN public.empresa e ON e.id = u.id_empresa
WHERE lau.id_ciclo IS NOT NULL
GROUP BY lau.acessado_em::DATE, e.id, e.nome, u.id, u.nome;


--  ######################
--  VIEWS SIMPLES
--  ######################

-- 1 (associa as causas raiz com seus respectivos problemas e ciclos de origem)
CREATE OR REPLACE VIEW pdca.vw_mapeamento_causa_problema AS
SELECT
    cr.id AS id_causa,
    cr.descricao AS descricao_causa,
    cr.principal AS eh_causa_principal,
    cr.criado_em AS causa_criada_em,
    p.id AS id_problema,
    p.titulo AS titulo_problema,
    p.status AS status_problema,
    p.peso AS peso_problema,
    c.id AS id_ciclo,
    c.titulo AS titulo_ciclo,
    c.id_empresa
FROM pdca.causa_raiz cr
JOIN pdca.problema p ON p.id = cr.id_problema
JOIN pdca.ciclo c ON c.id = p.id_ciclo;

-- 2 (tarefas que estão registradas com bloqueio, traz o responsável e a empresa)
CREATE OR REPLACE VIEW pdca.vw_tarefas_bloqueadas AS
SELECT
    t.id AS id_tarefa,
    t.titulo AS titulo_tarefa,
    t.prioridade,
    t.data_fim_prevista,
    c.id AS id_ciclo,
    c.titulo AS titulo_ciclo,
    pa.nome AS nome_plano_acao,
    u.id AS id_responsavel,
    u.nome AS nome_responsavel,
    u.email_login AS email_responsavel,
    e.id AS id_empresa,
    e.nome AS nome_empresa
FROM pdca.tarefa t
JOIN pdca.plano_acao pa ON pa.id = t.id_plano_acao
JOIN pdca.ciclo c ON c.id = pa.id_ciclo
JOIN public.usuario_sistema u ON u.id = t.id_responsavel
JOIN public.empresa e ON e.id = u.id_empresa
WHERE t.status = 'BLOQUEADA';

-- 3 (traz os treinamentos cadastrados no sistema com o ciclo relacionado e o responsável)
CREATE OR REPLACE VIEW pdca.vw_agenda_treinamentos AS
SELECT
    tr.id AS id_treinamento,
    tr.titulo AS titulo_treinamento,
    tr.data_treinamento,
    tr.obrigatorio,
    c.id AS id_ciclo,
    c.titulo AS titulo_ciclo,
    u.nome AS nome_responsavel,
    u.email_login AS email_responsavel
FROM pdca.treinamento tr
JOIN pdca.ciclo c ON c.id = tr.id_ciclo
JOIN public.usuario_sistema u ON u.id = tr.id_responsavel;

-- 4 (alertas não lidos)
CREATE OR REPLACE VIEW pdca.vw_alertas_nao_lidos AS
SELECT
    a.id AS id_alerta,
    a.id_tarefa,
    a.id_usuario_destino,
    u.nome AS usuario_nome,
    a.mensagem,
    a.enviado_em,
    t.titulo AS tarefa_titulo
FROM pdca.alerta_prazo a
JOIN public.usuario_sistema u ON u.id = a.id_usuario_destino
JOIN pdca.tarefa t ON t.id = a.id_tarefa
WHERE a.lido_em IS NULL;

-- 5 (treinamentos pendentes por colaborador)
CREATE OR REPLACE VIEW pdca.vw_treinamentos_pendentes AS
SELECT
    ut.id_usuario,
    u.nome AS usuario_nome,
    ut.id_treinamento,
    tr.titulo AS treinamento_titulo,
    tr.data_treinamento,
    ut.status AS status_treinamento,
    tr.obrigatorio
FROM pdca.usuario_treinamento ut
JOIN public.usuario_sistema u ON u.id = ut.id_usuario
JOIN pdca.treinamento tr ON tr.id = ut.id_treinamento
WHERE ut.status IN ('PENDENTE', 'CONFIRMADO');

-- 6 (painel de auditoria geral)
CREATE OR REPLACE VIEW auditoria.vw_painel_auditoria AS
SELECT
    la.id,
    la.id_usuario,
    u.nome AS usuario_nome,
    la.tabela,
    la.operacao,
    la.dados_antes,
    la.dados_depois,
    la.data_log
FROM auditoria.log_auditoria la
LEFT JOIN public.usuario_sistema u ON u.id = la.id_usuario;

-- 7 (painel de auditoria de status)
CREATE OR REPLACE VIEW auditoria.vw_log_status AS
SELECT
    ls.id,
    ls.id_usuario,
    u.nome AS usuario_nome,
    u.id_empresa,
    ls.tabela,
    ls.status_anterior,
    ls.status_atual,
    ls.data_log
FROM auditoria.log_status ls
LEFT JOIN public.usuario_sistema u ON u.id = ls.id_usuario;

-- 8 (painel de auditoria de tarefa)
CREATE OR REPLACE VIEW auditoria.vw_log_tarefas AS
SELECT
    lt.id,
    lt.id_tarefa,
    t.titulo AS tarefa_titulo,
    lt.id_usuario,
    u.nome AS usuario_nome,
    u.id_empresa,
    lt.operacao,
    lt.dados_antes,
    lt.dados_depois,
    lt.data_log
FROM auditoria.log_tarefa lt
LEFT JOIN pdca.tarefa t ON t.id = lt.id_tarefa
LEFT JOIN public.usuario_sistema u ON u.id = lt.id_usuario;

-- 9 (painel de auditoria de colaborador)
CREATE OR REPLACE VIEW auditoria.vw_log_colaboradores AS
SELECT
    lc.id,
    lc.id_colaborador,
    u_colab.nome AS colaborador_nome,
    lc.id_usuario AS id_usuario_executor,
    u_exec.nome AS executor_nome,
    u_exec.id_empresa,
    lc.operacao,
    lc.dados_antes,
    lc.dados_depois,
    lc.data_log
FROM auditoria.log_colaborador lc
LEFT JOIN public.usuario_sistema u_colab ON u_colab.id = lc.id_colaborador
LEFT JOIN public.usuario_sistema u_exec ON u_exec.id = lc.id_usuario;

-- 10 (monitoramento de convites)
CREATE OR REPLACE VIEW public.vw_monitoramento_convites AS
SELECT
    c.id AS id_convite,
    c.email_destino,
    c.status AS status_convite,
    c.expira_em,
    c.usado_em,
    c.criado_em,
    us.id AS id_usuario_criador,
    us.nome AS nome_usuario_criador,
    e.id AS id_empresa,
    e.nome AS nome_empresa,
    CASE
        WHEN c.status = 'PENDENTE' AND c.expira_em < NOW() THEN TRUE
        ELSE FALSE
    END AS convite_expirado
FROM public.convite_usuario c
LEFT JOIN public.usuario_sistema us ON us.id = c.criado_por
LEFT JOIN public.empresa e ON e.id = us.id_empresa;

-- 11 (monitoramento dos anexos por ciclo)
CREATE OR REPLACE VIEW pdca.vw_monitoramento_anexos AS
SELECT
    a.id AS id_anexo,
    a.nome_arquivo,
    a.tipo_arquivo,
    a.tamanho_arquivo,
    a.categoria,
    a.status AS status_anexo,
    a.criado_em,
    c.id AS id_ciclo,
    c.titulo AS titulo_ciclo,
    u.nome AS criado_por_nome,
    e.id AS id_empresa,
    e.nome AS nome_empresa
FROM pdca.anexo a
JOIN public.empresa e ON e.id = a.id_empresa
JOIN pdca.ciclo c ON c.id = a.id_ciclo
LEFT JOIN public.usuario_sistema u ON u.id = a.criado_por;

-- 12 (monitoramento dos papéis dos usuários em cada ciclo)
CREATE OR REPLACE VIEW pdca.vw_monitoramento_papeis_ciclo AS
SELECT
    uc.id_ciclo,
    c.titulo AS titulo_ciclo,
    c.status AS status_ciclo,
    uc.id_usuario,
    u.nome AS nome_usuario,
    u.email_login,
    uc.papel_ciclo,
    e.id AS id_empresa,
    e.nome AS nome_empresa
FROM pdca.usuario_ciclo uc
JOIN pdca.ciclo c ON c.id = uc.id_ciclo
JOIN public.usuario_sistema u ON u.id = uc.id_usuario
JOIN public.empresa e ON e.id = u.id_empresa;