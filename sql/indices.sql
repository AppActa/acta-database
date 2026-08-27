-- Ciclo por Empresa
EXPLAIN ANALYZE SELECT * FROM pdca.ciclo WHERE id_empresa = 1;
CREATE INDEX IF NOT EXISTS idx_ciclo_empresa ON pdca.ciclo (id_empresa);
-- ANTES: execution time -> 39.085
-- DEPOIS: execution time -> 0.604

-- Ciclo por Responsável
EXPLAIN ANALYZE SELECT * FROM pdca.ciclo WHERE id_responsavel = 1;
CREATE INDEX IF NOT EXISTS idx_ciclo_responsavel ON pdca.ciclo (id_responsavel);
-- ANTES: execution time -> 0.251
-- DEPOIS: execution time -> 0.028

-- Ciclo por Status
EXPLAIN ANALYZE SELECT * FROM pdca.ciclo WHERE status = 'EXECUCAO';
CREATE INDEX IF NOT EXISTS idx_ciclo_status ON pdca.ciclo (status);
-- ANTES: execution time -> 0.433
-- DEPOIS: execution time -> 0.031

-- Meta por Ciclo
EXPLAIN ANALYZE SELECT * FROM pdca.meta WHERE id_ciclo = 1;
CREATE INDEX IF NOT EXISTS idx_meta_ciclo ON pdca.meta (id_ciclo);
-- ANTES: execution time -> 0.426
-- DEPOIS: execution time -> 0.046

-- Meta por Status
EXPLAIN ANALYZE SELECT * FROM pdca.meta WHERE status = 'EM_ANDAMENTO';
CREATE INDEX IF NOT EXISTS idx_meta_status ON pdca.meta (status);
-- ANTES: execution time -> 89.230
-- DEPOIS: execution time -> 0.078

-- Meta por Prioridade
EXPLAIN ANALYZE SELECT * FROM pdca.meta WHERE prioridade = 'ALTA';
CREATE INDEX IF NOT EXISTS idx_meta_prioridade ON pdca.meta (prioridade);
-- ANTES: execution time -> 1.451
-- DEPOIS: execution time -> 0.043

-- Meta por Área
EXPLAIN ANALYZE SELECT * FROM pdca.meta WHERE area = 'Operações';
CREATE INDEX IF NOT EXISTS idx_meta_area ON pdca.meta (area);
-- ANTES: execution time -> 329.462
-- DEPOIS: execution time -> 0.027

-- Meta por Categoria
EXPLAIN ANALYZE SELECT * FROM pdca.meta WHERE categoria = 'Qualidade';
CREATE INDEX IF NOT EXISTS idx_meta_categoria ON pdca.meta (categoria);
-- ANTES: execution time -> 0.468
-- DEPOIS: execution time -> 0.036

-- Meta por Prazo
EXPLAIN ANALYZE SELECT * FROM pdca.meta WHERE prazo <= CURRENT_DATE;
CREATE INDEX IF NOT EXISTS idx_meta_prazo ON pdca.meta (prazo);
-- ANTES: execution time -> 0.327
-- DEPOIS: execution time -> 0.033

-- Plano por Ciclo
EXPLAIN ANALYZE SELECT * FROM pdca.plano_acao WHERE id_ciclo = 1;
CREATE INDEX IF NOT EXISTS idx_plano_ciclo ON pdca.plano_acao (id_ciclo);
-- ANTES: execution time -> 0.388
-- DEPOIS: execution time -> 0.050

-- Plano por Prioridade
EXPLAIN ANALYZE SELECT * FROM pdca.plano_acao WHERE prioridade = 'CRITICA';
CREATE INDEX IF NOT EXISTS idx_plano_prioridade ON pdca.plano_acao (prioridade);
-- ANTES: execution time -> 0.359
-- DEPOIS: execution time -> 0.026

-- Plano por Status
EXPLAIN ANALYZE SELECT * FROM pdca.plano_acao WHERE status = 'EM_EXECUCAO';
CREATE INDEX IF NOT EXISTS idx_plano_status ON pdca.plano_acao (status);
-- ANTES: execution time -> 0.344
-- DEPOIS: execution time -> 0.034

