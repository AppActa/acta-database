import logging
import os
import re
import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

# Configuração de logs
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

load_dotenv()  

URL_ORIGEM = os.getenv("URL_PRIMEIRO_BANCO")
URL_DESTINO = os.getenv("URL_SEGUNDO_BANCO")

engine_origem = create_engine(URL_ORIGEM)
engine_destino = create_engine(URL_DESTINO)


# inserir_df
def inserir_dataframe(df, nome_tabela, schema):
    """Insere o DataFrame no banco de destino definindo o usuário de auditoria na sessão."""
    if df.empty:
        return 

    with engine_destino.begin() as conn:
        
        conn.execute(text(f"SET LOCAL app.current_user_id = '0';"))
        
        df.to_sql(
            nome_tabela,
            con=conn,
            schema=schema,
            if_exists="append",
            index=False
        )

# Tratamento de dados

def limpar_digitos(valor):
    """Remove qualquer caractere não numérico."""
    if pd.isna(valor):
        return ""
    return re.sub(r"\D", "", str(valor))

def sanitizar_email(email):
    """Garante que o e-mail esteja em caixa baixa e sem espaços extras."""
    if pd.isna(email):
        return None
    email_limpo = str(email).strip().lower()
    regex = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
    return email_limpo if re.match(regex, email_limpo) else None


# Tabela empresa
def carregar_empresa():
    logging.info("Migrando Tabela: empresa -> public.empresa")
    df = pd.read_sql("SELECT * FROM empresa", engine_origem)
    qtd_encontrados = len(df)

    if df.empty:
        logging.info("Nenhuma empresa encontrada para migração.")
        return {}

    tamanho_map = {"PEQUENA": "PEQUENA", "MEDIA": "MEDIA", "GRANDE": "GRANDE"}

    df_destino = pd.DataFrame({
        "id": df["id_empresa"],
        "cnpj": df["cnpj"].apply(limpar_digitos).str.zfill(14),
        "nome": df["nome"].str.strip(),
        "tamanho_empresa": df["tamanho"].map(tamanho_map).fillna("MEDIA"),
        "setor_empresa": df["setor"].str.strip(),
        "status": df["status"].map({"ATIVA": "ATIVO", "INATIVA": "INATIVO"}).fillna("ATIVO"),
        "criado_em": pd.Timestamp.now()
    })

    ids_existentes = pd.read_sql("SELECT id FROM public.empresa", engine_destino)["id"].tolist()

    df_destino = df_destino[~df_destino["id"].isin(ids_existentes)]
    qtd_enviados = len(df_destino)
    
    if not df_destino.empty:
        inserir_dataframe(df_destino, "empresa", "public")

    logging.info(f"Tabela empresa -> Encontrados: {qtd_encontrados} | Enviados: {qtd_enviados}")

    df_atualizado = pd.read_sql("SELECT id FROM public.empresa", engine_destino)
    return {i: i for i in df_atualizado["id"]}


# Tabelas usuario_sistema, colaborador, email_colaborador, telefone_colaborador

