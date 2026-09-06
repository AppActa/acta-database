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

        IF usuario IS NULL THEN
            RAISE EXCEPTION 'Usuário não recebido pelo backend';
        END IF;

        INSERT INTO auditoria.log_status (id_usuario, id_registro, tabela, status_anterior, status_atual, data_log) VALUES (
        usuario, NEW.id, TG_TABLE_NAME, OLD.status, NEW.status, NOW());
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

    IF usuario IS NULL THEN
        RAISE EXCEPTION 'Usuário não recebido pelo backend';
    END IF;

    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria.log_auditoria (id_usuario, id_registro, tabela, operacao, dados_antes, dados_depois, data_log)
        VALUES (usuario, NEW.id, TG_TABLE_NAME, 'INSERT', '{}'::jsonb, to_jsonb(NEW));
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria.log_auditoria (id_usuario, id_registro, tabela, operacao, dados_antes, dados_depois, data_log)
        VALUES (usuario, NEW.id, TG_TABLE_NAME, 'UPDATE', to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria.log_auditoria (id_usuario, id_registro, tabela, operacao, dados_antes, dados_depois, data_log)
        VALUES (usuario, OLD.id, TG_TABLE_NAME, 'DELETE', to_jsonb(OLD), '{}'::jsonb);
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

    IF usuario IS NULL THEN
        RAISE EXCEPTION 'Usuário não recebido pelo backend';
    END IF;

    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria.log_colaborador (id_colaborador, id_usuario, operacao, dados_antes, dados_depois, data_log) VALUES (
        NEW.id, usuario, 'INSERT', '{}'::jsonb, to_jsonb(NEW));
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria.log_colaborador (id_colaborador, id_usuario, operacao, dados_antes, dados_depois, data_log) VALUES (
        NEW.id, usuario, 'UPDATE', to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria.log_colaborador (id_colaborador, id_usuario, operacao, dados_antes, dados_depois, data_log) VALUES (
        OLD.id, usuario, 'DELETE', to_jsonb(OLD), '{}'::jsonb);
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

    IF usuario IS NULL THEN
        RAISE EXCEPTION 'Usuário não recebido pelo backend';
    END IF;
    
    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria.log_tarefa (id_tarefa, id_usuario, operacao, dados_antes, dados_depois, data_log) VALUES (
        NEW.id, usuario,'INSERT', '{}'::jsonb, to_jsonb(NEW));
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria.log_tarefa (id_tarefa, id_usuario, operacao, dados_antes, dados_depois, data_log) VALUES (
        NEW.id, usuario, 'UPDATE', to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria.log_tarefa (id_tarefa, id_usuario, operacao, dados_antes, dados_depois, data_log) VALUES (
        OLD.id, usuario, 'DELETE', to_jsonb(OLD),'{}'::jsonb);
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

    RETURN COALESCE(NEW, OLD);
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
    IF NEW.id_tarefa = NEW.id_tarefa_dependencia THEN
        RAISE EXCEPTION 'Uma tarefa não pode depender de si mesma.';
    END IF;

    IF EXISTS (SELECT 1 FROM pdca.tarefa_dependencia WHERE id_tarefa = NEW.id_tarefa_dependencia AND id_tarefa_dependencia = NEW.id_tarefa) 
        THEN RAISE EXCEPTION 'A tarefa % não pode depender da tarefa %, pois a dependência inversa já existe.', NEW.id_tarefa, NEW.id_tarefa_dependencia;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 10 (sincroniza a data de acordo com o status da tarefa)

CREATE OR REPLACE FUNCTION pdca.fn_sinc_data_tarefa_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status IS DISTINCT FROM OLD.status THEN

        IF NEW.status = 'EM_ANDAMENTO' THEN
            IF NEW.data_inicio_real IS NULL THEN
                NEW.data_inicio_real := NOW();
            END IF;

            NEW.data_fim_real := NULL;

        ELSIF NEW.status IN ('CONCLUIDA', 'CANCELADA') THEN
            NEW.data_fim_real := NOW();
        
        END IF;

    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 11 (calcula o avanço do ciclo em percentual)
CREATE OR REPLACE FUNCTION pdca.fn_avanco_ciclo(p_id_ciclo BIGINT)
RETURNS NUMERIC AS $$
DECLARE
    total_tarefas INTEGER := 0;
    tarefas_concluidas INTEGER := 0;
BEGIN
    SELECT COUNT(*), COUNT(*) FILTER (WHERE t.status IN ('CONCLUIDA', 'CANCELADA'))
    INTO total_tarefas, tarefas_concluidas FROM pdca.tarefa t
    JOIN pdca.plano_acao pa ON pa.id = t.id_plano_acao
    WHERE pa.id_ciclo = p_id_ciclo;

    IF total_tarefas > 0 THEN
        RETURN ROUND((tarefas_concluidas::NUMERIC / total_tarefas::NUMERIC) * 100, 2);
    ELSE
        RETURN 0;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 12 (adiciona na tabela de relação usuario_ciclo o responsável por aquele ciclo)
CREATE OR REPLACE FUNCTION pdca.fn_vincular_responsavel_ciclo()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' AND OLD.id_responsavel IS DISTINCT FROM NEW.id_responsavel THEN
        UPDATE pdca.usuario_ciclo
        SET papel_ciclo = 'PARTICIPANTE'
        WHERE id_ciclo = NEW.id 
          AND id_usuario = OLD.id_responsavel 
          AND papel_ciclo = 'RESPONSAVEL';
    END IF;

    IF NEW.id_responsavel IS NOT NULL THEN
        INSERT INTO pdca.usuario_ciclo (id_usuario, id_ciclo, papel_ciclo)
        VALUES (NEW.id_responsavel, NEW.id, 'RESPONSAVEL')
        ON CONFLICT (id_usuario, id_ciclo) 
        DO UPDATE SET papel_ciclo = 'RESPONSAVEL';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 14 (etapas de verificação antes de uma tarefa ser iniciada)
CREATE OR REPLACE FUNCTION pdca.fn_pode_iniciar_tarefa(tarefa_id BIGINT, usuario_id BIGINT)
RETURNS BOOLEAN AS $$
DECLARE
    ciclo BIGINT;
    pertence_ao_ciclo BOOLEAN;
    plano_iniciado BOOLEAN;
    responsavel_tarefa BOOLEAN;
    treinamento_pendente BOOLEAN;
    dependencia_pendente BOOLEAN;
BEGIN

    -- Ciclo
    SELECT pa.id_ciclo INTO ciclo FROM pdca.tarefa t
    JOIN pdca.plano_acao pa ON pa.id = t.id_plano_acao
    WHERE t.id = tarefa_id;

    IF ciclo IS NULL THEN
        RETURN FALSE;
    END IF;

    -- O usuário está no ciclo
    SELECT EXISTS (
        SELECT 1 FROM pdca.usuario_ciclo WHERE id_ciclo = ciclo AND id_usuario = usuario_id
    ) INTO pertence_ao_ciclo;

    IF NOT pertence_ao_ciclo THEN
        RETURN FALSE;
    END IF;

    -- Se o plano foi iniciado
    SELECT EXISTS (
        SELECT 1 FROM pdca.tarefa t
        JOIN pdca.plano_acao pa ON pa.id = t.id_plano_acao WHERE t.id = tarefa_id AND pa.status = 'EM_EXECUCAO'
    ) INTO plano_iniciado;

    IF NOT plano_iniciado THEN
        RETURN FALSE;
    END IF;

    -- Responsável da tarefa
    SELECT EXISTS (
        SELECT 1 FROM pdca.tarefa WHERE id = tarefa_id AND id_responsavel = usuario_id
    ) INTO responsavel_tarefa;

    IF NOT responsavel_tarefa THEN
        RETURN FALSE;
    END IF;

    -- Treinamento OBRIGATÓRIO não concluído
    SELECT EXISTS (
        SELECT 1 FROM pdca.treinamento tr
        LEFT JOIN pdca.usuario_treinamento ut ON ut.id_treinamento = tr.id AND ut.id_usuario = usuario_id
        WHERE tr.id_ciclo = ciclo AND tr.obrigatorio = TRUE AND (ut.status IS NULL OR ut.status <> 'CONCLUIDO')
    ) INTO treinamento_pendente;

    IF treinamento_pendente THEN
        RETURN FALSE;
    END IF;

    -- Dependência da tarefa
    SELECT EXISTS (
        SELECT 1 FROM pdca.tarefa_dependencia dep
        JOIN pdca.tarefa t ON t.id = dep.id_tarefa_dependencia
        WHERE dep.id_tarefa = tarefa_id AND t.status <> 'CONCLUIDA'
    ) INTO dependencia_pendente;

    IF dependencia_pendente THEN
        RETURN FALSE;
    END IF;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- 15 (etapas de verificação antes de encerrar um ciclo)
CREATE OR REPLACE FUNCTION pdca.fn_pode_encerrar_ciclo(ciclo_id BIGINT)
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    status_ciclo VARCHAR(40);
    planos_pendentes INTEGER := 0;
    tarefas_pendentes INTEGER := 0;
BEGIN
    -- Validação 1: Existência e Status do Ciclo
    SELECT status INTO status_ciclo FROM pdca.ciclo WHERE id = ciclo_id;

    IF status_ciclo IS NULL OR status_ciclo IN ('CONCLUIDO', 'CANCELADO') THEN
        RETURN FALSE;
    END IF;

    -- Validação 2: Planos pendentes
    SELECT COUNT(*) INTO planos_pendentes 
    FROM pdca.plano_acao
    WHERE id_ciclo = ciclo_id AND status NOT IN ('CONCLUIDO', 'CANCELADO');

    IF planos_pendentes > 0 THEN
        RETURN FALSE;
    END IF;

    -- Validação 3: Tarefas pendentes
    SELECT COUNT(*) INTO tarefas_pendentes 
    FROM pdca.tarefa t
    JOIN pdca.plano_acao pa ON pa.id = t.id_plano_acao
    WHERE pa.id_ciclo = ciclo_id AND t.status NOT IN ('CONCLUIDA', 'CANCELADA');

    IF tarefas_pendentes > 0 THEN
        RETURN FALSE;
    END IF;

    RETURN TRUE;
END;
$$;

-- 16 (validar exclusão de registros de email_empresa, telefone_empresa e endereco_empresa)
CREATE OR REPLACE FUNCTION public.fn_validar_exclusao_empresa()
RETURNS TRIGGER AS $$
DECLARE
    total INT;
BEGIN
   
    IF NOT EXISTS (SELECT 1 FROM public.empresa WHERE id = OLD.id_empresa) THEN
        RETURN OLD;
    END IF;

    IF TG_TABLE_NAME = 'email_empresa' THEN
        SELECT COUNT(*) INTO total FROM public.email_empresa WHERE id_empresa = OLD.id_empresa;
    ELSIF TG_TABLE_NAME = 'telefone_empresa' THEN
        SELECT COUNT(*) INTO total FROM public.telefone_empresa WHERE id_empresa = OLD.id_empresa;
    ELSIF TG_TABLE_NAME = 'endereco_empresa' THEN
        SELECT COUNT(*) INTO total FROM public.endereco_empresa WHERE id_empresa = OLD.id_empresa;
    END IF;

    
    IF total <= 1 THEN
        IF NOT OLD.principal THEN
            IF TG_TABLE_NAME = 'email_empresa' THEN
                UPDATE public.email_empresa SET principal = TRUE WHERE id = OLD.id;
            ELSIF TG_TABLE_NAME = 'telefone_empresa' THEN
                UPDATE public.telefone_empresa SET principal = TRUE WHERE id = OLD.id;
            ELSIF TG_TABLE_NAME = 'endereco_empresa' THEN
                UPDATE public.endereco_empresa SET principal = TRUE WHERE id = OLD.id;
            END IF;
        END IF;
        
        RAISE EXCEPTION 'Não é possível excluir o único registro cadastrado para esta empresa.';
    END IF;

    IF OLD.principal THEN
        RAISE EXCEPTION 'Não é possível excluir o registro principal.';
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- 17 (validar exclusão de registros de email_colaborador e telefone_colaborador)
CREATE OR REPLACE FUNCTION public.fn_validar_exclusao_colaborador()
RETURNS TRIGGER AS $$
DECLARE
    total INT;
BEGIN

    IF NOT EXISTS (SELECT 1 FROM public.colaborador WHERE id = OLD.id_colaborador) THEN
        RETURN OLD;
    END IF;


    IF TG_TABLE_NAME = 'email_colaborador' THEN
        SELECT COUNT(*) INTO total FROM public.email_colaborador WHERE id_colaborador = OLD.id_colaborador;
    ELSIF TG_TABLE_NAME = 'telefone_colaborador' THEN
        SELECT COUNT(*) INTO total FROM public.telefone_colaborador WHERE id_colaborador = OLD.id_colaborador;
    END IF;


    IF total <= 1 THEN
        IF NOT OLD.principal THEN
            IF TG_TABLE_NAME = 'email_colaborador' THEN
                UPDATE public.email_colaborador SET principal = TRUE WHERE id = OLD.id;
            ELSIF TG_TABLE_NAME = 'telefone_colaborador' THEN
                UPDATE public.telefone_colaborador SET principal = TRUE WHERE id = OLD.id;
            END IF;
        END IF;
        
        RAISE EXCEPTION 'Não é possível excluir o único registro cadastrado para este colaborador.';
    END IF;

    IF OLD.principal THEN
        RAISE EXCEPTION 'Não é possível excluir o registro principal.';
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;


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

-- 12 (trigger que conecta a função fn_validar_dependencia_tarefa() à tabela tarefa_dependencia)
CREATE OR REPLACE TRIGGER tg_validar_dependencia_tarefa
BEFORE INSERT ON pdca.tarefa_dependencia
FOR EACH ROW
EXECUTE FUNCTION pdca.fn_validar_dependencia_tarefa();

-- 13 (trigger que conecta a função fn_vincular_responsavel_ciclo() à tabela ciclo)
CREATE OR REPLACE TRIGGER tg_vincular_responsavel_ciclo
AFTER INSERT OR UPDATE ON pdca.ciclo
FOR EACH ROW
EXECUTE FUNCTION pdca.fn_vincular_responsavel_ciclo();

-- 14 (trigger que conecta a função fn_validar_exclusao_empresa() à email_empresa)
CREATE OR REPLACE TRIGGER tg_validar_exclusao_email_empresa
BEFORE DELETE ON public.email_empresa
FOR EACH ROW EXECUTE FUNCTION public.fn_validar_exclusao_empresa();

-- 15 (trigger que conecta a função fn_validar_exclusao_empresa() à telefone_empresa)
CREATE OR REPLACE TRIGGER tg_validar_exclusao_telefone_empresa
BEFORE DELETE ON public.telefone_empresa
FOR EACH ROW EXECUTE FUNCTION public.fn_validar_exclusao_empresa();

-- 16 (trigger que conecta a função fn_validar_exclusao_empresa() à endereco_empresa)
CREATE OR REPLACE TRIGGER tg_validar_exclusao_endereco_empresa
BEFORE DELETE ON public.endereco_empresa
FOR EACH ROW EXECUTE FUNCTION public.fn_validar_exclusao_empresa();

-- 17 (trigger que conecta a função fn_validar_exclusao_colaborador() à email_colaborador)
CREATE OR REPLACE TRIGGER tg_validar_exclusao_email_colaborador
BEFORE DELETE ON public.email_colaborador
FOR EACH ROW EXECUTE FUNCTION public.fn_validar_exclusao_colaborador();

-- 18 (trigger que conecta a função fn_validar_exclusao_colaborador() à telefone_colaborador)
CREATE OR REPLACE TRIGGER tg_validar_exclusao_telefone_colaborador
BEFORE DELETE ON public.telefone_colaborador
FOR EACH ROW EXECUTE FUNCTION public.fn_validar_exclusao_colaborador();

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

-- 4 (encerrar ciclo se passar das verificações da função fn_pode_encerrar_ciclo)
CREATE OR REPLACE PROCEDURE pdca.pr_encerrar_ciclo(ciclo_id BIGINT)
LANGUAGE plpgsql
AS $$
BEGIN

    IF NOT pdca.fn_pode_encerrar_ciclo(ciclo_id) THEN
        RAISE EXCEPTION 'Não é possível encerrar o ciclo.';
    END IF;

    UPDATE pdca.ciclo SET status = 'CONCLUIDO', data_fim_real = CURRENT_DATE, atualizado_em = NOW() WHERE id = ciclo_id;
END;
$$;

-- 5 (reabertura de tarefa concluída ou cancelada, com novo prazo)
CREATE OR REPLACE PROCEDURE pdca.pr_reabrir_tarefa(tarefa_id BIGINT, novo_prazo DATE)
LANGUAGE plpgsql
AS $$
DECLARE
    status_atual VARCHAR(20);
BEGIN

    SELECT status INTO status_atual FROM pdca.tarefa WHERE id = tarefa_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tarefa com ID % não encontrada.', tarefa_id;
    END IF;

    IF status_atual NOT IN ('CONCLUIDA', 'CANCELADA') THEN
        RAISE EXCEPTION 'Apenas tarefas com status CONCLUIDA ou CANCELADA podem ser reabertas. Status atual: %', status_atual;
    END IF;

    IF novo_prazo < CURRENT_DATE THEN
        RAISE EXCEPTION 'O novo prazo (%) não pode ser menor que o dia atual.', TO_CHAR(novo_prazo, 'DD/MM/YYYY');
    END IF;

    UPDATE pdca.tarefa SET status = 'EM_ANDAMENTO', data_fim_prevista = novo_prazo, data_fim_real = NULL, 
    atualizado_em = CURRENT_TIMESTAMP WHERE id = tarefa_id;
END;
$$;

