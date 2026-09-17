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

    if df.empty:
        return

    tamanho_map = {"PEQUENA": "PEQUENA", "MEDIA": "MEDIA", "GRANDE": "GRANDE"}

    df_destino = pd.DataFrame({
        "id": df["empresa_id"],
        "cnpj": df["cnpj"].apply(limpar_digitos).str.zfill(14),
        "nome": df["nome"].str.strip(),
        "tamanho_empresa": df["tamanho"].map(tamanho_map).fillna("MEDIA"),
        "setor_empresa": df["setor"].str.strip(),
        "status": df["status"].map({"ATIVA": "ATIVO", "INATIVA": "INATIVO"}).fillna("ATIVO"),
        "criado_em": pd.Timestamp.now()
    })

    df_destino.to_sql("empresa", engine_destino, schema="public", if_exists="append", index=False)

# Tabelas usuario_sistema, colaborador, email_colaborador, telefone_colaborador

def carregar_usuarios_e_colaboradores():
    logging.info("Migrando: colaborador -> public.usuario_sistema, public.colaborador, public.email_colaborador, public.telefone_colaborador")
    df_colab = pd.read_sql("SELECT * FROM colaborador", engine_origem)

    if df_colab.empty:
        return

    df_colab["cpf_limpo"] = df_colab["cpf"].apply(limpar_digitos).str.zfill(11)
    df_colab["telefone_limpo"] = df_colab["telefone"].apply(limpar_digitos)
    df_colab["email_limpo"] = df_colab["email"].apply(sanitizar_email)

    # Tabela public.usuario_sistema
    df_usuario = pd.DataFrame({
        "id": df_colab["colaborador_id"],
        "id_empresa": df_colab["empresa_id"],
        "nome": (df_colab["nome"].str.strip() + " " + df_colab["sobrenome"].str.strip()),
        "email_login": df_colab["email_limpo"],
        "firebase_uid": None, 
        "tipo_usuario": "COLABORADOR",
        "status": "PENDENTE", 
        "criado_em": pd.Timestamp.now()
    })
    df_usuario.to_sql("usuario_sistema", engine_destino, schema="public", if_exists="append", index=False)

    # Tabela public.colaborador
    df_colaborador_detalhe = pd.DataFrame({
        "id": df_colab["colaborador_id"],
        "id_empresa": df_colab["empresa_id"],
        "id_usuario": df_colab["colaborador_id"],
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
    df_colaborador_detalhe.to_sql("colaborador", engine_destino, schema="public", if_exists="append", index=False)

    # Tabela public.email_colaborador
    df_email = pd.DataFrame({
        "id_colaborador": df_colab["colaborador_id"],
        "email": df_colab["email_limpo"],
        "principal": True,
        "criado_em": pd.Timestamp.now()
    })
    df_email.dropna(subset=["email"]).to_sql("email_colaborador", engine_destino, schema="public", if_exists="append", index=False)

    # Tabela public.telefone_colaborador
    df_tel = pd.DataFrame({
        "id_colaborador": df_colab["colaborador_id"],
        "numero_telefone": df_colab["telefone_limpo"],
        "principal": True,
        "criado_em": pd.Timestamp.now()
    })

   
    df_tel = df_tel[df_tel["numero_telefone"].str.len().between(10, 15)]
    df_tel.to_sql("telefone_colaborador", engine_destino, schema="public", if_exists="append", index=False)


# Tabela pdca.ciclo

def carregar_ciclos():
    logging.info("Migrando Tabela: ciclo -> pdca.ciclo")
    df = pd.read_sql("SELECT * FROM ciclo", engine_origem)

    if df.empty:
        return

    status_map = {
        "NAO_INICIADO": "PLANEJAMENTO",
        "INICIADO": "EXECUCAO",
        "FINALIZADO": "CONCLUIDO"
    }

    df_destino = pd.DataFrame({
        "id": df["ciclo_id"],
        "id_empresa": df["empresa_id"],
        "id_responsavel": df["responsavel_id"],
        "titulo": df["nome"].str.strip(),
        "descricao": df["descricao"].fillna("Sem descrição"),
        "status": df["status"].map(status_map).fillna("PLANEJAMENTO"),
        "data_inicio": df["dt_inicio"],
        "data_estimada_fim": df["dt_fim"].fillna(pd.to_datetime(df["dt_inicio"]) + pd.Timedelta(days=30)),
        "criado_em": df["criado_em"]
    })

    df_destino.to_sql("ciclo", engine_destino, schema="pdca", if_exists="append", index=False)

# Tabela pdca.plano_acao

def carregar_planos_acao():
    logging.info("Migrando Tabela: plano_acao -> pdca.plano_acao")
    df = pd.read_sql("SELECT * FROM plano_acao", engine_origem)

    if df.empty:
        return

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
        "id": df["plano_acao_id"],
        "id_ciclo": df["ciclo_id"],
        "nome": df["nome"].str.strip(),
        "objetivo": df["descricao"],
        "prioridade": df["prioridade"].map(prioridade_map).fillna("MEDIA"),
        "status": df["status"].map(status_map).fillna("RASCUNHO"),
        "origem": "IMPORTACAO",
        "criado_por": df["criador_id"],
        "criado_em": pd.Timestamp.now()
    })

    df_destino.to_sql("plano_acao", engine_destino, schema="pdca", if_exists="append", index=False)