def carregar_usuarios_e_colaboradores(mapa_empresa_ids):
    logging.info("Migrando: colaborador -> public.usuario_sistema, public.colaborador, public.email_colaborador, public.telefone_colaborador")
    df_colab = pd.read_sql("SELECT * FROM colaborador", engine_origem)
    qtd_encontrados = len(df_colab)

    if df_colab.empty:
        logging.info("Nenhum colaborador encontrado para migração.")
        return {}

    df_colab = df_colab[df_colab["id_empresa"].isin(mapa_empresa_ids.keys())]

    if df_colab.empty:
            logging.info("Nenhum colaborador encontrado para migração.")
            return {}

    df_colab["cpf_limpo"] = df_colab["cpf"].apply(limpar_digitos).str.zfill(11)
    df_colab["telefone_limpo"] = df_colab["telefone"].apply(limpar_digitos)
    df_colab["email_limpo"] = df_colab["email"].apply(sanitizar_email)

    # Tabela public.usuario_sistema
    df_usuario = pd.DataFrame({
        "id": df_colab["id_colaborador"],
        "id_empresa": df_colab["id_empresa"],
        "nome": (df_colab["nome"].str.strip() + " " + df_colab["sobrenome"].str.strip()),
        "email_login": df_colab["email_limpo"],
        "firebase_uid": None, 
        "tipo_usuario": "COLABORADOR",
        "status": "PENDENTE", 
        "criado_em": pd.Timestamp.now()
    })

    ids_existentes = pd.read_sql("SELECT id FROM public.usuario_sistema", engine_destino)["id"].tolist()

    df_usuario = df_usuario[~df_usuario["id"].isin(ids_existentes)]

    if not df_usuario.empty:
        inserir_dataframe(df_usuario, "usuario_sistema", "public")

    # Tabela public.colaborador
    df_colaborador_detalhe = pd.DataFrame({
        "id": df_colab["id_colaborador"],
        "id_empresa": df_colab["id_empresa"],
        "id_usuario": df_colab["id_colaborador"],
        "cpf": df_colab["cpf_limpo"],
        "nome": (df_colab["nome"].str.strip() + " " + df_colab["sobrenome"].str.strip()),
        "cargo": df_colab["cargo"].str.strip(),
        "area": df_colab["area"].str.strip(),
        "data_nascimento": "1990-01-01", 
        "data_contratacao": df_colab["dt_contratacao"],
        "permissao_gestor": df_colab["permissao_gestor"],
        "status": df_colab["status"].map({"ATIVA": "ATIVO", "INATIVA": "INATIVO"}).fillna("ATIVO"),
        "criado_em": pd.Timestamp.now()
    })

    ids_existentes = pd.read_sql("SELECT id FROM public.colaborador", engine_destino)["id"].tolist()

    df_colaborador_detalhe = df_colaborador_detalhe[~df_colaborador_detalhe["id"].isin(ids_existentes)]
    qtd_colab_enviados = len(df_colaborador_detalhe)

    if not df_colaborador_detalhe.empty:
        inserir_dataframe(df_colaborador_detalhe, "colaborador", "public")

    # Tabela public.email_colaborador
    df_email = pd.DataFrame({
        "id_colaborador": df_colab["id_colaborador"],
        "email": df_colab["email_limpo"],
        "principal": True,
        "criado_em": pd.Timestamp.now()
    }).dropna(subset=["email"])

    if not df_email.empty:
        dados_existentes = pd.read_sql("SELECT id_colaborador, email FROM public.email_colaborador", engine_destino)
        emails_existentes = dados_existentes["email"].tolist()
        colabs_existentes = dados_existentes["id_colaborador"].tolist()

        df_email_filtrado = df_email[
            (~df_email["email"].isin(emails_existentes)) & 
            (~df_email["id_colaborador"].isin(colabs_existentes))
        ]

        if not df_email_filtrado.empty:
            inserir_dataframe(df_email_filtrado, "email_colaborador", "public")


    # Tabela public.telefone_colaborador
    df_tel = pd.DataFrame({
        "id_colaborador": df_colab["id_colaborador"],
        "numero_telefone": df_colab["telefone_limpo"],
        "principal": True,
        "criado_em": pd.Timestamp.now()
    })

    df_tel = df_tel[df_tel["numero_telefone"].str.len().between(10, 15)]

    if not df_tel.empty:
        dados_tel_existentes = pd.read_sql("SELECT id_colaborador, numero_telefone FROM public.telefone_colaborador", engine_destino)
        tels_existentes = dados_tel_existentes["numero_telefone"].tolist()
        colabs_tel_existentes = dados_tel_existentes["id_colaborador"].tolist()

        df_tel_filtrado = df_tel[
            (~df_tel["numero_telefone"].isin(tels_existentes)) &
            (~df_tel["id_colaborador"].isin(colabs_tel_existentes))
        ]

        if not df_tel_filtrado.empty:
            inserir_dataframe(df_tel_filtrado, "telefone_colaborador", schema="public")

        logging.info(f"Tabela colaborador -> Encontrados: {qtd_encontrados} | Enviados: {qtd_colab_enviados}")

        df_atualizado = pd.read_sql("SELECT id FROM public.colaborador", engine_destino)
        return {i: i for i in df_atualizado["id"]}


# Tabela pdca.ciclo