-- Plano pelo Criador
EXPLAIN ANALYZE SELECT * FROM pdca.plano_acao WHERE criado_por = 1;
CREATE INDEX IF NOT EXISTS idx_plano_criado_por ON pdca.plano_acao (criado_por);
-- ANTES: execution time -> 0.390
-- DEPOIS: execution time -> 0.034

-- Treinamento por Ciclo
EXPLAIN ANALYZE SELECT * FROM pdca.treinamento WHERE id_ciclo = 1;
CREATE INDEX IF NOT EXISTS idx_treinamento_ciclo ON pdca.treinamento (id_ciclo);
-- ANTES: execution time -> 0.218
-- DEPOIS: execution time -> 0.028

-- Treinamento por Responsável
EXPLAIN ANALYZE SELECT * FROM pdca.treinamento WHERE id_responsavel = 1;
CREATE INDEX IF NOT EXISTS idx_treinamento_responsavel ON pdca.treinamento (id_responsavel);
-- ANTES: execution time -> 0.293
-- DEPOIS: execution time -> 0.030

-- Treinamento por Obrigatoriedade
EXPLAIN ANALYZE SELECT * FROM pdca.treinamento WHERE obrigatorio = TRUE;
CREATE INDEX IF NOT EXISTS idx_treinamento_obrigatorio ON pdca.treinamento (obrigatorio);
-- ANTES: execution time -> 0.332
-- DEPOIS: execution time -> 0.035

-- Verificação por Ciclo
EXPLAIN ANALYZE SELECT * FROM pdca.verificacao_resultado WHERE id_ciclo = 1;
CREATE INDEX IF NOT EXISTS idx_verificacao_ciclo ON pdca.verificacao_resultado (id_ciclo);
-- ANTES: execution time -> 17.595
-- DEPOIS: execution time -> 0.036

-- Verificação pelo Criador
EXPLAIN ANALYZE SELECT * FROM pdca.verificacao_resultado WHERE criado_por = 1;
CREATE INDEX IF NOT EXISTS idx_verificacao_criado_por ON pdca.verificacao_resultado (criado_por);
-- ANTES: execution time -> 81.822
-- DEPOIS: execution time -> 0.037

-- Verificação por Status
EXPLAIN ANALYZE SELECT * FROM pdca.verificacao_resultado WHERE status = 'APROVADO';
CREATE INDEX IF NOT EXISTS idx_verificacao_status ON pdca.verificacao_resultado (status);
-- ANTES: execution time -> 118.682
-- DEPOIS: execution time -> 0.037

-- Causa Raiz por Ciclo
EXPLAIN ANALYZE SELECT * FROM pdca.causa_raiz WHERE id_ciclo = 1;
CREATE INDEX IF NOT EXISTS idx_causa_raiz_ciclo ON pdca.causa_raiz (id_ciclo);
-- ANTES: execution time -> 558.289
-- DEPOIS: execution time -> 0.049

-- Causa Raiz por Plano
EXPLAIN ANALYZE SELECT * FROM pdca.causa_raiz WHERE id_plano_acao = 1;
CREATE INDEX IF NOT EXISTS idx_causa_raiz_plano ON pdca.causa_raiz (id_plano_acao);
-- ANTES: execution time -> 5.176
-- DEPOIS: execution time -> 0.048

-- Causa Raiz por Problema
EXPLAIN ANALYZE SELECT * FROM pdca.causa_raiz WHERE id_problema = 1;
CREATE INDEX IF NOT EXISTS idx_causa_raiz_problema ON pdca.causa_raiz (id_problema);
-- ANTES: execution time -> 0.358
-- DEPOIS: execution time -> 0.030

-- Tarefa por Plano
EXPLAIN ANALYZE SELECT * FROM pdca.tarefa WHERE id_plano_acao = 1;
CREATE INDEX IF NOT EXISTS idx_tarefa_plano ON pdca.tarefa (id_plano_acao);
-- ANTES: execution time -> 0.545
-- DEPOIS: execution time -> 0.075


-- Tarefa por Responsável
EXPLAIN ANALYZE SELECT * FROM pdca.tarefa WHERE id_responsavel = 1;
CREATE INDEX IF NOT EXISTS idx_tarefa_responsavel ON pdca.tarefa (id_responsavel);
-- ANTES: execution time -> 0.320
-- DEPOIS: execution time -> 0.067

