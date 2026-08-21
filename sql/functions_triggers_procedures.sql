-- ######################
-- FUNCTIONS
-- ######################

-- 1 (sempre que uma linha for atualizada, o campo atualizado_em será atualizado com a data e hora atual)

CREATE OR REPLACE FUNCTION public.fn_atualizado_em()
RETURNS TRIGGER AS $$
BEGIN
    NEW.atualizado_em = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2 (sempre que houver alteração da tabela tarefa, o status do plano de ação será atualizado)

CREATE OR REPLACE FUNCTION pdca.fn_atualizar_status_plano()
RETURNS TRIGGER AS $$
DECLARE
    id_plano BIGINT;
    pendentes INTEGER;
    canceladas INTEGER;
    total INTEGER;
BEGIN
    id_plano := CASE
        WHEN TG_OP = 'DELETE' THEN OLD.id_plano_acao
        ELSE NEW.id_plano_acao
    END;

    SELECT COUNT(*) FILTER (WHERE status NOT IN ('CONCLUIDA', 'CANCELADA')), COUNT(*) FILTER (WHERE status = 'CANCELADA'), COUNT(*)
    INTO pendentes, canceladas, total FROM pdca.tarefa WHERE id_plano_acao = id_plano;

    IF total = 0 THEN
        RETURN NEW;

    ELSIF pendentes = 0 AND canceladas = total THEN
        UPDATE pdca.plano_acao SET status = 'CANCELADO', atualizado_em = NOW()
        WHERE id = id_plano AND status != 'CANCELADO';

    ELSIF pendentes = 0 THEN
        UPDATE pdca.plano_acao SET status = 'CONCLUIDO', atualizado_em = NOW()
        WHERE id = id_plano AND status != 'CONCLUIDO';

    ELSIF pendentes > 0 THEN
        UPDATE pdca.plano_acao SET status = 'EM_EXECUCAO', atualizado_em = NOW()
        WHERE id = id_plano AND status IN ('CONCLUIDO', 'CANCELADO');
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3 (registro na tabela log_status) - (precisa do usuário atual)
-- O backend deve setar: SET app.current_user_id = <id>;

CREATE OR REPLACE FUNCTION auditoria.fn_log_status()
RETURNS TRIGGER AS $$
DECLARE
    usuario BIGINT;
BEGIN

    IF OLD.status IS DISTINCT FROM NEW.status THEN
        
        BEGIN
            usuario := current_setting('app.current_user_id', true)::BIGINT;
            EXCEPTION WHEN OTHERS THEN
            usuario := NULL;
        END;

        INSERT INTO auditoria.log_status (id_usuario, id_registro, tabela, status_anterior, status_atual, data_log) VALUES (
        COALESCE(usuario, 1), NEW.id, TG_TABLE_NAME, OLD.status, NEW.status, NOW());
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 4 (registro na tabela log_auditoria) - (precisa do usuário atual)

CREATE OR REPLACE FUNCTION auditoria.fn_log_auditoria()
RETURNS TRIGGER AS $$
DECLARE
    usuario BIGINT;