# Tabela pdca.plano_5w2h

def carregar_plano_5w2h():
    logging.info("Migrando Tabela: plano_acao5w2h -> pdca.plano_5w2h")
    df = pd.read_sql("SELECT * FROM plano_acao5w2h", engine_origem)

    if df.empty:
        return

    df_destino = pd.DataFrame({
        "id": df["plano_acao_5w2h_id"],
        "id_plano_acao": df["plano_acao_id"],
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

    df_destino.to_sql("plano_5w2h", engine_destino, schema="pdca", if_exists="append", index=False)

# Tabela pdca.meta

def carregar_metas():
    logging.info("Migrando Tabela: meta -> pdca.meta")
    df = pd.read_sql("SELECT * FROM meta", engine_origem)

    if df.empty:
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
        "id": df["meta_id"],
        "id_ciclo": df["ciclo_id"],
        "id_plano_acao": df["plano_acao_id"],
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

    df_destino.to_sql("meta", engine_destino, schema="pdca", if_exists="append", index=False)

# Tabela pdca.tarefa

def carregar_tarefas():
    logging.info("Migrando Tabela: tarefa -> pdca.tarefa")
    df = pd.read_sql("SELECT * FROM tarefa", engine_origem)

    if df.empty:
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
        "id": df["tarefa_id"],
        "id_plano_acao": df["plano_acao_id"], 
        "id_responsavel": df["colaborador_id"],
        "titulo": df["titulo"].str.strip(),
        "descricao": df["descricao"].fillna("Sem descrição"),
        "prioridade": df["prioridade"].map(prioridade_map).fillna("MEDIA"),
        "status": df["status"].map(status_map).fillna("PENDENTE"),
        "data_inicio_real": df["dt_inicio"],
        "data_fim_prevista": df["dt_entrega"].fillna(pd.to_datetime(df["dt_inicio"]) + pd.Timedelta(days=30)),
        "criado_em": pd.Timestamp.now()
    })

    df_destino.to_sql("tarefa", engine_destino, schema="pdca", if_exists="append", index=False)

# Tabela pdca.problema

def carregar_problemas():
    logging.info("Migrando Tabela: problema -> pdca.problema")
    df = pd.read_sql("SELECT * FROM problema", engine_origem)

    if df.empty:
        return

    status_map = {
        "EM_ANALISE": "EM_ANALISE",
        "EM_RESOLUCAO": "ABERTO",
        "RESOLVIDO": "RESOLVIDO"
    }

    df_destino = pd.DataFrame({
        "id": df["problema_id"],
        "id_ciclo": df["ciclo_id"],
        "id_problema_pai": None,
        "criado_por": df["colaborador_id"],
        "titulo": df["titulo"].str.strip(),
        "descricao": df["descricao"].str.strip(),
        "peso": 0.50, 
        "status": df["status"].map(status_map).fillna("EM_ANALISE"),
        "origem": "IMPORTACAO",
        "persistente": False,
        "criado_em": df["encontrado_em"]
    })

    df_destino.to_sql("problema", engine_destino, schema="pdca", if_exists="append", index=False)


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
        logging.info("--- INICIANDO PROCESSO DE ETL/RPA ---")
        carregar_empresa()
        carregar_usuarios_e_colaboradores()
        carregar_ciclos()
        carregar_planos_acao()
        carregar_plano_5w2h()
        carregar_metas()
        carregar_tarefas()
        carregar_problemas()
        atualizar_sequences()
        logging.info("--- PROCESSO CONCLUÍDO COM SUCESSO ---")
    except Exception as e:
        logging.error(f"Falha na execução da migração: {str(e)}")


if __name__ == "__main__":
    executar_rpa()