-- Tarefa por Status
EXPLAIN ANALYZE SELECT * FROM pdca.tarefa WHERE status = 'EM_ANDAMENTO';
CREATE INDEX IF NOT EXISTS idx_tarefa_status ON pdca.tarefa (status);
-- ANTES: execution time -> 0.419
-- DEPOIS: execution time -> 0.049

-- Problema por Ciclo
EXPLAIN ANALYZE SELECT * FROM pdca.problema WHERE id_ciclo = 1;
CREATE INDEX IF NOT EXISTS idx_problema_ciclo ON pdca.problema (id_ciclo);
-- ANTES: execution time -> 93.369
-- DEPOIS: execution time -> 0.032

-- Problema pelo Criador
EXPLAIN ANALYZE SELECT * FROM pdca.problema WHERE criado_por = 1;
CREATE INDEX IF NOT EXISTS idx_problema_criado_por ON pdca.problema (criado_por);
-- ANTES: execution time -> 0.413
-- DEPOIS: execution time -> 0.028

-- Problema por Peso
EXPLAIN ANALYZE SELECT * FROM pdca.problema WHERE peso >= 0.50;
CREATE INDEX IF NOT EXISTS idx_problema_peso ON pdca.problema (peso);
-- ANTES: execution time -> 0.544
-- DEPOIS: execution time -> 0.063

-- Problema por Status
EXPLAIN ANALYZE SELECT * FROM pdca.problema WHERE status = 'PRIORIZADO';
CREATE INDEX IF NOT EXISTS idx_problema_status ON pdca.problema (status);
-- ANTES: execution time -> 0.401
-- DEPOIS: execution time -> 0.081

-- Alerta Prazo por Tarefa
EXPLAIN ANALYZE SELECT * FROM pdca.alerta_prazo WHERE id_tarefa = 1;
CREATE INDEX IF NOT EXISTS idx_alerta_tarefa ON pdca.alerta_prazo (id_tarefa);
-- ANTES: execution time -> 0.681
-- DEPOIS: execution time -> 0.027

-- Alerta Prazo por Usuário
EXPLAIN ANALYZE SELECT * FROM pdca.alerta_prazo WHERE id_usuario_destino = 1;
CREATE INDEX IF NOT EXISTS idx_alerta_usuario ON pdca.alerta_prazo (id_usuario_destino);
-- ANTES: execution time -> 0.329
-- DEPOIS: execution time -> 0.025

-- Colaborador por Empresa
EXPLAIN ANALYZE SELECT * FROM colaborador WHERE id_empresa = 1;
CREATE INDEX IF NOT EXISTS idx_colaborador_empresa ON colaborador (id_empresa);
-- ANTES: execution time -> 96.731
-- DEPOIS: execution time -> 0.162

-- Colaborador por Usuário
EXPLAIN ANALYZE SELECT * FROM colaborador WHERE id_usuario = 1;
CREATE INDEX IF NOT EXISTS idx_colaborador_usuario ON colaborador (id_usuario);
-- ANTES: execution time -> 0.109
-- DEPOIS: execution time -> 0.033

-- Colaborador por Cargo
EXPLAIN ANALYZE SELECT * FROM colaborador WHERE cargo = 'Gerente';
CREATE INDEX IF NOT EXISTS idx_colaborador_cargo ON colaborador (cargo);
-- ANTES: execution time -> 116.626
-- DEPOIS: execution time -> 0.029

-- Colaborador por Área
EXPLAIN ANALYZE SELECT * FROM colaborador WHERE area = 'Operações';
CREATE INDEX IF NOT EXISTS idx_colaborador_area ON colaborador (area);
-- ANTES: execution time -> 62.279
-- DEPOIS: execution time -> 0.185

-- Colaborador por Status
EXPLAIN ANALYZE SELECT * FROM colaborador WHERE status = 'ATIVO';
CREATE INDEX IF NOT EXISTS idx_colaborador_status ON colaborador (status);
-- ANTES: execution time -> 0.460
-- DEPOIS: execution time -> 0.033