def carregar_ciclos(mapa_empresa_ids, mapa_colaborador_ids):
    logging.info("Migrando Tabela: ciclo -> pdca.ciclo")
    df = pd.read_sql("SELECT * FROM ciclo", engine_origem)

    if df.empty:
        logging.info("Nenhum ciclo encontrado para migração.")
        return {}

    df = df[df["id_empresa"].isin(mapa_empresa_ids.keys()) & df["id_responsavel"].isin(mapa_colaborador_ids.keys())]

    if df.empty:
        logging.info("Nenhum ciclo encontrado para migração.")
        return {}

    status_map = {
        "NAO_INICIADO": "PLANEJAMENTO",
        "INICIADO": "EXECUCAO",
        "FINALIZADO": "CONCLUIDO"
    }

    df_destino = pd.DataFrame({
        "id": df["id_ciclo"],
        "id_empresa": df["id_empresa"],
        "id_responsavel": df["id_responsavel"],
        "titulo": df["nome"].str.strip(),
        "descricao": df["descricao"].fillna("Sem descrição"),
        "status": df["status"].map(status_map).fillna("PLANEJAMENTO"),
        "data_inicio": df["dt_inicio"],
        "data_estimada_fim": df["dt_fim"].fillna(pd.to_datetime(df["dt_inicio"]) + pd.Timedelta(days=30)),
        "criado_em": df["criado_em"]
    })

    ids_existentes = pd.read_sql("SELECT id FROM pdca.ciclo", engine_destino)["id"].tolist()

    df_destino = df_destino[~df_destino["id"].isin(ids_existentes)]

    if not df_destino.empty:
        inserir_dataframe(df_destino, "ciclo", schema="pdca")

    df_atualizado = pd.read_sql("SELECT id FROM pdca.ciclo", engine_destino)
    return {i: i for i in df_atualizado["id"]}

# Tabela pdca.plano_acao

def carregar_planos_acao(mapa_ciclo_ids, mapa_colaborador_ids):
    logging.info("Migrando Tabela: plano_acao -> pdca.plano_acao")
    df = pd.read_sql("SELECT * FROM plano_acao", engine_origem)

    if df.empty:
        logging.info("Nenhum plano de ação encontrado para migração.")
        return {}

    df = df[df["id_ciclo"].isin(mapa_ciclo_ids.keys()) & df["id_criador"].isin(mapa_colaborador_ids.keys())]
    if df.empty:
        logging.info("Nenhum plano de ação encontrado para migração.")
        return {}

    status_map = {
        "NAO_INICIADO": "RASCUNHO",
        "INICIADO": "EM_EXECUCAO",
        "FINALIZADO": "CONCLUIDO"
    }

    prioridade_map = {
        "BAIXO": "BAIXA",
        "MEDIO": "MEDIA",
        "ALTO": "ALTA"
    }

    df_destino = pd.DataFrame({
        "id": df["id_plano_acao"],
        "id_ciclo": df["id_ciclo"],
        "nome": df["nome"].str.strip(),
        "objetivo": df["descricao"],
        "prioridade": df["prioridade"].map(prioridade_map).fillna("MEDIA"),
        "status": df["status"].map(status_map).fillna("RASCUNHO"),
        "origem": "IMPORTACAO",
        "criado_por": df["id_criador"],
        "criado_em": pd.Timestamp.now()
    })

    ids_existentes = pd.read_sql("SELECT id FROM pdca.plano_acao", engine_destino)["id"].tolist()

    df_destino = df_destino[~df_destino["id"].isin(ids_existentes)]

    if not df_destino.empty:
        inserir_dataframe(df_destino, "plano_acao", schema="pdca")

    df_atualizado = pd.read_sql("SELECT id FROM pdca.plano_acao", engine_destino)
    return {i: i for i in df_atualizado["id"]}

# Tabela pdca.plano_5w2h

def carregar_plano_5w2h(mapa_plano_ids, mapa_colaborador_ids):
    logging.info("Migrando Tabela: plano_acao5w2h -> pdca.plano_5w2h")
    df = pd.read_sql("SELECT * FROM plano_acao5w2h", engine_origem)

    if df.empty:
        logging.info("Nenhum plano 5W2H encontrado para migração.")
        return

    df = df[df["id_plano_acao"].isin(mapa_plano_ids.keys()) & df["who"].isin(mapa_colaborador_ids.keys())]
    if df.empty:
        logging.info("Nenhum plano 5W2H encontrado para migração.")
        return

    df_destino = pd.DataFrame({
        "id": df["id_plano_acao_5w2h"],
        "id_plano_acao": df["id_plano_acao"],
        "id_who_responsavel": df["who"],
        "what_acao": df["what"],
        "why_justificativa": df["why"].fillna("Sem justificativa definida"),
        "where_local": df["where"].fillna("Não especificado"),
        "when_inicio": None,
        "when_fim": df["when"].fillna(pd.Timestamp.now().date()),
        "how_modo_execucao": df["how"].fillna("Conforme planejado"),
        "how_much_custo": df["how_much"].fillna(0.00),
        "criado_em": pd.Timestamp.now()
    })

    ids_existentes = pd.read_sql("SELECT id FROM pdca.plano_5w2h", engine_destino)["id"].tolist()

    df_destino = df_destino[~df_destino["id"].isin(ids_existentes)]

    if not df_destino.empty:
        inserir_dataframe(df_destino, "plano_5w2h", schema="pdca")