BEGIN
    BEGIN
        usuario := current_setting('app.current_user_id', true)::BIGINT;
    EXCEPTION WHEN OTHERS THEN
        usuario := NULL;
    END;

    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria.log_auditoria (id_usuario, id_registro, tabela, operacao, dados_antes, dados_depois, data_log)
        VALUES (COALESCE(usuario, 1), NEW.id, TG_TABLE_NAME, 'INSERT', '{}'::jsonb, to_jsonb(NEW));
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria.log_auditoria (id_usuario, id_registro, tabela, operacao, dados_antes, dados_depois, data_log)
        VALUES (COALESCE(usuario, 1), NEW.id, TG_TABLE_NAME, 'UPDATE', to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria.log_auditoria (id_usuario, id_registro, tabela, operacao, dados_antes, dados_depois, data_log)
        VALUES (COALESCE(usuario, 1), OLD.id, TG_TABLE_NAME, 'DELETE', to_jsonb(OLD), '{}'::jsonb);
        RETURN OLD;

    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- 5 (registro na tabela log_colaborador) - (precisa do usuário atual)

CREATE OR REPLACE FUNCTION auditoria.fn_log_colaborador()
RETURNS TRIGGER AS $$
DECLARE
    usuario BIGINT;
BEGIN
    BEGIN
        usuario := current_setting('app.current_user_id', true)::BIGINT;
    EXCEPTION WHEN OTHERS THEN
        usuario := NULL;
    END;

    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria.log_colaborador (id_colaborador, id_usuario, operacao, dados_antes, dados_depois, data_log) VALUES (
        NEW.id, COALESCE(usuario, 1), 'INSERT', '{}'::jsonb, to_jsonb(NEW));
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria.log_colaborador (id_colaborador, id_usuario, operacao, dados_antes, dados_depois, data_log) VALUES (
        NEW.id, COALESCE(usuario, 1), 'UPDATE', to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria.log_colaborador (id_colaborador, id_usuario, operacao, dados_antes, dados_depois, data_log) VALUES (
        OLD.id, COALESCE(usuario, 1), 'DELETE', to_jsonb(OLD), '{}'::jsonb);
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- 6 (registro na tabela log_tarefa) - (precisa do usuário atual)

CREATE OR REPLACE FUNCTION auditoria.fn_log_tarefa()
RETURNS TRIGGER AS $$
DECLARE
    usuario BIGINT;
BEGIN
    BEGIN
        usuario := current_setting('app.current_user_id', true)::BIGINT;
    EXCEPTION WHEN OTHERS THEN
        usuario := NULL;
    END;

    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria.log_tarefa (id_tarefa, id_usuario, operacao, dados_antes, dados_depois, data_log) VALUES (
        NEW.id, COALESCE(usuario, 1),'INSERT', '{}'::jsonb, to_jsonb(NEW));
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria.log_tarefa (id_tarefa, id_usuario, operacao, dados_antes, dados_depois, data_log) VALUES (
        NEW.id, COALESCE(usuario, 1), 'UPDATE', to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria.log_tarefa (id_tarefa, id_usuario, operacao, dados_antes, dados_depois, data_log) VALUES (
        OLD.id, COALESCE(usuario, 1), 'DELETE', to_jsonb(OLD),'{}'::jsonb);
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- 7 (Atualiza o peso do problema sempre que houver alteração na tabela priorizacao_problema_usuario)

CREATE OR REPLACE FUNCTION pdca.fn_recalcular_peso_problema()
RETURNS TRIGGER AS $$
DECLARE
    problema BIGINT;
    media NUMERIC(3,2);
BEGIN
    problema := CASE
        WHEN TG_OP = 'DELETE' THEN OLD.id_problema
        ELSE NEW.id_problema
    END;

    SELECT COALESCE(AVG(peso_calculado), 0) INTO media FROM pdca.priorizacao_problema_usuario
    WHERE id_problema = problema;

    UPDATE pdca.problema SET peso = media, atualizado_em = NOW() WHERE id = problema;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 8 (id_problema da tabela causa_raiz deve ser do mesmo ciclo que o id_ciclo da tabela causa_raiz)

CREATE OR REPLACE FUNCTION pdca.fn_validar_causa_raiz()
RETURNS TRIGGER AS $$
DECLARE
    ciclo BIGINT;
BEGIN
    SELECT id_ciclo INTO ciclo FROM pdca.problema WHERE id = NEW.id_problema;   

    IF ciclo IS DISTINCT FROM NEW.id_ciclo THEN
        RAISE EXCEPTION 'A causa raiz não pertence ao mesmo ciclo que o problema associado.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 9 (uma tarefa não pode acabar dependendo de uma tarefa que depende dessa tarefa)

CREATE OR REPLACE FUNCTION pdca.fn_validar_dependencia_tarefa()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.id_tarefa = NEW.id_tarefa_dependente THEN
        RAISE EXCEPTION 'Uma tarefa não pode depender de si mesma.';
    END IF;

    IF EXISTS (SELECT 1 FROM pdca.tarefa_dependencia WHERE id_tarefa = NEW.id_tarefa_dependente AND id_tarefa_dependente = NEW.id_tarefa) 
        THEN RAISE EXCEPTION 'A tarefa % não pode depender da tarefa %, pois a dependência inversa já existe.', NEW.id_tarefa, NEW.id_tarefa_dependente;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 10 (sincroniza a data de acordo com o status da tarefa)

CREATE OR REPLACE FUNCTION pdca.fn_sinc_data_tarefa_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'EM_ANDAMENTO' THEN
        NEW.data_inicio = NOW();

    ELSIF NEW.status = 'CONCLUIDA' THEN
        NEW.data_fim = NOW();

    ELSIF NEW.status = 'CANCELADA' THEN
        NEW.data_fim = NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 11 (não deixa ter mais de um principal por telefone/email/endereco)
CREATE OR REPLACE FUNCTION public.fn_validar_principal()
RETURNS TRIGGER AS $$
DECLARE
    qtd_principal INTEGER := 0;
BEGIN       
    IF NEW.principal THEN

        IF TG_TABLE_NAME = 'telefone_colaborador' THEN
            SELECT COUNT(*) INTO qtd_principal FROM public.telefone_colaborador WHERE id_colaborador = NEW.id_colaborador 
            AND principal = TRUE AND id IS DISTINCT FROM NEW.id;
            
        ELSIF TG_TABLE_NAME = 'email_colaborador' THEN
            SELECT COUNT(*) INTO qtd_principal FROM public.email_colaborador WHERE id_colaborador = NEW.id_colaborador 
            AND principal = TRUE AND id IS DISTINCT FROM NEW.id;
            
        ELSIF TG_TABLE_NAME = 'endereco_empresa' THEN
            SELECT COUNT(*) INTO qtd_principal FROM public.endereco_empresa WHERE id_empresa = NEW.id_empresa 
            AND principal = TRUE AND id IS DISTINCT FROM NEW.id;
            
        ELSIF TG_TABLE_NAME = 'telefone_empresa' THEN
            SELECT COUNT(*) INTO qtd_principal FROM public.telefone_empresa WHERE id_empresa = NEW.id_empresa 
            AND principal = TRUE AND id IS DISTINCT FROM NEW.id;
            
        ELSIF TG_TABLE_NAME = 'email_empresa' THEN
            SELECT COUNT(*) INTO qtd_principal FROM public.email_empresa WHERE id_empresa = NEW.id_empresa 
            AND principal = TRUE AND id IS DISTINCT FROM NEW.id;
        END IF;

        IF qtd_principal > 0 THEN
            RAISE EXCEPTION 'Já existe um registro principal cadastrado.';
        END IF;

    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 12 (calcula o avanço do ciclo em percentual)
CREATE OR REPLACE FUNCTION pdca.fn_avanco_ciclo(id_ciclo BIGINT)
RETURNS NUMERIC AS $$
DECLARE
    total_tarefas INTEGER;
    tarefas_concluidas INTEGER;
BEGIN
    SELECT COUNT(*) FROM pdca.tarefa WHERE id_ciclo = id_ciclo AND status IN ('CONCLUIDA', 'CANCELADA') INTO tarefas_concluidas;
    SELECT COUNT(*) FROM pdca.tarefa WHERE id_ciclo = id_ciclo INTO total_tarefas;

    IF total_tarefas > 0 THEN
        RETURN (tarefas_concluidas::NUMERIC / total_tarefas::NUMERIC) * 100;
    ELSE
        RETURN 0;
    END IF;
END;
$$;

--  ######################
--  TRIGGERS
--  ######################

-- 1 (trigger em loop que conecta a função fn_atualizado_em() a todas as tabelas que possuem a coluna atualizado_em)

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT table_schema, table_name
        FROM information_schema.columns
        WHERE column_name = 'atualizado_em'
        AND table_schema IN ('public', 'pdca')
    LOOP
        EXECUTE format('
            CREATE OR REPLACE TRIGGER tg_atualizado_em
            BEFORE UPDATE ON %I.%I
            FOR EACH ROW
            EXECUTE FUNCTION public.fn_atualizado_em();',
            r.table_schema, r.table_name
        );
    END LOOP;
END $$;

-- 2 (sempre que houver inserção na tabela tarefa, o status do plano de ação será atualizado)

CREATE OR REPLACE TRIGGER tg_status_plano_insert
AFTER INSERT ON pdca.tarefa
FOR EACH ROW
EXECUTE FUNCTION pdca.fn_atualizar_status_plano();

-- 3 (sempre que houver atualização na tabela tarefa, o status do plano de ação será atualizado)

CREATE OR REPLACE TRIGGER tg_status_plano_update
AFTER UPDATE OF status ON pdca.tarefa
FOR EACH ROW
EXECUTE FUNCTION pdca.fn_atualizar_status_plano();

-- 4 (sempre que houver exclusão na tabela tarefa, o status do plano de ação será atualizado)

CREATE OR REPLACE TRIGGER tg_status_plano_delete
AFTER DELETE ON pdca.tarefa
FOR EACH ROW
EXECUTE FUNCTION pdca.fn_atualizar_status_plano();

-- 5 (trigger em loop que conecta a função fn_log_status() a todas as tabelas, exceto tarefa e colaborador, pois tem logs próprios)

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT table_schema, table_name
        FROM information_schema.columns
        WHERE column_name = 'status'
          AND table_schema IN ('public', 'pdca')
          AND table_name NOT IN ('tarefa', 'colaborador')
    LOOP
        EXECUTE format('
            CREATE OR REPLACE TRIGGER tg_log_status
            AFTER UPDATE OF status ON %I.%I
            FOR EACH ROW
            EXECUTE FUNCTION auditoria.fn_log_status();',
            r.table_schema, r.table_name
        );
    END LOOP;
END $$;

-- 6 (trigger em loop que conecta a função fn_log_auditoria() a todas as tabelas, exceto tarefa e colaborador, pois tem logs próprios)

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT table_schema, table_name
        FROM information_schema.columns
        WHERE column_name = 'id'
          AND table_schema IN ('public', 'pdca')
          AND table_name NOT IN ('tarefa', 'colaborador')
    LOOP
        EXECUTE format('
            CREATE OR REPLACE TRIGGER tg_auditoria
            AFTER INSERT OR UPDATE OR DELETE ON %I.%I
            FOR EACH ROW
            EXECUTE FUNCTION auditoria.fn_log_auditoria();',
            r.table_schema, r.table_name
        );
    END LOOP;
END $$;

-- 7 (trigger que conecta a função fn_log_tarefa() à tabela tarefa)

CREATE OR REPLACE TRIGGER tg_log_tarefa
AFTER INSERT OR UPDATE OR DELETE ON pdca.tarefa
FOR EACH ROW
EXECUTE FUNCTION auditoria.fn_log_tarefa();

-- 8 (trigger que conecta a função fn_log_colaborador() à tabela colaborador)

CREATE OR REPLACE TRIGGER tg_log_colaborador
AFTER INSERT OR UPDATE OR DELETE ON public.colaborador
FOR EACH ROW
EXECUTE FUNCTION auditoria.fn_log_colaborador();

-- 9 (trigger que conecta a função fn_recalcular_peso_problema() à tabela priorizacao_problema_usuario)

CREATE OR REPLACE TRIGGER trg_recalcular_peso_problema
AFTER INSERT OR UPDATE OF peso_calculado OR DELETE ON pdca.priorizacao_problema_usuario
FOR EACH ROW
EXECUTE FUNCTION pdca.fn_recalcular_peso_problema();

-- 10 (trigger que conecta a função fn_validar_causa_raiz() à tabela causa_raiz)
CREATE OR REPLACE TRIGGER tg_validar_causa_raiz
BEFORE INSERT OR UPDATE ON pdca.causa_raiz
FOR EACH ROW
EXECUTE FUNCTION pdca.fn_validar_causa_raiz();

-- 11 (trigger que conecta a função fn_sinc_data_tarefa_status() à tabela tarefa)
CREATE OR REPLACE TRIGGER tg_sinc_data_tarefa_status
BEFORE UPDATE OF status ON pdca.tarefa
FOR EACH ROW
EXECUTE FUNCTION pdca.fn_sinc_data_tarefa_status();

-- 12 (trigger em loop que conecta a função fn_validar_principal() à tabela telefone_colaborador, email_colaborador, endereco_empresa, telefone_empresa e email_empresa)
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_schema IN ('public')
          AND table_name IN ('telefone_colaborador', 'email_colaborador', 'endereco_empresa', 'telefone_empresa', 'email_empresa')
    LOOP
        EXECUTE format('
            CREATE OR REPLACE TRIGGER tg_validar_principal
            BEFORE INSERT OR UPDATE ON %I.%I
            FOR EACH ROW
            EXECUTE FUNCTION public.fn_validar_principal();',
            r.table_schema, r.table_name
        );
    END LOOP;
END $$;

-- 13 (trigger que conecta a função fn_validar_dependencia_tarefa() à tabela tarefa_dependencia)
CREATE OR REPLACE TRIGGER tg_validar_dependencia_tarefa
BEFORE INSERT ON pdca.tarefa_dependencia
FOR EACH ROW
EXECUTE FUNCTION pdca.fn_validar_dependencia_tarefa();

--  ######################
--  PROCEDURES
--  ######################

-- 1 (gera alertas de atraso para tarefas que estão atrasadas e atualiza o status das mesmas para 'ATRASADA')

CREATE OR REPLACE PROCEDURE pdca.pr_gerar_alertas_atraso()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO pdca.alerta_prazo (id_tarefa, id_usuario_destino, mensagem) SELECT t.id, t.id_responsavel,
    FORMAT('A tarefa "%s" está atrasada desde %s.', t.titulo, TO_CHAR(t.data_fim_prevista, 'DD/MM/YYYY')) FROM pdca.tarefa t 
    WHERE t.data_fim_prevista < CURRENT_DATE 
    AND t.status NOT IN ('CONCLUIDA', 'CANCELADA');

    UPDATE pdca.tarefa SET status = 'ATRASADA' WHERE data_fim_prevista < CURRENT_DATE AND status NOT IN ('CONCLUIDA', 'CANCELADA');
END;
$$;

-- 2 (gera log de acesso do usuário)

CREATE OR REPLACE PROCEDURE auditoria.pr_registrar_acesso(usuario BIGINT, ciclo BIGINT, acao VARCHAR(60))
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO auditoria.log_acesso_usuario (id_usuario, id_ciclo, acao_realizada) VALUES (usuario, ciclo, acao);
END;
$$;

-- 3 (gera log de atividade diária do usuário)

CREATE OR REPLACE PROCEDURE auditoria.pr_registrar_atividade_diaria(usuario BIGINT, num_acoes INTEGER, hora_inicio TIMESTAMP)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO auditoria.atv_usuario_dia (id_usuario, data_atv, hora_inicio, hora_fim, qnt_acoes)
    VALUES (usuario, CURRENT_DATE, hora_inicio, NOW(), num_acoes);
END;
$$;