-- Usuário por Empresa
EXPLAIN ANALYZE SELECT * FROM usuario_sistema WHERE id_empresa = 1;
CREATE INDEX IF NOT EXISTS idx_usuario_empresa ON usuario_sistema (id_empresa);
-- ANTES: execution time -> 0.863
-- DEPOIS: execution time -> 0.041

-- Usuário por Status
EXPLAIN ANALYZE SELECT * FROM usuario_sistema WHERE status = 'ATIVO';
CREATE INDEX IF NOT EXISTS idx_usuario_status ON usuario_sistema (status);
-- ANTES: execution time -> 0.719
-- DEPOIS: execution time -> 0.039

-- Usuário por Tipo
EXPLAIN ANALYZE SELECT * FROM usuario_sistema WHERE tipo_usuario = 'ADMIN';
CREATE INDEX IF NOT EXISTS idx_usuario_tipo ON usuario_sistema (tipo_usuario);
-- ANTES: execution time -> 0.479
-- DEPOIS: execution time -> 0.031

-- Empresa por Status
EXPLAIN ANALYZE SELECT * FROM empresa WHERE status = 'ATIVO';
CREATE INDEX IF NOT EXISTS idx_empresa_status ON empresa (status);
-- ANTES: execution time -> 70.854
-- DEPOIS: execution time -> 0.030

-- Empresa por Setor
EXPLAIN ANALYZE SELECT * FROM empresa WHERE setor_empresa = 'Alimentício';
CREATE INDEX IF NOT EXISTS idx_empresa_setor ON empresa (setor_empresa);
-- ANTES: execution time -> 0.434
-- DEPOIS: execution time -> 0.036

-- Endereço_empresa por Empresa
EXPLAIN ANALYZE SELECT * FROM endereco_empresa WHERE id_empresa = 1;
CREATE INDEX IF NOT EXISTS idx_endereco_empresa ON endereco_empresa (id_empresa);
-- ANTES: execution time -> 98.828
-- DEPOIS: execution time -> 0.090

-- Telefone_empresa por Empresa
EXPLAIN ANALYZE SELECT * FROM telefone_empresa WHERE id_empresa = 1;
CREATE INDEX IF NOT EXISTS idx_telefone_empresa ON telefone_empresa (id_empresa);
-- ANTES: execution time -> 1.567
-- DEPOIS: execution time -> 0.038

-- Email_empresa por Empresa
EXPLAIN ANALYZE SELECT * FROM email_empresa WHERE id_empresa = 1;
CREATE INDEX IF NOT EXISTS idx_email_empresa ON email_empresa (id_empresa);
-- ANTES: execution time -> 9.357
-- DEPOIS: execution time -> 0.024

-- Telefone_colaborador por Colaborador
EXPLAIN ANALYZE SELECT * FROM telefone_colaborador WHERE id_colaborador = 1;
CREATE INDEX IF NOT EXISTS idx_telefone_colaborador ON telefone_colaborador (id_colaborador);
-- ANTES: execution time -> 0.389
-- DEPOIS: execution time -> 0.032

-- Email_colaborador por Colaborador
EXPLAIN ANALYZE SELECT * FROM email_colaborador WHERE id_colaborador = 1;
CREATE INDEX IF NOT EXISTS idx_email_colaborador ON email_colaborador (id_colaborador);
-- ANTES: execution time -> 1.439
-- DEPOIS: execution time -> 0.035

-- Índices Únicos

CREATE UNIQUE INDEX IF NOT EXISTS idx_telefone_colaborador_principal
ON public.telefone_colaborador (id_colaborador) WHERE principal = TRUE;

CREATE UNIQUE INDEX IF NOT EXISTS idx_email_colaborador_principal
ON public.email_colaborador (id_colaborador) WHERE principal = TRUE;

CREATE UNIQUE INDEX IF NOT EXISTS idx_endereco_empresa_principal
ON public.endereco_empresa (id_empresa) WHERE principal = TRUE;

CREATE UNIQUE INDEX IF NOT EXISTS idx_telefone_empresa_principal
ON public.telefone_empresa (id_empresa) WHERE principal = TRUE;

CREATE UNIQUE INDEX IF NOT EXISTS idx_email_empresa_principal
ON public.email_empresa (id_empresa) WHERE principal = TRUE;