# Tabela pdca.meta

def carregar_metas(mapa_ciclo_ids, mapa_plano_ids):
    logging.info("Migrando Tabela: meta -> pdca.meta")
    df = pd.read_sql("SELECT * FROM meta", engine_origem)

    if df.empty:
        logging.info("Nenhuma meta encontrada para migração.")
        return

    df = df[df["id_ciclo"].isin(mapa_ciclo_ids.keys()) & df["id_plano_acao"].isin(mapa_plano_ids.keys())]
    if df.empty:
        logging.info("Nenhuma meta encontrada para migração.")
        return

    status_map = {
        "ABAIXO_DO_ESPERADO": "EM_ANDAMENTO",
        "REGULAR": "EM_ANDAMENTO",
        "ACIMA_DO_ESPERADO": "ATINGIDA"
    }

    prioridade_map = {
        "BAIXO": "BAIXA",
        "MEDIO": "MEDIA",
        "ALTO": "ALTA"
    }

    df_destino = pd.DataFrame({
        "id": df["id_meta"],
        "id_ciclo": df["id_ciclo"],
        "id_plano_acao": df["id_plano_acao"],
        "objetivo": (df["descricao_meta"].fillna("") + " - " + df["objetivo"].fillna("")).str.strip(" - "),
        "valor_base": 0.00,
        "valor_alvo": 0.00,
        "unidade": None,
        "prazo": df["prazo"],
        "status": df["status"].map(status_map).fillna("EM_ANDAMENTO"),
        "prioridade": df["prioridade"].map(prioridade_map).fillna("MEDIA"),
        "area": None,
        "categoria": None,
        "criado_em": df["criado_em"]
    })

    ids_existentes = pd.read_sql("SELECT id FROM pdca.meta", engine_destino)["id"].tolist()

    df_destino = df_destino[~df_destino["id"].isin(ids_existentes)]

    if not df_destino.empty:
        inserir_dataframe(df_destino, "meta", schema="pdca")

# Tabela pdca.tarefa

def carregar_tarefas(mapa_plano_ids, mapa_colaborador_ids):
    logging.info("Migrando Tabela: tarefa -> pdca.tarefa")
    df = pd.read_sql("SELECT * FROM tarefa", engine_origem)

    if df.empty:
        logging.info("Nenhuma tarefa encontrada para migração.")
        return

    df = df[df["id_plano_acao"].isin(mapa_plano_ids.keys()) & df["id_colaborador"].isin(mapa_colaborador_ids.keys())]
    if df.empty:
        logging.info("Nenhuma tarefa encontrada para migração.")
        return

    status_map = {
        "NAO_INICIADO": "PENDENTE",
        "INICIADO": "EM_ANDAMENTO",
        "FINALIZADO": "CONCLUIDA"
    }

    prioridade_map = {
        "BAIXO": "BAIXA",
        "MEDIO": "MEDIA",
        "ALTO": "ALTA"
    }

    df_destino = pd.DataFrame({
        "id": df["id_tarefa"],
        "id_plano_acao": df["id_plano_acao"], 
        "id_responsavel": df["id_colaborador"],
        "titulo": df["titulo"].str.strip(),
        "descricao": df["descricao"].fillna("Sem descrição"),
        "prioridade": df["prioridade"].map(prioridade_map).fillna("MEDIA"),
        "status": df["status"].map(status_map).fillna("PENDENTE"),
        "data_inicio_real": df["dt_inicio"],
        "data_fim_prevista": df["dt_entrega"].fillna(pd.to_datetime(df["dt_inicio"]) + pd.Timedelta(days=30)),
        "criado_em": pd.Timestamp.now()
    })

    ids_existentes = pd.read_sql("SELECT id FROM pdca.tarefa", engine_destino)["id"].tolist()

    planos_validos = pd.read_sql("SELECT id FROM pdca.plano_acao", engine_destino)["id"].tolist()

    df_destino = df_destino[df_destino["id_plano_acao"].isin(planos_validos)]

    df_destino = df_destino[~df_destino["id"].isin(ids_existentes)]

    if not df_destino.empty:
        inserir_dataframe(df_destino, "tarefa", schema="pdca")

