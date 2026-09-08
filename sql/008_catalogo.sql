-- Catalogo de dados

INSERT INTO auditoria.catalogo_dados (
    nome_schema, tabela, coluna, tipo_dado, eh_pk, eh_fk, referencia, obrigatorio, regra_negocio, nivel_acesso, observacao
) VALUES

-- SCHEMA: public

-- public.empresa
('public', 'empresa', 'id', 'BIGSERIAL', TRUE, FALSE, NULL, TRUE, 'Gerado automaticamente pelo banco de dados.', 'INTERNO', 'Identificador único da empresa.'),
('public', 'empresa', 'cnpj', 'CHAR(14)', FALSE, FALSE, NULL, TRUE, 'Apenas números (14 dígitos). Deve ser único no sistema.', 'PUBLICO', 'CNPJ da empresa, armazenado apenas com números.'),
('public', 'empresa', 'nome', 'VARCHAR(160)', FALSE, FALSE, NULL, TRUE, 'Mínimo de 2 caracteres após remover espaços.', 'PUBLICO', 'Nome empresarial.'),
('public', 'empresa', 'tamanho_empresa', 'VARCHAR(40)', FALSE, FALSE, NULL, TRUE, 'Valores aceitos: PEQUENA, MEDIA ou GRANDE.', 'PUBLICO', 'Porte da empresa: PEQUENA, MEDIA ou GRANDE.'),
('public', 'empresa', 'setor_empresa', 'VARCHAR(100)', FALSE, FALSE, NULL, TRUE, 'Segmento de atuação da empresa.', 'PUBLICO', 'Setor ou segmento de atuação da empresa.'),
('public', 'empresa', 'status', 'VARCHAR(40)', FALSE, FALSE, NULL, TRUE, 'Valores aceitos: ATIVO, INATIVO, PENDENTE, BLOQUEADO, ARQUIVADO.', 'INTERNO', 'Situação cadastral da empresa na plataforma.'),
('public', 'empresa', 'criado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, TRUE, 'Valor padrão obtido com NOW().', 'INTERNO', 'Data e hora de criação do registro.'),
('public', 'empresa', 'atualizado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, FALSE, 'Data/hora da última alteração.', 'INTERNO', 'Data e hora da última atualização do registro.'),

-- public.usuario_sistema
('public', 'usuario_sistema', 'id', 'BIGSERIAL', TRUE, FALSE, NULL, TRUE, 'Gerado automaticamente pelo banco de dados.', 'INTERNO', 'Identificador único do usuário.'),
('public', 'usuario_sistema', 'id_empresa', 'BIGINT', FALSE, TRUE, 'public.empresa(id)', TRUE, 'ON DELETE CASCADE.', 'INTERNO', 'Empresa à qual o usuário pertence.'),
('public', 'usuario_sistema', 'nome', 'VARCHAR(160)', FALSE, FALSE, NULL, TRUE,  'Nome do usuário.', 'SENSIVEL', 'Nome do usuário.'),
('public', 'usuario_sistema', 'email_login', 'VARCHAR(254)', FALSE, FALSE, NULL, TRUE, 'Deve corresponder ao padrão de e-mail válido. Único no sistema.', 'SENSIVEL', 'E-mail utilizado para login no sistema.'),
('public', 'usuario_sistema', 'firebase_uid', 'VARCHAR(128)', FALSE, FALSE, NULL, FALSE, 'Obrigatório caso o status seja ATIVO.', 'RESTRITO', 'Identificador único do usuário no Firebase Authentication.'),
('public', 'usuario_sistema', 'tipo_usuario', 'VARCHAR(40)', FALSE, FALSE, NULL, TRUE, 'Valores aceitos: ADMIN, GESTOR ou COLABORADOR.', 'INTERNO', 'Perfil de acesso do usuário: ADMIN, GESTOR ou COLABORADOR.'),
('public', 'usuario_sistema', 'status', 'VARCHAR(40)', FALSE, FALSE, NULL, TRUE, 'Valores aceitos: ATIVO, INATIVO, PENDENTE, BLOQUEADO, ARQUIVADO.', 'INTERNO', 'Situação do usuário no sistema.'),
('public', 'usuario_sistema', 'criado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, TRUE, 'Valor padrão obtido com NOW().', 'INTERNO', 'Data e hora de criação do registro.'),
('public', 'usuario_sistema', 'atualizado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, FALSE, 'Data/hora da última alteração.', 'INTERNO', 'Data e hora da última atualização do registro.'),

-- public.convite_usuario
('public', 'convite_usuario', 'id', 'BIGSERIAL', TRUE, FALSE, NULL, TRUE, 'Gerado automaticamente.', 'INTERNO', 'Identificador único do convite.'),
('public', 'convite_usuario', 'id_usuario', 'BIGINT', FALSE, TRUE, 'public.usuario_sistema(id)', TRUE, 'ON DELETE CASCADE.', 'INTERNO', 'Usuário convidado.'),
('public', 'convite_usuario', 'email_destino', 'VARCHAR(254)', FALSE, FALSE, NULL, TRUE, 'Validação de padrão de e-mail.', 'SENSIVEL', 'Endereço de e-mail para o qual o convite foi enviado.'),
('public', 'convite_usuario', 'token_hash', 'VARCHAR(255)', FALSE, FALSE, NULL, TRUE, 'Hash único para validação.', 'RESTRITO', 'Hash único do token utilizado para validar o convite.'),
('public', 'convite_usuario', 'status', 'VARCHAR(20)', FALSE, FALSE, NULL, TRUE, 'Valores: PENDENTE, USADO, REVOGADO, EXPIRADO.', 'INTERNO', 'Situação do convite: PENDENTE, USADO, REVOGADO ou EXPIRADO.'),
('public', 'convite_usuario', 'expira_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, TRUE, 'Deve ser maior que a data de criação.', 'INTERNO', 'Data e hora de expiração do convite.'),
('public', 'convite_usuario', 'usado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, FALSE, 'Preenchido obrigatoriamente se status = USADO.', 'INTERNO', 'Data e hora de utilização do convite, quando utilizado.'),
('public', 'convite_usuario', 'criado_por', 'BIGINT', FALSE, TRUE, 'public.usuario_sistema(id)', TRUE, 'ON DELETE RESTRICT.', 'INTERNO', 'Usuário que criou o convite.'),
('public', 'convite_usuario', 'criado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, TRUE, 'Valor padrão obtido com NOW().', 'INTERNO', 'Data e hora de criação do convite.'),

-- public.colaborador
('public', 'colaborador', 'id', 'BIGSERIAL', TRUE, FALSE, NULL, TRUE, 'Gerado automaticamente.', 'INTERNO', 'Identificador único do colaborador.'),
('public', 'colaborador', 'id_empresa', 'BIGINT', FALSE, TRUE, 'public.empresa(id)', TRUE, 'ON DELETE CASCADE.', 'INTERNO', 'Empresa à qual o colaborador pertence.'),
('public', 'colaborador', 'id_usuario', 'BIGINT', FALSE, TRUE, 'public.usuario_sistema(id)', TRUE, 'ON DELETE CASCADE. Chave única.', 'INTERNO', 'Usuário do sistema associado ao colaborador.'),
('public', 'colaborador', 'cpf', 'CHAR(11)', FALSE, FALSE, NULL, TRUE, 'Exatamente 11 dígitos numéricos. Único no sistema.', 'SENSIVEL', 'CPF do colaborador, armazenado apenas com números.'),
('public', 'colaborador', 'nome', 'VARCHAR(160)', FALSE, FALSE, NULL, TRUE, 'Nome do colaborador.', 'SENSIVEL', 'Nome do colaborador.'),
('public', 'colaborador', 'cargo', 'VARCHAR(100)', FALSE, FALSE, NULL, TRUE, 'Cargo ocupado.', 'INTERNO', 'Cargo ocupado pelo colaborador.'),
('public', 'colaborador', 'area', 'VARCHAR(100)', FALSE, FALSE, NULL, TRUE, 'Área ou departamento.', 'INTERNO', 'Área ou departamento do colaborador.'),
('public', 'colaborador', 'data_nascimento', 'DATE', FALSE, FALSE, NULL, TRUE, 'O colaborador deve ter no mínimo 18 anos.', 'SENSIVEL', 'Data de nascimento do colaborador.'),
('public', 'colaborador', 'data_contratacao', 'DATE', FALSE, FALSE, NULL, TRUE, 'Deve ser maior ou igual à data de nascimento.', 'INTERNO', 'Data de contratação do colaborador.'),
('public', 'colaborador', 'permissao_gestor', 'BOOLEAN', FALSE, FALSE, NULL, TRUE, 'Indica se possui privilégios de gestor.', 'INTERNO', 'Indica se o colaborador possui permissão de gestor.'),
('public', 'colaborador', 'status', 'VARCHAR(40)', FALSE, FALSE, NULL, TRUE, 'Valores aceitos: ATIVO, INATIVO, PENDENTE, BLOQUEADO, ARQUIVADO.', 'INTERNO', 'Situação do colaborador no sistema.'),
('public', 'colaborador', 'criado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, TRUE, 'Valor padrão obtido com NOW().', 'INTERNO', 'Data e hora de criação do registro.'),
('public', 'colaborador', 'atualizado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, FALSE, 'Data/hora da última alteração.', 'INTERNO', 'Data e hora da última atualização do registro.'),

-- public.endereco_empresa
('public', 'endereco_empresa', 'id', 'BIGSERIAL', TRUE, FALSE, NULL, TRUE, 'Gerado automaticamente.', 'INTERNO', 'Identificador único do endereço.'),
('public', 'endereco_empresa', 'id_empresa', 'BIGINT', FALSE, TRUE, 'public.empresa(id)', TRUE, 'ON DELETE CASCADE.', 'INTERNO', 'Empresa dona do endereço.'),
('public', 'endereco_empresa', 'cep', 'CHAR(8)', FALSE, FALSE, NULL, TRUE, 'Exatamente 8 dígitos numéricos.', 'PUBLICO', 'CEP do endereço, armazenado apenas com números.'),
('public', 'endereco_empresa', 'uf', 'CHAR(2)', FALSE, FALSE, NULL, TRUE, 'Duas letras maiúsculas (UF do Brasil).', 'PUBLICO', 'Unidade federativa do endereço.'),
('public', 'endereco_empresa', 'cidade', 'VARCHAR(100)', FALSE, FALSE, NULL, TRUE, 'Nome da cidade.', 'PUBLICO', 'Cidade do endereço.'),
('public', 'endereco_empresa', 'bairro', 'VARCHAR(100)', FALSE, FALSE, NULL, TRUE, 'Nome do bairro.', 'PUBLICO', 'Bairro do endereço.'),
('public', 'endereco_empresa', 'logradouro', 'VARCHAR(180)', FALSE, FALSE, NULL, TRUE, 'Rua, avenida, etc.', 'PUBLICO', 'Logradouro do endereço.'),
('public', 'endereco_empresa', 'numero_endereco', 'VARCHAR(20)', FALSE, FALSE, NULL, TRUE, 'Número do imóvel.', 'PUBLICO', 'Número do endereço.'),
('public', 'endereco_empresa', 'complemento', 'TEXT', FALSE, FALSE, NULL, FALSE, 'Complemento opcional.', 'PUBLICO', 'Complemento do endereço, quando houver.'),
('public', 'endereco_empresa', 'principal', 'BOOLEAN', FALSE, FALSE, NULL, TRUE, 'Indica se é o endereço principal da empresa.', 'INTERNO', 'Indica se este é o endereço principal da empresa.'),
('public', 'endereco_empresa', 'criado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, TRUE, 'Valor padrão obtido com NOW().', 'INTERNO', 'Data e hora de criação do registro.'),
('public', 'endereco_empresa', 'atualizado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, FALSE, 'Data/hora da última alteração.', 'INTERNO', 'Data e hora da última atualização do registro.'),

-- public.email_empresa
('public', 'email_empresa', 'id', 'BIGSERIAL', TRUE, FALSE, NULL, TRUE, 'Gerado automaticamente.', 'INTERNO', 'Identificador único do e-mail da empresa.'),
('public', 'email_empresa', 'id_empresa', 'BIGINT', FALSE, TRUE, 'public.empresa(id)', TRUE, 'ON DELETE CASCADE. Padrão único com e-mail.', 'INTERNO', 'Empresa dona do e-mail.'),
('public', 'email_empresa', 'email', 'VARCHAR(254)', FALSE, FALSE, NULL, TRUE, 'Formato válido de e-mail.', 'PUBLICO', 'Endereço de e-mail da empresa.'),
('public', 'email_empresa', 'principal', 'BOOLEAN', FALSE, FALSE, NULL, TRUE, 'Define o e-mail principal.', 'INTERNO', 'Indica se este é o e-mail principal da empresa.'),
('public', 'email_empresa', 'criado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, TRUE, 'Valor padrão obtido com NOW().', 'INTERNO', 'Data e hora de criação do registro.'),

-- public.telefone_empresa
('public', 'telefone_empresa', 'id', 'BIGSERIAL', TRUE, FALSE, NULL, TRUE, 'Gerado automaticamente.', 'INTERNO', 'Identificador único do telefone da empresa.'),
('public', 'telefone_empresa', 'id_empresa', 'BIGINT', FALSE, TRUE, 'public.empresa(id)', TRUE, 'ON DELETE CASCADE. Padrão único com numero_telefone.', 'INTERNO', 'Empresa dona do telefone.'),
('public', 'telefone_empresa', 'numero_telefone', 'VARCHAR(20)', FALSE, FALSE, NULL, TRUE, 'Apenas números.', 'PUBLICO', 'Número de telefone da empresa, armazenado apenas com números.'),
('public', 'telefone_empresa', 'principal', 'BOOLEAN', FALSE, FALSE, NULL, TRUE, 'Define o telefone principal.', 'INTERNO', 'Indica se este é o telefone principal da empresa.'),
('public', 'telefone_empresa', 'criado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, TRUE, 'Valor padrão obtido com NOW().', 'INTERNO', 'Data e hora de criação do registro.'),

-- public.email_colaborador
('public', 'email_colaborador', 'id', 'BIGSERIAL', TRUE, FALSE, NULL, TRUE, 'Gerado automaticamente.', 'INTERNO', 'Identificador único do e-mail do colaborador.'),
('public', 'email_colaborador', 'id_colaborador', 'BIGINT', FALSE, TRUE, 'public.colaborador(id)', TRUE, 'ON DELETE CASCADE. Único com e-mail.', 'INTERNO', 'Colaborador dono do e-mail.'),
('public', 'email_colaborador', 'email', 'VARCHAR(254)', FALSE, FALSE, NULL, TRUE, 'Validação de formato de e-mail.', 'SENSIVEL', 'Endereço de e-mail do colaborador.'),
('public', 'email_colaborador', 'principal', 'BOOLEAN', FALSE, FALSE, NULL, TRUE, 'Define o e-mail principal.', 'INTERNO', 'Indica se este é o e-mail principal do colaborador.'),
('public', 'email_colaborador', 'criado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, TRUE, 'Valor padrão obtido com NOW().', 'INTERNO', 'Data e hora de criação do registro.'),

-- public.telefone_colaborador
('public', 'telefone_colaborador', 'id', 'BIGSERIAL', TRUE, FALSE, NULL, TRUE, 'Gerado automaticamente.', 'INTERNO', 'Identificador único do telefone do colaborador.'),
('public', 'telefone_colaborador', 'id_colaborador', 'BIGINT', FALSE, TRUE, 'public.colaborador(id)', TRUE, 'ON DELETE CASCADE. Único com numero_telefone.', 'INTERNO', 'Colaborador dono do telefone.'),
('public', 'telefone_colaborador', 'numero_telefone', 'VARCHAR(20)', FALSE, FALSE, NULL, TRUE, 'Apenas números.', 'RESTRITO', 'Número de telefone do colaborador, armazenado apenas com números.'),
('public', 'telefone_colaborador', 'principal', 'BOOLEAN', FALSE, FALSE, NULL, TRUE, 'Define o telefone principal.', 'INTERNO', 'Indica se este é o telefone principal do colaborador.'),
('public', 'telefone_colaborador', 'criado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, TRUE, 'Valor padrão obtido com NOW().', 'INTERNO', 'Data e hora de criação do registro.'),

-- SCHEMA: pdca

-- pdca.ciclo
('pdca', 'ciclo', 'id', 'BIGSERIAL', TRUE, FALSE, NULL, TRUE, 'Gerado automaticamente.', 'INTERNO', 'Identificador único do ciclo PDCA.'),
('pdca', 'ciclo', 'id_empresa', 'BIGINT', FALSE, TRUE, 'public.empresa(id)', TRUE, 'ON DELETE CASCADE.', 'INTERNO', 'Empresa dona do ciclo.'),
('pdca', 'ciclo', 'id_responsavel', 'BIGINT', FALSE, TRUE, 'public.usuario_sistema(id)', TRUE, 'Usuário responsável.', 'INTERNO', 'Usuário responsável pelo ciclo.'),
('pdca', 'ciclo', 'id_ishikawa_mongo', 'INTEGER', FALSE, FALSE, NULL, FALSE, 'Chave de referência externa ao MongoDB.', 'INTERNO', 'Identificador do diagrama de Ishikawa armazenado em base externa.'),
('pdca', 'ciclo', 'titulo', 'VARCHAR(160)', FALSE, FALSE, NULL, TRUE, 'Título do ciclo.', 'INTERNO', 'Título do ciclo PDCA.'),
('pdca', 'ciclo', 'descricao', 'TEXT', FALSE, FALSE, NULL, TRUE, 'Descrição detalhada.', 'INTERNO', 'Descrição do objetivo e contexto do ciclo.'),
('pdca', 'ciclo', 'status', 'VARCHAR(40)', FALSE, FALSE, NULL, TRUE, 'PLANEJAMENTO, EXECUCAO, VERIFICACAO, PADRONIZACAO, CONCLUIDO, CANCELADO, PAUSADO.', 'INTERNO', 'Etapa ou situação atual do ciclo.'),
('pdca', 'ciclo', 'data_inicio', 'DATE', FALSE, FALSE, NULL, TRUE, 'Data inicial.', 'INTERNO', 'Data de início do ciclo.'),
('pdca', 'ciclo', 'data_estimada_fim', 'DATE', FALSE, FALSE, NULL, TRUE, 'Deve ser maior ou igual à data_inicio.', 'INTERNO', 'Data estimada para encerramento do ciclo.'),
('pdca', 'ciclo', 'data_fim_real', 'DATE', FALSE, FALSE, NULL, FALSE, 'Se preenchida, deve ser maior ou igual à data_inicio.', 'INTERNO', 'Data real de encerramento do ciclo, quando concluído.'),
('pdca', 'ciclo', 'criado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, TRUE, 'Valor padrão NOW().', 'INTERNO', 'Data e hora de criação do registro.'),
('pdca', 'ciclo', 'atualizado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, FALSE, 'Data/hora da última alteração.', 'INTERNO', 'Data e hora da última atualização do registro.'),

-- pdca.plano_acao
('pdca', 'plano_acao', 'id', 'BIGSERIAL', TRUE, FALSE, NULL, TRUE, 'Gerado automaticamente.', 'INTERNO', 'Identificador único do plano de ação.'),
('pdca', 'plano_acao', 'id_ciclo', 'BIGINT', FALSE, TRUE, 'pdca.ciclo(id)', TRUE, 'ON DELETE CASCADE.', 'INTERNO', 'Ciclo PDCA ao qual o plano pertence.'),
('pdca', 'plano_acao', 'nome', 'VARCHAR(160)', FALSE, FALSE, NULL, TRUE, 'Nome descritivo.', 'INTERNO', 'Nome do plano de ação.'),
('pdca', 'plano_acao', 'objetivo', 'TEXT', FALSE, FALSE, NULL, FALSE, 'Objetivo do plano.', 'SENSIVEL', 'Objetivo do plano de ação.'),
('pdca', 'plano_acao', 'prioridade', 'VARCHAR(40)', FALSE, FALSE, NULL, TRUE, 'BAIXA, MEDIA, ALTA, CRITICA.', 'SENSIVEL', 'Prioridade do plano.'),
('pdca', 'plano_acao', 'status', 'VARCHAR(40)', FALSE, FALSE, NULL, TRUE, 'RASCUNHO, APROVADO, EM_EXECUCAO, CONCLUIDO, CANCELADO.', 'INTERNO', 'Situação atual do plano.'),
('pdca', 'plano_acao', 'origem', 'VARCHAR(40)', FALSE, FALSE, NULL, TRUE, 'MANUAL, IA, FORMULARIO, IMPORTACAO, SISTEMA.', 'INTERNO', 'Origem de criação do plano.'),
('pdca', 'plano_acao', 'criado_por', 'BIGINT', FALSE, TRUE, 'public.usuario_sistema(id)', TRUE, 'Usuário criador.', 'INTERNO', 'Usuário que criou o plano.'),
('pdca', 'plano_acao', 'criado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, TRUE, 'Valor padrão NOW().', 'INTERNO', 'Data e hora de criação do registro.'),
('pdca', 'plano_acao', 'atualizado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, FALSE, 'Data de atualização.', 'INTERNO', 'Data e hora da última atualização do registro.'),

-- pdca.meta
('pdca', 'meta', 'id', 'BIGSERIAL', TRUE, FALSE, NULL, TRUE, 'Gerado automaticamente.', 'INTERNO', 'Identificador único da meta.'),
('pdca', 'meta', 'id_ciclo', 'BIGINT', FALSE, TRUE, 'pdca.ciclo(id)', TRUE, 'ON DELETE CASCADE.', 'INTERNO', 'Ciclo PDCA ao qual a meta pertence.'),
('pdca', 'meta', 'id_plano_acao', 'BIGINT', FALSE, TRUE, 'pdca.plano_acao(id)', TRUE, 'Plano de ação vinculado.', 'INTERNO', 'Plano de ação ao qual a meta pertence.'),
('pdca', 'meta', 'objetivo', 'TEXT', FALSE, FALSE, NULL, TRUE, 'Descrição da meta.', 'SENSIVEL', 'Objetivo mensurável da meta.'),
('pdca', 'meta', 'valor_base', 'NUMERIC(15,2)', FALSE, FALSE, NULL, FALSE, 'Deve ser maior ou igual a 0.', 'INTERNO', 'Valor inicial ou linha de base da meta.'),
('pdca', 'meta', 'valor_alvo', 'NUMERIC(15,2)', FALSE, FALSE, NULL, FALSE, 'Deve ser maior ou igual a 0.', 'SENSIVEL', 'Valor esperado para atingir a meta.'),
('pdca', 'meta', 'unidade', 'VARCHAR(30)', FALSE, FALSE, NULL, FALSE, 'Unidade de medida (ex: %, R$, un).', 'INTERNO', 'Unidade de medida da meta.'),
('pdca', 'meta', 'prazo', 'DATE', FALSE, FALSE, NULL, TRUE, 'Data limite da meta.', 'SENSIVEL', 'Prazo para cumprimento da meta.'),
('pdca', 'meta', 'status', 'VARCHAR(40)', FALSE, FALSE, NULL, TRUE, 'NAO_INICIADA, EM_ANDAMENTO, ATINGIDA, PARCIALMENTE_ATINGIDA, NAO_ATINGIDA, CANCELADA.', 'INTERNO', 'Situação atual da meta.'),
('pdca', 'meta', 'prioridade', 'VARCHAR(40)', FALSE, FALSE, NULL, TRUE, 'BAIXA, MEDIA, ALTA, CRITICA.', 'INTERNO', 'Prioridade da meta.'),
('pdca', 'meta', 'area', 'VARCHAR(100)', FALSE, FALSE, NULL, FALSE, 'Área responsável.', 'INTERNO', 'Área responsável ou impactada pela meta.'),
('pdca', 'meta', 'categoria', 'VARCHAR(100)', FALSE, FALSE, NULL, FALSE, 'Categoria da meta.', 'INTERNO', 'Categoria de classificação da meta.'),
('pdca', 'meta', 'criado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, TRUE, 'Valor padrão NOW().', 'INTERNO', 'Data e hora de criação do registro.'),
('pdca', 'meta', 'atualizado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, FALSE, 'Data/hora da última alteração.', 'INTERNO', 'Data e hora da última atualização do registro.'),

-- pdca.treinamento
('pdca', 'treinamento', 'id', 'BIGSERIAL', TRUE, FALSE, NULL, TRUE, 'Gerado automaticamente.', 'INTERNO', 'Identificador único do treinamento.'),
('pdca', 'treinamento', 'id_ciclo', 'BIGINT', FALSE, TRUE, 'pdca.ciclo(id)', TRUE, 'ON DELETE CASCADE.', 'INTERNO', 'Ciclo PDCA ao qual o treinamento pertence.'),
('pdca', 'treinamento', 'id_responsavel', 'BIGINT', FALSE, TRUE, 'public.usuario_sistema(id)', TRUE, 'Responsável pela instrução/gestão.', 'INTERNO', 'Usuário responsável pelo treinamento.'),
('pdca', 'treinamento', 'titulo', 'VARCHAR(160)', FALSE, FALSE, NULL, TRUE, 'Nome do treinamento.', 'INTERNO', 'Título do treinamento.'),
('pdca', 'treinamento', 'descricao', 'TEXT', FALSE, FALSE, NULL, FALSE, 'Detalhes do conteúdo.', 'INTERNO', 'Descrição do treinamento.'),
('pdca', 'treinamento', 'data_treinamento', 'DATE', FALSE, FALSE, NULL, TRUE, 'Data de realização/agendamento.', 'INTERNO', 'Data planejada ou realizada do treinamento.'),
('pdca', 'treinamento', 'obrigatorio', 'BOOLEAN', FALSE, FALSE, NULL, TRUE, 'Padrão TRUE.', 'INTERNO', 'Indica se o treinamento é obrigatório.'),
('pdca', 'treinamento', 'criado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, TRUE, 'Valor padrão NOW().', 'INTERNO', 'Data e hora de criação do registro.'),
('pdca', 'treinamento', 'atualizado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, FALSE, 'Última atualização.', 'INTERNO', 'Data e hora da última atualização do registro.'),

-- pdca.verificacao_resultado
('pdca', 'verificacao_resultado', 'id', 'BIGSERIAL', TRUE, FALSE, NULL, TRUE, 'Gerado automaticamente.', 'INTERNO', 'Identificador único da verificação.'),
('pdca', 'verificacao_resultado', 'id_ciclo', 'BIGINT', FALSE, TRUE, 'pdca.ciclo(id)', TRUE, 'ON DELETE CASCADE.', 'INTERNO', 'Ciclo PDCA verificado.'),
('pdca', 'verificacao_resultado', 'criado_por', 'BIGINT', FALSE, TRUE, 'public.usuario_sistema(id)', TRUE, 'Avaliador do resultado.', 'INTERNO', 'Usuário que registrou a verificação.'),
('pdca', 'verificacao_resultado', 'status', 'VARCHAR(40)', FALSE, FALSE, NULL, TRUE, 'NAO_VERIFICADO, APROVADO, PARCIAL, REPROVADO.', 'INTERNO', 'Resultado da verificação.'),
('pdca', 'verificacao_resultado', 'resumo', 'TEXT', FALSE, FALSE, NULL, TRUE, 'Resumo do resultado obtido.', 'INTERNO', 'Resumo da verificação realizada.'),
('pdca', 'verificacao_resultado', 'observacao', 'TEXT', FALSE, FALSE, NULL, FALSE, 'Observações adicionais.', 'INTERNO', 'Observações adicionais da verificação.'),
('pdca', 'verificacao_resultado', 'criado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, TRUE, 'Valor padrão NOW().', 'INTERNO', 'Data e hora de criação do registro.'),

-- pdca.problema
('pdca', 'problema', 'id', 'BIGSERIAL', TRUE, FALSE, NULL, TRUE, 'Gerado automaticamente.', 'INTERNO', 'Identificador único do problema.'),
('pdca', 'problema', 'id_ciclo', 'BIGINT', FALSE, TRUE, 'pdca.ciclo(id)', TRUE, 'ON DELETE CASCADE.', 'INTERNO', 'Ciclo PDCA ao qual o problema pertence.'),
('pdca', 'problema', 'id_problema_pai', 'BIGINT', FALSE, TRUE, 'pdca.problema(id)', FALSE, 'ON DELETE CASCADE. Auto-relacionamento.', 'INTERNO', 'Problema superior em uma hierarquia de problemas.'),
('pdca', 'problema', 'criado_por', 'BIGINT', FALSE, TRUE, 'public.usuario_sistema(id)', TRUE, 'Usuário relator.', 'INTERNO', 'Usuário que registrou o problema.'),
('pdca', 'problema', 'titulo', 'VARCHAR(160)', FALSE, FALSE, NULL, TRUE, 'Título do problema.', 'SENSIVEL', 'Título do problema.'),
('pdca', 'problema', 'descricao', 'TEXT', FALSE, FALSE, NULL, TRUE, 'Detalhamento.', 'SENSIVEL', 'Descrição detalhada do problema.'),
('pdca', 'problema', 'peso', 'NUMERIC(3,2)', FALSE, FALSE, NULL, TRUE, 'Valor decimal de 0 a 1.', 'SENSIVEL', 'Peso relativo do problema para priorização.'),
('pdca', 'problema', 'status', 'VARCHAR(40)', FALSE, FALSE, NULL, TRUE, 'ABERTO, EM_ANALISE, PRIORIZADO, RESOLVIDO, DESCARTADO.', 'INTERNO', 'Situação atual do problema.'),
('pdca', 'problema', 'origem', 'VARCHAR(40)', FALSE, FALSE, NULL, TRUE, 'MANUAL, IA, FORMULARIO, IMPORTACAO, SISTEMA.', 'INTERNO', 'Origem de identificação do problema.'),
('pdca', 'problema', 'persistente', 'BOOLEAN', FALSE, FALSE, NULL, TRUE, 'Padrão FALSE.', 'SENSIVEL', 'Indica se o problema é recorrente ou persistente.'),
('pdca', 'problema', 'criado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, TRUE, 'Valor padrão NOW().', 'INTERNO', 'Data e hora de criação do registro.'),
('pdca', 'problema', 'atualizado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, FALSE, 'Data da última alteração.', 'INTERNO', 'Data e hora da última atualização do registro.'),

-- pdca.causa_raiz
('pdca', 'causa_raiz', 'id', 'BIGSERIAL', TRUE, FALSE, NULL, TRUE, 'Gerado automaticamente.', 'INTERNO', 'Identificador único da causa raiz.'),
('pdca', 'causa_raiz', 'id_ciclo', 'BIGINT', FALSE, TRUE, 'pdca.ciclo(id)', TRUE, 'ON DELETE CASCADE.', 'INTERNO', 'Ciclo PDCA ao qual a causa pertence.'),
('pdca', 'causa_raiz', 'id_problema', 'BIGINT', FALSE, TRUE, 'pdca.problema(id)', TRUE, 'Problema associado.', 'INTERNO', 'Problema relacionado à causa raiz.'),
('pdca', 'causa_raiz', 'id_plano_acao', 'BIGINT', FALSE, TRUE, 'pdca.plano_acao(id)', FALSE, 'Plano de ação corretiva, se houver.', 'INTERNO', 'Plano de ação associado à causa raiz, quando houver.'),
('pdca', 'causa_raiz', 'id_5_porques_mongo', 'INTEGER', FALSE, FALSE, NULL, FALSE, 'Identificador de análise externa (MongoDB).', 'INTERNO', 'Identificador da análise dos 5 porquês armazenada em base externa.'),
('pdca', 'causa_raiz', 'validada_por', 'BIGINT', FALSE, TRUE, 'public.usuario_sistema(id)', FALSE, 'Usuário validador.', 'INTERNO', 'Usuário que validou a causa raiz.'),
('pdca', 'causa_raiz', 'descricao', 'TEXT', FALSE, FALSE, NULL, TRUE, 'Descrição da causa.', 'INTERNO', 'Descrição da causa raiz.'),
('pdca', 'causa_raiz', 'origem', 'VARCHAR(40)', FALSE, FALSE, NULL, TRUE, 'MANUAL, IA, FORMULARIO, IMPORTACAO, SISTEMA.', 'INTERNO', 'Origem de identificação da causa raiz.'),
('pdca', 'causa_raiz', 'aceita', 'BOOLEAN', FALSE, FALSE, NULL, TRUE, 'Status de aceitação.', 'INTERNO', 'Indica se a causa raiz foi aceita.'),
('pdca', 'causa_raiz', 'validada_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, FALSE, 'Data de validação.', 'INTERNO', 'Data e hora de validação da causa raiz.'),
('pdca', 'causa_raiz', 'principal', 'BOOLEAN', FALSE, FALSE, NULL, TRUE, 'Indica se é a causa raiz primária.', 'INTERNO', 'Indica se esta é a causa raiz principal.'),
('pdca', 'causa_raiz', 'criado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, TRUE, 'Valor padrão NOW().', 'INTERNO', 'Data e hora de criação do registro.'),
('pdca', 'causa_raiz', 'atualizado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, FALSE, 'Data da última alteração.', 'INTERNO', 'Data e hora da última atualização do registro.'),

-- pdca.meta_responsavel
('pdca', 'meta_responsavel', 'id_meta', 'BIGINT', TRUE, TRUE, 'pdca.meta(id)', TRUE, 'ON DELETE CASCADE. Parte da chave primária composta.', 'INTERNO', 'Meta atribuída ao usuário.'),
('pdca', 'meta_responsavel', 'id_usuario', 'BIGINT', TRUE, TRUE, 'public.usuario_sistema(id)', TRUE, 'ON DELETE CASCADE. Parte da chave primária composta.', 'INTERNO', 'Usuário responsável pela meta.'),

-- pdca.plano_5w2h
('pdca', 'plano_5w2h', 'id', 'BIGSERIAL', TRUE, FALSE, NULL, TRUE, 'Gerado automaticamente.', 'INTERNO', 'Identificador único do detalhamento 5W2H.'),
('pdca', 'plano_5w2h', 'id_plano_acao', 'BIGINT', FALSE, TRUE, 'pdca.plano_acao(id)', TRUE, 'ON DELETE CASCADE. Chave única.', 'INTERNO', 'Plano de ação detalhado pelo 5W2H.'),
('pdca', 'plano_5w2h', 'id_who_responsavel', 'BIGINT', FALSE, TRUE, 'public.usuario_sistema(id)', TRUE, 'Responsável (Who).', 'INTERNO', 'Usuário responsável pela execução da ação.'),
('pdca', 'plano_5w2h', 'what_acao', 'TEXT', FALSE, FALSE, NULL, TRUE, 'Ação a executar (What).', 'INTERNO', 'O que será feito.'),
('pdca', 'plano_5w2h', 'why_justificativa', 'TEXT', FALSE, FALSE, NULL, TRUE, 'Justificativa (Why).', 'INTERNO', 'Por que a ação será realizada.'),
('pdca', 'plano_5w2h', 'where_local', 'TEXT', FALSE, FALSE, NULL, TRUE, 'Local de aplicação (Where).', 'INTERNO', 'Onde a ação será realizada.'),
('pdca', 'plano_5w2h', 'when_inicio', 'DATE', FALSE, FALSE, NULL, FALSE, 'Data inicial (When).', 'INTERNO', 'Data de início da ação.'),
('pdca', 'plano_5w2h', 'when_fim', 'DATE', FALSE, FALSE, NULL, TRUE, 'Data limite (When). Deve ser >= when_inicio se este for informado.', 'INTERNO', 'Data de fim planejada da ação.'),
('pdca', 'plano_5w2h', 'how_modo_execucao', 'TEXT', FALSE, FALSE, NULL, TRUE, 'Método (How).', 'INTERNO', 'Como a ação será executada.'),
('pdca', 'plano_5w2h', 'how_much_custo', 'NUMERIC(12,2)', FALSE, FALSE, NULL, TRUE, 'Custo monetário (How much). Deve ser >= 0.', 'SENSIVEL', 'Custo estimado da ação.'),
('pdca', 'plano_5w2h', 'criado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, TRUE, 'Valor padrão NOW().', 'INTERNO', 'Data e hora de criação do registro.'),
('pdca', 'plano_5w2h', 'atualizado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, FALSE, 'Data da última edição.', 'INTERNO', 'Data e hora da última atualização do registro.'),

-- pdca.efeito_secundario
('pdca', 'efeito_secundario', 'id', 'BIGSERIAL', TRUE, FALSE, NULL, TRUE, 'Gerado automaticamente.', 'INTERNO', 'Identificador único do efeito secundário.'),
('pdca', 'efeito_secundario', 'id_verificacao_resultado', 'BIGINT', FALSE, TRUE, 'pdca.verificacao_resultado(id)', TRUE, 'ON DELETE CASCADE.', 'INTERNO', 'Verificação de resultado relacionada ao efeito.'),
('pdca', 'efeito_secundario', 'descricao', 'TEXT', FALSE, FALSE, NULL, TRUE, 'Descrição do impacto secundário.', 'INTERNO', 'Descrição do efeito secundário.'),
('pdca', 'efeito_secundario', 'peso', 'NUMERIC(3,2)', FALSE, FALSE, NULL, TRUE, 'Valor entre 0 e 1.', 'INTERNO', 'Peso relativo do efeito secundário.'),
('pdca', 'efeito_secundario', 'impacto_estimado', 'TEXT', FALSE, FALSE, NULL, FALSE, 'Avaliação de impacto.', 'SENSIVEL', 'Impacto estimado do efeito secundário.'),
('pdca', 'efeito_secundario', 'tipo', 'VARCHAR(8)', FALSE, FALSE, NULL, FALSE, 'POSITIVO ou NEGATIVO.', 'INTERNO', 'Tipo do efeito: POSITIVO ou NEGATIVO.'),
('pdca', 'efeito_secundario', 'criado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, TRUE, 'Valor padrão NOW().', 'INTERNO', 'Data e hora de criação do registro.'),
('pdca', 'efeito_secundario', 'atualizado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, FALSE, 'Data de atualização.', 'INTERNO', 'Data e hora da última atualização do registro.'),

-- pdca.tarefa
('pdca', 'tarefa', 'id', 'BIGSERIAL', TRUE, FALSE, NULL, TRUE, 'Gerado automaticamente.', 'INTERNO', 'Identificador único da tarefa.'),
('pdca', 'tarefa', 'id_plano_acao', 'BIGINT', FALSE, TRUE, 'pdca.plano_acao(id)', TRUE, 'ON DELETE CASCADE.', 'INTERNO', 'Plano de ação ao qual a tarefa pertence.'),
('pdca', 'tarefa', 'id_responsavel', 'BIGINT', FALSE, TRUE, 'public.usuario_sistema(id)', TRUE, 'Usuário encarregado da tarefa.', 'INTERNO', 'Usuário responsável pela tarefa.'),
('pdca', 'tarefa', 'titulo', 'VARCHAR(160)', FALSE, FALSE, NULL, TRUE, 'Título curto.', 'INTERNO', 'Título da tarefa.'),
('pdca', 'tarefa', 'descricao', 'TEXT', FALSE, FALSE, NULL, TRUE, 'Detalhamento da instrução.', 'INTERNO', 'Descrição detalhada da tarefa.'),
('pdca', 'tarefa', 'prioridade', 'VARCHAR(40)', FALSE, FALSE, NULL, TRUE, 'BAIXA, MEDIA, ALTA, CRITICA.', 'INTERNO', 'Prioridade da tarefa.'),
('pdca', 'tarefa', 'status', 'VARCHAR(40)', FALSE, FALSE, NULL, TRUE, 'PENDENTE, EM_ANDAMENTO, BLOQUEADA, CONCLUIDA, ATRASADA, CANCELADA.', 'INTERNO', 'Situação atual da tarefa.'),
('pdca', 'tarefa', 'data_inicio_real', 'DATE', FALSE, FALSE, NULL, FALSE, 'Data em que iniciou.', 'INTERNO', 'Data real de início da tarefa.'),
('pdca', 'tarefa', 'data_fim_prevista', 'DATE', FALSE, FALSE, NULL, TRUE, 'Prazo estipulado. Deve ser >= data_inicio_real.', 'INTERNO', 'Data prevista para conclusão da tarefa.'),
('pdca', 'tarefa', 'data_fim_real', 'DATE', FALSE, FALSE, NULL, FALSE, 'Data de conclusão efetiva. Deve ser >= data_inicio_real.', 'INTERNO', 'Data real de conclusão da tarefa.'),
('pdca', 'tarefa', 'criado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, TRUE, 'Valor padrão NOW().', 'INTERNO', 'Data e hora de criação do registro.'),
('pdca', 'tarefa', 'atualizado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, FALSE, 'Última modificação.', 'INTERNO', 'Data e hora da última atualização do registro.'),

-- pdca.alerta_prazo
('pdca', 'alerta_prazo', 'id', 'BIGSERIAL', TRUE, FALSE, NULL, TRUE, 'Gerado automaticamente.', 'INTERNO', 'Identificador único do alerta.'),
('pdca', 'alerta_prazo', 'id_tarefa', 'BIGINT', FALSE, TRUE, 'pdca.tarefa(id)', TRUE, 'ON DELETE CASCADE.', 'INTERNO', 'Tarefa relacionada ao alerta.'),
('pdca', 'alerta_prazo', 'id_usuario_destino', 'BIGINT', FALSE, TRUE, 'public.usuario_sistema(id)', TRUE, 'ON DELETE CASCADE.', 'INTERNO', 'Usuário destinatário do alerta.'),
('pdca', 'alerta_prazo', 'mensagem', 'TEXT', FALSE, FALSE, NULL, TRUE, 'Texto do alerta.', 'INTERNO', 'Mensagem enviada no alerta.'),
('pdca', 'alerta_prazo', 'enviado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, TRUE, 'Valor padrão NOW().', 'INTERNO', 'Data e hora de envio do alerta.'),
('pdca', 'alerta_prazo', 'lido_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, FALSE, 'Registrado na confirmação de leitura.', 'INTERNO', 'Data e hora de leitura do alerta.'),

-- pdca.tarefa_dependencia
('pdca', 'tarefa_dependencia', 'id_tarefa', 'BIGINT', TRUE, TRUE, 'pdca.tarefa(id)', TRUE, 'ON DELETE CASCADE. Parte da PK.', 'INTERNO', 'Tarefa que depende de outra tarefa.'),
('pdca', 'tarefa_dependencia', 'id_tarefa_dependencia', 'BIGINT', TRUE, TRUE, 'pdca.tarefa(id)', TRUE, 'ON DELETE CASCADE. Parte da PK. Deve ser diferente de id_tarefa.', 'INTERNO', 'Tarefa que deve ser considerada como dependência.'),

-- pdca.usuario_ciclo
('pdca', 'usuario_ciclo', 'id_usuario', 'BIGINT', TRUE, TRUE, 'public.usuario_sistema(id)', TRUE, 'ON DELETE CASCADE. Parte da PK.', 'INTERNO', 'Usuário participante do ciclo.'),
('pdca', 'usuario_ciclo', 'id_ciclo', 'BIGINT', TRUE, TRUE, 'pdca.ciclo(id)', TRUE, 'ON DELETE CASCADE. Parte da PK.', 'INTERNO', 'Ciclo PDCA ao qual o usuário está vinculado.'),
('pdca', 'usuario_ciclo', 'papel_ciclo', 'VARCHAR(40)', FALSE, FALSE, NULL, TRUE, 'RESPONSAVEL, PARTICIPANTE, EXECUTOR, VALIDADOR, OBSERVADOR.', 'INTERNO', 'Papel do usuário no ciclo.'),

-- pdca.usuario_treinamento
('pdca', 'usuario_treinamento', 'id_treinamento', 'BIGINT', TRUE, TRUE, 'pdca.treinamento(id)', TRUE, 'ON DELETE CASCADE. Parte da PK.', 'INTERNO', 'Treinamento atribuído ao usuário.'),
('pdca', 'usuario_treinamento', 'id_usuario', 'BIGINT', TRUE, TRUE, 'public.usuario_sistema(id)', TRUE, 'ON DELETE CASCADE. Parte da PK.', 'INTERNO', 'Usuário participante do treinamento.'),
('pdca', 'usuario_treinamento', 'obrigatorio', 'BOOLEAN', FALSE, FALSE, NULL, TRUE, 'Indica obrigatoriedade individual.', 'INTERNO', 'Indica se o treinamento é obrigatório para o usuário.'),
('pdca', 'usuario_treinamento', 'status', 'VARCHAR(40)', FALSE, FALSE, NULL, TRUE, 'PENDENTE, CONFIRMADO, CONCLUIDO, DISPENSADO, CANCELADO.', 'INTERNO', 'Situação do usuário no treinamento.'),
('pdca', 'usuario_treinamento', 'terminado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, FALSE, 'Data/hora de término do treinamento.', 'INTERNO', 'Data e hora de conclusão do treinamento.'),

-- pdca.priorizacao_problema_usuario
('pdca', 'priorizacao_problema_usuario', 'id_problema', 'BIGINT', TRUE, TRUE, 'pdca.problema(id)', TRUE, 'ON DELETE CASCADE. Parte da PK.', 'INTERNO', 'Problema priorizado pelo usuário.'),
('pdca', 'priorizacao_problema_usuario', 'id_usuario', 'BIGINT', TRUE, TRUE, 'public.usuario_sistema(id)', TRUE, 'ON DELETE CASCADE. Parte da PK.', 'INTERNO', 'Usuário que realizou a priorização.'),
('pdca', 'priorizacao_problema_usuario', 'posicao', 'INTEGER', FALSE, FALSE, NULL, TRUE, 'Valor maior que 0.', 'INTERNO', 'Posição atribuída ao problema na priorização.'),
('pdca', 'priorizacao_problema_usuario', 'peso_calculado', 'NUMERIC(3,2)', FALSE, FALSE, NULL, TRUE, 'Peso decimal entre 0 e 1.', 'INTERNO', 'Peso calculado para o problema a partir da priorização.'),
('pdca', 'priorizacao_problema_usuario', 'criado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, TRUE, 'Valor padrão NOW().', 'INTERNO', 'Data e hora de criação do registro.'),
('pdca', 'priorizacao_problema_usuario', 'atualizado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, FALSE, 'Data de atualização.', 'INTERNO', 'Data e hora da última atualização do registro.'),

-- pdca.anexo
('pdca', 'anexo', 'id', 'BIGSERIAL', TRUE, FALSE, NULL, TRUE, 'Gerado automaticamente.', 'INTERNO', 'Identificador único do anexo.'),
('pdca', 'anexo', 'id_empresa', 'BIGINT', FALSE, TRUE, 'public.empresa(id)', TRUE, 'ON DELETE RESTRICT.', 'INTERNO', 'Empresa dona do anexo.'),
('pdca', 'anexo', 'id_ciclo', 'BIGINT', FALSE, TRUE, 'pdca.ciclo(id)', TRUE, 'ON DELETE RESTRICT.', 'INTERNO', 'Ciclo PDCA relacionado ao anexo.'),
('pdca', 'anexo', 'criado_por', 'BIGINT', FALSE, TRUE, 'public.usuario_sistema(id)', FALSE, 'ON DELETE SET NULL.', 'INTERNO', 'Usuário que enviou o anexo.'),
('pdca', 'anexo', 'id_origem', 'BIGINT', FALSE, FALSE, NULL, FALSE, 'Obrigatório para categorias diferentes de OUTRO.', 'INTERNO', 'Identificador do registro relacionado à categoria do anexo.'),
('pdca', 'anexo', 'nome_arquivo', 'VARCHAR(255)', FALSE, FALSE, NULL, TRUE, 'Nome original do arquivo.', 'INTERNO', 'Nome original ou apresentado do arquivo.'),
('pdca', 'anexo', 'tipo_arquivo', 'VARCHAR(150)', FALSE, FALSE, NULL, TRUE, 'MIME type válido (PDF, Office, Imagens, CSV, Text).', 'INTERNO', 'Tipo MIME do arquivo.'),
('pdca', 'anexo', 'tamanho_arquivo', 'BIGINT', FALSE, FALSE, NULL, TRUE, 'Tamanho em bytes (> 0).', 'INTERNO', 'Tamanho do arquivo em bytes.'),
('pdca', 'anexo', 'bucket_arquivo', 'VARCHAR(100)', FALSE, FALSE, NULL, TRUE, 'Padrão acta-arquivos.', 'RESTRITO', 'Bucket de armazenamento do arquivo.'),
('pdca', 'anexo', 'caminho_arquivo', 'TEXT', FALSE, FALSE, NULL, TRUE, 'Chave única associada ao bucket.', 'RESTRITO', 'Caminho ou chave do arquivo no armazenamento.'),
('pdca', 'anexo', 'status', 'VARCHAR(30)', FALSE, FALSE, NULL, TRUE, 'PROCESSANDO, ATIVO, ERRO, EXCLUIDO. Padrão PROCESSANDO.', 'INTERNO', 'Situação do processamento e disponibilidade do anexo.'),
('pdca', 'anexo', 'descricao', 'TEXT', FALSE, FALSE, NULL, FALSE, 'Detalhes adicionais.', 'INTERNO', 'Descrição opcional do anexo.'),
('pdca', 'anexo', 'criado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, TRUE, 'Valor padrão NOW().', 'INTERNO', 'Data e hora de criação do registro.'),
('pdca', 'anexo', 'atualizado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, FALSE, 'Data de atualização.', 'INTERNO', 'Data e hora da última atualização do registro.'),
('pdca', 'anexo', 'excluido_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, FALSE, 'Obrigatório caso o status seja EXCLUIDO.', 'INTERNO', 'Data e hora de exclusão lógica do anexo.'),
('pdca', 'anexo', 'categoria', 'VARCHAR(40)', FALSE, FALSE, NULL, TRUE, 'TREINAMENTO, PLANO_ACAO, CAUSA_RAIZ, PROBLEMA, META, RELATORIO, LICAO_APRENDIDA, FORMULARIO, EVIDENCIA, OUTRO.', 'INTERNO', 'Categoria funcional do anexo.'),

-- SCHEMA: auditoria

-- auditoria.catalogo_dados
('auditoria', 'catalogo_dados', 'id', 'BIGSERIAL', TRUE, FALSE, NULL, TRUE, 'Gerado automaticamente.', 'INTERNO', 'Identificador único do item de catálogo.'),
('auditoria', 'catalogo_dados', 'nome_schema', 'VARCHAR(100)', FALSE, FALSE, NULL, TRUE, 'Nome do Schema PostgreSQL.', 'INTERNO', 'Schema onde a coluna está definida.'),
('auditoria', 'catalogo_dados', 'tabela', 'VARCHAR(100)', FALSE, FALSE, NULL, TRUE, 'Nome da Tabela. Padrão único com coluna.', 'INTERNO', 'Nome da tabela catalogada.'),
('auditoria', 'catalogo_dados', 'coluna', 'VARCHAR(100)', FALSE, FALSE, NULL, TRUE, 'Nome da Coluna.', 'INTERNO', 'Nome da coluna catalogada.'),
('auditoria', 'catalogo_dados', 'tipo_dado', 'VARCHAR(80)', FALSE, FALSE, NULL, TRUE, 'Tipo do dado no PostgreSQL.', 'INTERNO', 'Tipo de dado da coluna.'),
('auditoria', 'catalogo_dados', 'eh_pk', 'BOOLEAN', FALSE, FALSE, NULL, TRUE, 'Flag de Primary Key.', 'INTERNO', 'Indica se a coluna compõe a chave primária.'),
('auditoria', 'catalogo_dados', 'eh_fk', 'BOOLEAN', FALSE, FALSE, NULL, TRUE, 'Flag de Foreign Key.', 'INTERNO', 'Indica se a coluna compõe uma chave estrangeira.'),
('auditoria', 'catalogo_dados', 'referencia', 'TEXT', FALSE, FALSE, NULL, FALSE, 'Especificação tabela(coluna) de destino.', 'INTERNO', 'Referência da chave estrangeira, quando houver.'),
('auditoria', 'catalogo_dados', 'obrigatorio', 'BOOLEAN', FALSE, FALSE, NULL, TRUE, 'Indica NOT NULL.', 'INTERNO', 'Indica se a coluna é obrigatória.'),
('auditoria', 'catalogo_dados', 'regra_negocio', 'TEXT', FALSE, FALSE, NULL, FALSE, 'Regras, restrições e validações.', 'INTERNO', 'Regra de negócio associada à coluna.'),
('auditoria', 'catalogo_dados', 'nivel_acesso', 'VARCHAR(40)', FALSE, FALSE, NULL, TRUE, 'PUBLICO, INTERNO, RESTRITO, SENSIVEL.', 'INTERNO', 'Nível de acesso ou sensibilidade da coluna.'),
('auditoria', 'catalogo_dados', 'observacao', 'TEXT', FALSE, FALSE, NULL, FALSE, 'Anotações sobre a coluna.', 'INTERNO', 'Observações adicionais sobre a coluna.'),
('auditoria', 'catalogo_dados', 'criado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, TRUE, 'Valor padrão NOW().', 'INTERNO', 'Data e hora de criação do registro.'),

-- auditoria.atv_usuario_dia
('auditoria', 'atv_usuario_dia', 'id', 'BIGSERIAL', TRUE, FALSE, NULL, TRUE, 'Gerado automaticamente.', 'RESTRITO', 'Identificador único do registro de atividade.'),
('auditoria', 'atv_usuario_dia', 'id_usuario', 'BIGINT', FALSE, FALSE, NULL, TRUE, 'ID do Usuário sem FK explícita para histórico.', 'RESTRITO', 'Usuário associado à atividade.'),
('auditoria', 'atv_usuario_dia', 'data_atv', 'DATE', FALSE, FALSE, NULL, FALSE, 'Padrão CURRENT_DATE.', 'RESTRITO', 'Data de referência da atividade.'),
('auditoria', 'atv_usuario_dia', 'hora_inicio', 'TIMESTAMPTZ', FALSE, FALSE, NULL, TRUE, 'Início do intervalo.', 'RESTRITO', 'Início da janela de atividade.'),
('auditoria', 'atv_usuario_dia', 'hora_fim', 'TIMESTAMPTZ', FALSE, FALSE, NULL, TRUE, 'Fim do intervalo. Deve ser >= hora_inicio.', 'RESTRITO', 'Fim da janela de atividade.'),
('auditoria', 'atv_usuario_dia', 'qnt_acoes', 'INTEGER', FALSE, FALSE, NULL, TRUE, 'Quantidade de ações (>= 0).', 'RESTRITO', 'Quantidade de ações realizadas no período.'),

-- auditoria.log_auditoria
('auditoria', 'log_auditoria', 'id', 'BIGSERIAL', TRUE, FALSE, NULL, TRUE, 'Gerado automaticamente.', 'RESTRITO', 'Identificador único do log de auditoria.'),
('auditoria', 'log_auditoria', 'id_usuario', 'BIGINT', FALSE, FALSE, NULL, TRUE, 'ID do Usuário executor da ação.', 'RESTRITO', 'Usuário associado à operação auditada.'),
('auditoria', 'log_auditoria', 'id_registro', 'BIGINT', FALSE, FALSE, NULL, TRUE, 'ID do registro modificado.', 'RESTRITO', 'Identificador do registro afetado.'),
('auditoria', 'log_auditoria', 'tabela', 'VARCHAR(100)', FALSE, FALSE, NULL, TRUE, 'Nome da tabela afetada.', 'RESTRITO', 'Tabela onde a operação ocorreu.'),
('auditoria', 'log_auditoria', 'operacao', 'VARCHAR(40)', FALSE, FALSE, NULL, TRUE, 'INSERT, UPDATE, DELETE, LOGIN, LOGOUT, READ, EXPORT.', 'RESTRITO', 'Tipo de operação auditada.'),
('auditoria', 'log_auditoria', 'dados_antes', 'JSONB', FALSE, FALSE, NULL, TRUE, 'Snapshot anterior (Objeto JSONB).', 'RESTRITO', 'Estado do registro antes da operação.'),
('auditoria', 'log_auditoria', 'dados_depois', 'JSONB', FALSE, FALSE, NULL, TRUE, 'Snapshot posterior (Objeto JSONB).', 'RESTRITO', 'Estado do registro depois da operação.'),
('auditoria', 'log_auditoria', 'data_log', 'TIMESTAMPTZ', FALSE, FALSE, NULL, TRUE, 'Valor padrão NOW().', 'RESTRITO', 'Data e hora de criação do log.'),

-- auditoria.log_status
('auditoria', 'log_status', 'id', 'BIGSERIAL', TRUE, FALSE, NULL, TRUE, 'Gerado automaticamente.', 'RESTRITO', 'Identificador único do log de status.'),
('auditoria', 'log_status', 'id_usuario', 'BIGINT', FALSE, FALSE, NULL, TRUE, 'Usuário alterador.', 'RESTRITO', 'Usuário responsável pela alteração.'),
('auditoria', 'log_status', 'id_registro', 'BIGINT', FALSE, FALSE, NULL, TRUE, 'ID do elemento afetado.', 'RESTRITO', 'Identificador do registro alterado.'),
('auditoria', 'log_status', 'tabela', 'VARCHAR(100)', FALSE, FALSE, NULL, TRUE, 'Tabela modificada.', 'RESTRITO', 'Tabela do registro alterado.'),
('auditoria', 'log_status', 'status_anterior', 'VARCHAR(40)', FALSE, FALSE, NULL, TRUE, 'Status que estava atribuído.', 'RESTRITO', 'Status antes da alteração.'),
('auditoria', 'log_status', 'status_atual', 'VARCHAR(40)', FALSE, FALSE, NULL, TRUE, 'Novo status aplicado.', 'RESTRITO', 'Status depois da alteração.'),
('auditoria', 'log_status', 'data_log', 'TIMESTAMPTZ', FALSE, FALSE, NULL, TRUE, 'Valor padrão NOW().', 'RESTRITO', 'Data e hora da alteração de status.'),

-- auditoria.log_colaborador
('auditoria', 'log_colaborador', 'id', 'BIGSERIAL', TRUE, FALSE, NULL, TRUE, 'Gerado automaticamente.', 'RESTRITO', 'Identificador único do log de colaborador.'),
('auditoria', 'log_colaborador', 'id_colaborador', 'BIGINT', FALSE, FALSE, NULL, TRUE, 'Colaborador afetado.', 'RESTRITO', 'Colaborador associado ao log.'),
('auditoria', 'log_colaborador', 'id_usuario', 'BIGINT', FALSE, FALSE, NULL, TRUE, 'Usuário operador.', 'RESTRITO', 'Usuário responsável pela operação.'),
('auditoria', 'log_colaborador', 'operacao', 'VARCHAR(40)', FALSE, FALSE, NULL, TRUE, 'INSERT, UPDATE, DELETE, LOGIN, LOGOUT, READ, EXPORT.', 'RESTRITO', 'Tipo de operação auditada.'),
('auditoria', 'log_colaborador', 'dados_antes', 'JSONB', FALSE, FALSE, NULL, TRUE, 'Snapshot anterior (Objeto JSONB).', 'RESTRITO', 'Estado do registro antes da operação.'),
('auditoria', 'log_colaborador', 'dados_depois', 'JSONB', FALSE, FALSE, NULL, TRUE, 'Snapshot posterior (Objeto JSONB).', 'RESTRITO', 'Estado do registro depois da operação.'),
('auditoria', 'log_colaborador', 'data_log', 'TIMESTAMPTZ', FALSE, FALSE, NULL, TRUE, 'Valor padrão NOW().', 'RESTRITO', 'Data e hora de criação do log.'),

-- auditoria.log_acesso_usuario
('auditoria', 'log_acesso_usuario', 'id', 'BIGSERIAL', TRUE, FALSE, NULL, TRUE, 'Gerado automaticamente.', 'RESTRITO', 'Identificador único do log de acesso.'),
('auditoria', 'log_acesso_usuario', 'id_usuario', 'BIGINT', FALSE, FALSE, NULL, TRUE, 'Usuário acessante.', 'RESTRITO', 'Usuário que realizou o acesso.'),
('auditoria', 'log_acesso_usuario', 'id_ciclo', 'BIGINT', FALSE, FALSE, NULL, FALSE, 'ID do ciclo acessado.', 'RESTRITO', 'Ciclo PDCA acessado, quando aplicável.'),
('auditoria', 'log_acesso_usuario', 'acao_realizada', 'VARCHAR(60)', FALSE, FALSE, NULL, TRUE, 'Descrição simples da ação.', 'RESTRITO', 'Ação realizada pelo usuário.'),
('auditoria', 'log_acesso_usuario', 'acessado_em', 'TIMESTAMPTZ', FALSE, FALSE, NULL, TRUE, 'Valor padrão NOW().', 'RESTRITO', 'Data e hora do acesso.'),

-- auditoria.log_tarefa
('auditoria', 'log_tarefa', 'id', 'BIGSERIAL', TRUE, FALSE, NULL, TRUE, 'Gerado automaticamente.', 'RESTRITO', 'Identificador único do log de tarefa.'),
('auditoria', 'log_tarefa', 'id_tarefa', 'BIGINT', FALSE, FALSE, NULL, TRUE, 'Tarefa auditada.', 'RESTRITO', 'Tarefa associada ao log.'),
('auditoria', 'log_tarefa', 'id_usuario', 'BIGINT', FALSE, FALSE, NULL, TRUE, 'Usuário executor.', 'RESTRITO', 'Usuário responsável pela operação.'),
('auditoria', 'log_tarefa', 'dados_antes', 'JSONB', FALSE, FALSE, NULL, TRUE, 'Snapshot anterior (Objeto JSONB).', 'RESTRITO', 'Estado da tarefa antes da operação.'),
('auditoria', 'log_tarefa', 'dados_depois', 'JSONB', FALSE, FALSE, NULL, TRUE, 'Snapshot posterior (Objeto JSONB).', 'RESTRITO', 'Estado da tarefa depois da operação.'),
('auditoria', 'log_tarefa', 'data_log', 'TIMESTAMPTZ', FALSE, FALSE, NULL, TRUE, 'Valor padrão NOW().', 'RESTRITO', 'Data e hora de criação do log.'),
('auditoria', 'log_tarefa', 'operacao', 'VARCHAR(40)', FALSE, FALSE, NULL, TRUE, 'INSERT, UPDATE, DELETE, LOGIN, LOGOUT, READ, EXPORT.', 'RESTRITO', 'Tipo de operação auditada.');