# Tabela pdca.problema

def carregar_problemas(mapa_ciclo_ids, mapa_colaborador_ids):
    logging.info("Migrando Tabela: problema -> pdca.problema")
    df = pd.read_sql("SELECT * FROM problema", engine_origem)

    if df.empty:
        logging.info("Nenhum problema encontrado para migração.")
        return

    df = df[df["id_ciclo"].isin(mapa_ciclo_ids.keys()) & df["id_colaborador"].isin(mapa_colaborador_ids.keys())]
    if df.empty:
        logging.info("Nenhum problema encontrado para migração.")
        return

    status_map = {
        "EM_ANALISE": "EM_ANALISE",
        "EM_RESOLUCAO": "ABERTO",
        "RESOLVIDO": "RESOLVIDO"
    }

    df_destino = pd.DataFrame({
        "id": df["id_problema"],
        "id_ciclo": df["id_ciclo"],
        "id_problema_pai": None,
        "criado_por": df["id_colaborador"],
        "titulo": df["titulo"].str.strip(),
        "descricao": df["descricao"].str.strip(),
        "peso": 0.50, 
        "status": df["status"].map(status_map).fillna("EM_ANALISE"),
        "origem": "IMPORTACAO",
        "persistente": False,
        "criado_em": df["encontrado_em"]
    })

    ids_existentes = pd.read_sql("SELECT id FROM pdca.problema", engine_destino)["id"].tolist()

    df_destino = df_destino[~df_destino["id"].isin(ids_existentes)]

    if not df_destino.empty:
        inserir_dataframe(df_destino, "problema", schema="pdca")


# ATUALIZAÇÃO DE SEQUÊNCIAS DO POSTGRES

def atualizar_sequences():
    logging.info("Atualizando sequências de IDs no banco de destino...")
    queries = [
        "SELECT setval('public.empresa_id_seq', COALESCE((SELECT MAX(id) FROM public.empresa), 1));",
        "SELECT setval('public.usuario_sistema_id_seq', COALESCE((SELECT MAX(id) FROM public.usuario_sistema), 1));",
        "SELECT setval('public.colaborador_id_seq', COALESCE((SELECT MAX(id) FROM public.colaborador), 1));",
        "SELECT setval('pdca.ciclo_id_seq', COALESCE((SELECT MAX(id) FROM pdca.ciclo), 1));",
        "SELECT setval('pdca.plano_acao_id_seq', COALESCE((SELECT MAX(id) FROM pdca.plano_acao), 1));",
        "SELECT setval('pdca.plano_5w2h_id_seq', COALESCE((SELECT MAX(id) FROM pdca.plano_5w2h), 1));",
        "SELECT setval('pdca.meta_id_seq', COALESCE((SELECT MAX(id) FROM pdca.meta), 1));",
        "SELECT setval('pdca.tarefa_id_seq', COALESCE((SELECT MAX(id) FROM pdca.tarefa), 1));",
        "SELECT setval('pdca.problema_id_seq', COALESCE((SELECT MAX(id) FROM pdca.problema), 1));"
    ]
    with engine_destino.connect() as conn:
        for q in queries:
            conn.execute(text(q))
        conn.commit()


# EXECUÇÃO PRINCIPAL

def executar_rpa():
    try:
        logging.info("--- INICIANDO PROCESSO DE RPA ---")

        mapa_empresa_ids = carregar_empresa()
        mapa_colaborador_ids = carregar_usuarios_e_colaboradores(mapa_empresa_ids)
        mapa_ciclo_ids = carregar_ciclos(mapa_empresa_ids, mapa_colaborador_ids)
        mapa_plano_ids = carregar_planos_acao(mapa_ciclo_ids, mapa_colaborador_ids)
        
        carregar_plano_5w2h(mapa_plano_ids, mapa_colaborador_ids)
        carregar_metas(mapa_ciclo_ids, mapa_plano_ids)
        carregar_tarefas(mapa_plano_ids, mapa_colaborador_ids)
        carregar_problemas(mapa_ciclo_ids, mapa_colaborador_ids)

        atualizar_sequences()
        logging.info("--- PROCESSO CONCLUÍDO COM SUCESSO ---")
    except Exception as e:
        logging.error(f"Falha na execução da migração: {str(e)}", exc_info=True)


if __name__ == "__main__":
    executar_rpa()