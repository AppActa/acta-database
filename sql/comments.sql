
-- Schema public
COMMENT ON TABLE public.empresa IS 'Empresas cadastradas na plataforma Acta.';
COMMENT ON COLUMN public.empresa.id IS 'Identificador unico da empresa.';
COMMENT ON COLUMN public.empresa.cnpj IS 'CNPJ da empresa, armazenado apenas com numeros.';
COMMENT ON COLUMN public.empresa.nome IS 'Nome empresarial.';
COMMENT ON COLUMN public.empresa.tamanho_empresa IS 'Porte da empresa: PEQUENA, MEDIA ou GRANDE.';
COMMENT ON COLUMN public.empresa.setor_empresa IS 'Setor ou segmento de atuacao da empresa.';
COMMENT ON COLUMN public.empresa.status IS 'Situacao cadastral da empresa na plataforma.';
COMMENT ON COLUMN public.empresa.criado_em IS 'Data e hora de criacao do registro.';
COMMENT ON COLUMN public.empresa.atualizado_em IS 'Data e hora da ultima atualizacao do registro.';

COMMENT ON TABLE public.usuario_sistema IS 'Usuarios que acessam o sistema.';
COMMENT ON COLUMN public.usuario_sistema.id IS 'Identificador unico do usuario.';
COMMENT ON COLUMN public.usuario_sistema.id_empresa IS 'Empresa a qual o usuario pertence.';
COMMENT ON COLUMN public.usuario_sistema.nome IS 'Nome do usuario.';
COMMENT ON COLUMN public.usuario_sistema.email_login IS 'E-mail utilizado para login no sistema.';
COMMENT ON COLUMN public.usuario_sistema.firebase_uid IS 'Identificador unico do usuario no Firebase Authentication.';
COMMENT ON COLUMN public.usuario_sistema.tipo_usuario IS 'Perfil de acesso do usuario: ADMIN, GESTOR ou COLABORADOR.';
COMMENT ON COLUMN public.usuario_sistema.status IS 'Situacao do usuario no sistema.';
COMMENT ON COLUMN public.usuario_sistema.criado_em IS 'Data e hora de criacao do registro.';
COMMENT ON COLUMN public.usuario_sistema.atualizado_em IS 'Data e hora da ultima atualizacao do registro.';

COMMENT ON TABLE public.convite_usuario IS 'Convites enviados para usuarios da plataforma.';
COMMENT ON COLUMN public.convite_usuario.id IS 'Identificador unico do convite.';
COMMENT ON COLUMN public.convite_usuario.id_usuario IS 'Usuario convidado.';
COMMENT ON COLUMN public.convite_usuario.email_destino IS 'Endereco de e-mail para o qual o convite foi enviado.';
COMMENT ON COLUMN public.convite_usuario.token_hash IS 'Hash unico do token utilizado para validar o convite.';
COMMENT ON COLUMN public.convite_usuario.status IS 'Situacao do convite: PENDENTE, USADO, REVOGADO ou EXPIRADO.';
COMMENT ON COLUMN public.convite_usuario.expira_em IS 'Data e hora de expiracao do convite.';
COMMENT ON COLUMN public.convite_usuario.usado_em IS 'Data e hora de utilizacao do convite, quando utilizado.';
COMMENT ON COLUMN public.convite_usuario.criado_por IS 'Usuario que criou o convite.';
COMMENT ON COLUMN public.convite_usuario.criado_em IS 'Data e hora de criacao do convite.';

COMMENT ON TABLE public.colaborador IS 'Colaboradores vinculados a uma empresa e a um usuario do sistema.';
COMMENT ON COLUMN public.colaborador.id IS 'Identificador unico do colaborador.';
COMMENT ON COLUMN public.colaborador.id_empresa IS 'Empresa a qual o colaborador pertence.';
COMMENT ON COLUMN public.colaborador.id_usuario IS 'Usuario do sistema associado ao colaborador.';
COMMENT ON COLUMN public.colaborador.cpf IS 'CPF do colaborador, armazenado apenas com numeros.';
COMMENT ON COLUMN public.colaborador.nome IS 'Nome completo do colaborador.';
COMMENT ON COLUMN public.colaborador.cargo IS 'Cargo ocupado pelo colaborador.';
COMMENT ON COLUMN public.colaborador.area IS 'Area ou departamento do colaborador.';
COMMENT ON COLUMN public.colaborador.data_nascimento IS 'Data de nascimento do colaborador.';
COMMENT ON COLUMN public.colaborador.data_contratacao IS 'Data de contratacao do colaborador.';
COMMENT ON COLUMN public.colaborador.permissao_gestor IS 'Indica se o colaborador possui permissao de gestor.';
COMMENT ON COLUMN public.colaborador.status IS 'Situacao do colaborador no sistema.';
COMMENT ON COLUMN public.colaborador.criado_em IS 'Data e hora de criacao do registro.';
COMMENT ON COLUMN public.colaborador.atualizado_em IS 'Data e hora da ultima atualizacao do registro.';

COMMENT ON TABLE public.endereco_empresa IS 'Enderecos cadastrados para empresas.';
COMMENT ON COLUMN public.endereco_empresa.id IS 'Identificador unico do endereco.';
COMMENT ON COLUMN public.endereco_empresa.id_empresa IS 'Empresa dona do endereco.';
COMMENT ON COLUMN public.endereco_empresa.cep IS 'CEP do endereco, armazenado apenas com numeros.';
COMMENT ON COLUMN public.endereco_empresa.uf IS 'Unidade federativa do endereco.';
COMMENT ON COLUMN public.endereco_empresa.cidade IS 'Cidade do endereco.';
COMMENT ON COLUMN public.endereco_empresa.bairro IS 'Bairro do endereco.';
COMMENT ON COLUMN public.endereco_empresa.logradouro IS 'Logradouro do endereco.';
COMMENT ON COLUMN public.endereco_empresa.numero_endereco IS 'Numero do endereco.';
COMMENT ON COLUMN public.endereco_empresa.complemento IS 'Complemento do endereco, quando houver.';
COMMENT ON COLUMN public.endereco_empresa.principal IS 'Indica se este e o endereco principal da empresa.';
COMMENT ON COLUMN public.endereco_empresa.criado_em IS 'Data e hora de criacao do registro.';
COMMENT ON COLUMN public.endereco_empresa.atualizado_em IS 'Data e hora da ultima atualizacao do registro.';

COMMENT ON TABLE public.email_empresa IS 'E-mails cadastrados para empresas.';
COMMENT ON COLUMN public.email_empresa.id IS 'Identificador unico do e-mail da empresa.';
COMMENT ON COLUMN public.email_empresa.id_empresa IS 'Empresa dona do e-mail.';
COMMENT ON COLUMN public.email_empresa.email IS 'Endereco de e-mail da empresa.';
COMMENT ON COLUMN public.email_empresa.principal IS 'Indica se este e o e-mail principal da empresa.';
COMMENT ON COLUMN public.email_empresa.criado_em IS 'Data e hora de criacao do registro.';

COMMENT ON TABLE public.telefone_empresa IS 'Telefones cadastrados para empresas.';
COMMENT ON COLUMN public.telefone_empresa.id IS 'Identificador unico do telefone da empresa.';
COMMENT ON COLUMN public.telefone_empresa.id_empresa IS 'Empresa dona do telefone.';
COMMENT ON COLUMN public.telefone_empresa.numero_telefone IS 'Numero de telefone da empresa, armazenado apenas com numeros.';
COMMENT ON COLUMN public.telefone_empresa.principal IS 'Indica se este e o telefone principal da empresa.';
COMMENT ON COLUMN public.telefone_empresa.criado_em IS 'Data e hora de criacao do registro.';

COMMENT ON TABLE public.email_colaborador IS 'E-mails cadastrados para colaboradores.';
COMMENT ON COLUMN public.email_colaborador.id IS 'Identificador unico do e-mail do colaborador.';
COMMENT ON COLUMN public.email_colaborador.id_colaborador IS 'Colaborador dono do e-mail.';
COMMENT ON COLUMN public.email_colaborador.email IS 'Endereco de e-mail do colaborador.';
COMMENT ON COLUMN public.email_colaborador.principal IS 'Indica se este e o e-mail principal do colaborador.';
COMMENT ON COLUMN public.email_colaborador.criado_em IS 'Data e hora de criacao do registro.';

COMMENT ON TABLE public.telefone_colaborador IS 'Telefones cadastrados para colaboradores.';
COMMENT ON COLUMN public.telefone_colaborador.id IS 'Identificador unico do telefone do colaborador.';
COMMENT ON COLUMN public.telefone_colaborador.id_colaborador IS 'Colaborador dono do telefone.';
COMMENT ON COLUMN public.telefone_colaborador.numero_telefone IS 'Numero de telefone do colaborador, armazenado apenas com numeros.';
COMMENT ON COLUMN public.telefone_colaborador.principal IS 'Indica se este e o telefone principal do colaborador.';
COMMENT ON COLUMN public.telefone_colaborador.criado_em IS 'Data e hora de criacao do registro.';

-- Schema pdca
COMMENT ON TABLE pdca.ciclo IS 'Ciclos PDCA conduzidos por uma empresa.';
COMMENT ON COLUMN pdca.ciclo.id IS 'Identificador unico do ciclo PDCA.';
COMMENT ON COLUMN pdca.ciclo.id_empresa IS 'Empresa dona do ciclo.';
COMMENT ON COLUMN pdca.ciclo.id_responsavel IS 'Usuario responsavel pelo ciclo.';
COMMENT ON COLUMN pdca.ciclo.id_ishikawa_mongo IS 'Identificador do diagrama de Ishikawa armazenado em base externa.';
COMMENT ON COLUMN pdca.ciclo.titulo IS 'Titulo do ciclo PDCA.';
COMMENT ON COLUMN pdca.ciclo.descricao IS 'Descricao do objetivo e contexto do ciclo.';
COMMENT ON COLUMN pdca.ciclo.status IS 'Etapa ou situacao atual do ciclo.';
COMMENT ON COLUMN pdca.ciclo.data_inicio IS 'Data de inicio do ciclo.';
COMMENT ON COLUMN pdca.ciclo.data_estimada_fim IS 'Data estimada para encerramento do ciclo.';
COMMENT ON COLUMN pdca.ciclo.data_fim_real IS 'Data real de encerramento do ciclo, quando concluido.';
COMMENT ON COLUMN pdca.ciclo.criado_em IS 'Data e hora de criacao do registro.';
COMMENT ON COLUMN pdca.ciclo.atualizado_em IS 'Data e hora da ultima atualizacao do registro.';

COMMENT ON TABLE pdca.plano_acao IS 'Planos de acao vinculados a ciclos PDCA.';
COMMENT ON COLUMN pdca.plano_acao.id IS 'Identificador unico do plano de acao.';
COMMENT ON COLUMN pdca.plano_acao.id_ciclo IS 'Ciclo PDCA ao qual o plano pertence.';
COMMENT ON COLUMN pdca.plano_acao.nome IS 'Nome do plano de acao.';
COMMENT ON COLUMN pdca.plano_acao.objetivo IS 'Objetivo do plano de acao.';
COMMENT ON COLUMN pdca.plano_acao.prioridade IS 'Prioridade do plano.';
COMMENT ON COLUMN pdca.plano_acao.status IS 'Situacao atual do plano.';
COMMENT ON COLUMN pdca.plano_acao.origem IS 'Origem de criacao do plano.';
COMMENT ON COLUMN pdca.plano_acao.criado_por IS 'Usuario que criou o plano.';
COMMENT ON COLUMN pdca.plano_acao.criado_em IS 'Data e hora de criacao do registro.';
COMMENT ON COLUMN pdca.plano_acao.atualizado_em IS 'Data e hora da ultima atualizacao do registro.';

COMMENT ON TABLE pdca.meta IS 'Metas definidas para um ciclo e plano de acao.';
COMMENT ON COLUMN pdca.meta.id IS 'Identificador unico da meta.';
COMMENT ON COLUMN pdca.meta.id_ciclo IS 'Ciclo PDCA ao qual a meta pertence.';
COMMENT ON COLUMN pdca.meta.id_plano_acao IS 'Plano de acao ao qual a meta pertence.';
COMMENT ON COLUMN pdca.meta.objetivo IS 'Objetivo mensuravel da meta.';
COMMENT ON COLUMN pdca.meta.valor_base IS 'Valor inicial ou linha de base da meta.';
COMMENT ON COLUMN pdca.meta.valor_alvo IS 'Valor esperado para atingir a meta.';
COMMENT ON COLUMN pdca.meta.unidade IS 'Unidade de medida da meta.';
COMMENT ON COLUMN pdca.meta.prazo IS 'Prazo para cumprimento da meta.';
COMMENT ON COLUMN pdca.meta.status IS 'Situacao atual da meta.';
COMMENT ON COLUMN pdca.meta.prioridade IS 'Prioridade da meta.';
COMMENT ON COLUMN pdca.meta.area IS 'Area responsavel ou impactada pela meta.';
COMMENT ON COLUMN pdca.meta.categoria IS 'Categoria de classificacao da meta.';
COMMENT ON COLUMN pdca.meta.criado_em IS 'Data e hora de criacao do registro.';
COMMENT ON COLUMN pdca.meta.atualizado_em IS 'Data e hora da ultima atualizacao do registro.';

COMMENT ON TABLE pdca.treinamento IS 'Treinamentos associados a ciclos PDCA.';
COMMENT ON COLUMN pdca.treinamento.id IS 'Identificador unico do treinamento.';
COMMENT ON COLUMN pdca.treinamento.id_ciclo IS 'Ciclo PDCA ao qual o treinamento pertence.';
COMMENT ON COLUMN pdca.treinamento.id_anexo_mongo IS 'Identificador de anexo externo relacionado ao treinamento.';
COMMENT ON COLUMN pdca.treinamento.id_responsavel IS 'Usuario responsavel pelo treinamento.';
COMMENT ON COLUMN pdca.treinamento.titulo IS 'Titulo do treinamento.';
COMMENT ON COLUMN pdca.treinamento.descricao IS 'Descricao do treinamento.';
COMMENT ON COLUMN pdca.treinamento.data_treinamento IS 'Data planejada ou realizada do treinamento.';
COMMENT ON COLUMN pdca.treinamento.obrigatorio IS 'Indica se o treinamento e obrigatorio.';
COMMENT ON COLUMN pdca.treinamento.criado_em IS 'Data e hora de criacao do registro.';
COMMENT ON COLUMN pdca.treinamento.atualizado_em IS 'Data e hora da ultima atualizacao do registro.';

COMMENT ON TABLE pdca.verificacao_resultado IS 'Registros de verificacao dos resultados de um ciclo.';
COMMENT ON COLUMN pdca.verificacao_resultado.id IS 'Identificador unico da verificacao.';
COMMENT ON COLUMN pdca.verificacao_resultado.id_ciclo IS 'Ciclo PDCA verificado.';
COMMENT ON COLUMN pdca.verificacao_resultado.criado_por IS 'Usuario que registrou a verificacao.';
COMMENT ON COLUMN pdca.verificacao_resultado.status IS 'Resultado da verificacao.';
COMMENT ON COLUMN pdca.verificacao_resultado.resumo IS 'Resumo da verificacao realizada.';
COMMENT ON COLUMN pdca.verificacao_resultado.observacao IS 'Observacoes adicionais da verificacao.';
COMMENT ON COLUMN pdca.verificacao_resultado.criado_em IS 'Data e hora de criacao do registro.';

COMMENT ON TABLE pdca.problema IS 'Problemas identificados em um ciclo PDCA.';
COMMENT ON COLUMN pdca.problema.id IS 'Identificador unico do problema.';
COMMENT ON COLUMN pdca.problema.id_ciclo IS 'Ciclo PDCA ao qual o problema pertence.';
COMMENT ON COLUMN pdca.problema.id_problema_pai IS 'Problema superior em uma hierarquia de problemas.';
COMMENT ON COLUMN pdca.problema.criado_por IS 'Usuario que registrou o problema.';
COMMENT ON COLUMN pdca.problema.titulo IS 'Titulo do problema.';
COMMENT ON COLUMN pdca.problema.descricao IS 'Descricao detalhada do problema.';
COMMENT ON COLUMN pdca.problema.peso IS 'Peso relativo do problema para priorizacao.';
COMMENT ON COLUMN pdca.problema.status IS 'Situacao atual do problema.';
COMMENT ON COLUMN pdca.problema.origem IS 'Origem de identificacao do problema.';
COMMENT ON COLUMN pdca.problema.persistente IS 'Indica se o problema e recorrente ou persistente.';
COMMENT ON COLUMN pdca.problema.criado_em IS 'Data e hora de criacao do registro.';
COMMENT ON COLUMN pdca.problema.atualizado_em IS 'Data e hora da ultima atualizacao do registro.';

COMMENT ON TABLE pdca.causa_raiz IS 'Causas raiz relacionadas a problemas de ciclos PDCA.';
COMMENT ON COLUMN pdca.causa_raiz.id IS 'Identificador unico da causa raiz.';
COMMENT ON COLUMN pdca.causa_raiz.id_ciclo IS 'Ciclo PDCA ao qual a causa pertence.';
COMMENT ON COLUMN pdca.causa_raiz.id_problema IS 'Problema relacionado a causa raiz.';
COMMENT ON COLUMN pdca.causa_raiz.id_plano_acao IS 'Plano de acao associado a causa raiz, quando houver.';
COMMENT ON COLUMN pdca.causa_raiz.id_5_porques_mongo IS 'Identificador da analise dos 5 porques armazenada em base externa.';
COMMENT ON COLUMN pdca.causa_raiz.validada_por IS 'Usuario que validou a causa raiz.';
COMMENT ON COLUMN pdca.causa_raiz.descricao IS 'Descricao da causa raiz.';
COMMENT ON COLUMN pdca.causa_raiz.origem IS 'Origem de identificacao da causa raiz.';
COMMENT ON COLUMN pdca.causa_raiz.aceita IS 'Indica se a causa raiz foi aceita.';
COMMENT ON COLUMN pdca.causa_raiz.validada_em IS 'Data e hora de validacao da causa raiz.';
COMMENT ON COLUMN pdca.causa_raiz.principal IS 'Indica se esta e a causa raiz principal.';
COMMENT ON COLUMN pdca.causa_raiz.criado_em IS 'Data e hora de criacao do registro.';
COMMENT ON COLUMN pdca.causa_raiz.atualizado_em IS 'Data e hora da ultima atualizacao do registro.';

COMMENT ON TABLE pdca.meta_responsavel IS 'Associacao entre metas e usuarios responsaveis.';
COMMENT ON COLUMN pdca.meta_responsavel.id_meta IS 'Meta atribuida ao usuario.';
COMMENT ON COLUMN pdca.meta_responsavel.id_usuario IS 'Usuario responsavel pela meta.';

COMMENT ON TABLE pdca.plano_5w2h IS 'Detalhamento 5W2H de um plano de acao.';
COMMENT ON COLUMN pdca.plano_5w2h.id IS 'Identificador unico do detalhamento 5W2H.';
COMMENT ON COLUMN pdca.plano_5w2h.id_plano_acao IS 'Plano de acao detalhado pelo 5W2H.';
COMMENT ON COLUMN pdca.plano_5w2h.id_who_responsavel IS 'Usuario responsavel pela execucao da acao.';
COMMENT ON COLUMN pdca.plano_5w2h.what_acao IS 'O que sera feito.';
COMMENT ON COLUMN pdca.plano_5w2h.why_justificativa IS 'Por que a acao sera realizada.';
COMMENT ON COLUMN pdca.plano_5w2h.where_local IS 'Onde a acao sera realizada.';
COMMENT ON COLUMN pdca.plano_5w2h.when_inicio IS 'Data de inicio da acao.';
COMMENT ON COLUMN pdca.plano_5w2h.when_fim IS 'Data de fim planejada da acao.';
COMMENT ON COLUMN pdca.plano_5w2h.how_modo_execucao IS 'Como a acao sera executada.';
COMMENT ON COLUMN pdca.plano_5w2h.how_much_custo IS 'Custo estimado da acao.';
COMMENT ON COLUMN pdca.plano_5w2h.criado_em IS 'Data e hora de criacao do registro.';
COMMENT ON COLUMN pdca.plano_5w2h.atualizado_em IS 'Data e hora da ultima atualizacao do registro.';

COMMENT ON TABLE pdca.efeito_secundario IS 'Efeitos secundarios identificados durante a verificacao de resultados.';
COMMENT ON COLUMN pdca.efeito_secundario.id IS 'Identificador unico do efeito secundario.';
COMMENT ON COLUMN pdca.efeito_secundario.id_verificacao_resultado IS 'Verificacao de resultado relacionada ao efeito.';
COMMENT ON COLUMN pdca.efeito_secundario.descricao IS 'Descricao do efeito secundario.';
COMMENT ON COLUMN pdca.efeito_secundario.peso IS 'Peso relativo do efeito secundario.';
COMMENT ON COLUMN pdca.efeito_secundario.impacto_estimado IS 'Impacto estimado do efeito secundario.';
COMMENT ON COLUMN pdca.efeito_secundario.tipo IS 'Tipo do efeito: POSITIVO ou NEGATIVO.';
COMMENT ON COLUMN pdca.efeito_secundario.criado_em IS 'Data e hora de criacao do registro.';
COMMENT ON COLUMN pdca.efeito_secundario.atualizado_em IS 'Data e hora da ultima atualizacao do registro.';

COMMENT ON TABLE pdca.tarefa IS 'Tarefas executaveis associadas a planos de acao.';
COMMENT ON COLUMN pdca.tarefa.id IS 'Identificador unico da tarefa.';
COMMENT ON COLUMN pdca.tarefa.id_plano_acao IS 'Plano de acao ao qual a tarefa pertence.';
COMMENT ON COLUMN pdca.tarefa.id_responsavel IS 'Usuario responsavel pela tarefa.';
COMMENT ON COLUMN pdca.tarefa.titulo IS 'Titulo da tarefa.';
COMMENT ON COLUMN pdca.tarefa.descricao IS 'Descricao detalhada da tarefa.';
COMMENT ON COLUMN pdca.tarefa.prioridade IS 'Prioridade da tarefa.';
COMMENT ON COLUMN pdca.tarefa.status IS 'Situacao atual da tarefa.';
COMMENT ON COLUMN pdca.tarefa.data_inicio_real IS 'Data real de inicio da tarefa.';
COMMENT ON COLUMN pdca.tarefa.data_fim_prevista IS 'Data prevista para conclusao da tarefa.';
COMMENT ON COLUMN pdca.tarefa.data_fim_real IS 'Data real de conclusao da tarefa.';
COMMENT ON COLUMN pdca.tarefa.criado_em IS 'Data e hora de criacao do registro.';
COMMENT ON COLUMN pdca.tarefa.atualizado_em IS 'Data e hora da ultima atualizacao do registro.';

COMMENT ON TABLE pdca.alerta_prazo IS 'Alertas enviados a usuarios sobre prazos de tarefas.';
COMMENT ON COLUMN pdca.alerta_prazo.id IS 'Identificador unico do alerta.';
COMMENT ON COLUMN pdca.alerta_prazo.id_tarefa IS 'Tarefa relacionada ao alerta.';
COMMENT ON COLUMN pdca.alerta_prazo.id_usuario_destino IS 'Usuario destinatario do alerta.';
COMMENT ON COLUMN pdca.alerta_prazo.mensagem IS 'Mensagem enviada no alerta.';
COMMENT ON COLUMN pdca.alerta_prazo.enviado_em IS 'Data e hora de envio do alerta.';
COMMENT ON COLUMN pdca.alerta_prazo.lido_em IS 'Data e hora de leitura do alerta.';

COMMENT ON TABLE pdca.tarefa_dependencia IS 'Dependencias entre tarefas de planos de acao.';
COMMENT ON COLUMN pdca.tarefa_dependencia.id_tarefa IS 'Tarefa que depende de outra tarefa.';
COMMENT ON COLUMN pdca.tarefa_dependencia.id_tarefa_dependencia IS 'Tarefa que deve ser considerada como dependencia.';

COMMENT ON TABLE pdca.usuario_ciclo IS 'Usuarios participantes de ciclos PDCA e seus papeis.';
COMMENT ON COLUMN pdca.usuario_ciclo.id_usuario IS 'Usuario participante do ciclo.';
COMMENT ON COLUMN pdca.usuario_ciclo.id_ciclo IS 'Ciclo PDCA ao qual o usuario esta vinculado.';
COMMENT ON COLUMN pdca.usuario_ciclo.papel_ciclo IS 'Papel do usuario no ciclo.';

COMMENT ON TABLE pdca.usuario_treinamento IS 'Participacao de usuarios em treinamentos.';
COMMENT ON COLUMN pdca.usuario_treinamento.id_treinamento IS 'Treinamento atribuido ao usuario.';
COMMENT ON COLUMN pdca.usuario_treinamento.id_usuario IS 'Usuario participante do treinamento.';
COMMENT ON COLUMN pdca.usuario_treinamento.obrigatorio IS 'Indica se o treinamento e obrigatorio para o usuario.';
COMMENT ON COLUMN pdca.usuario_treinamento.status IS 'Situacao do usuario no treinamento.';
COMMENT ON COLUMN pdca.usuario_treinamento.terminado_em IS 'Data e hora de conclusao do treinamento.';

COMMENT ON TABLE pdca.priorizacao_problema_usuario IS 'Priorizacao de problemas realizada por usuarios.';
COMMENT ON COLUMN pdca.priorizacao_problema_usuario.id_problema IS 'Problema priorizado pelo usuario.';
COMMENT ON COLUMN pdca.priorizacao_problema_usuario.id_usuario IS 'Usuario que realizou a priorizacao.';
COMMENT ON COLUMN pdca.priorizacao_problema_usuario.posicao IS 'Posicao atribuida ao problema na priorizacao.';
COMMENT ON COLUMN pdca.priorizacao_problema_usuario.peso_calculado IS 'Peso calculado para o problema a partir da priorizacao.';
COMMENT ON COLUMN pdca.priorizacao_problema_usuario.criado_em IS 'Data e hora de criacao do registro.';
COMMENT ON COLUMN pdca.priorizacao_problema_usuario.atualizado_em IS 'Data e hora da ultima atualizacao do registro.';

COMMENT ON TABLE pdca.anexo IS 'Arquivos anexados a empresas, ciclos e registros do processo PDCA.';
COMMENT ON COLUMN pdca.anexo.id IS 'Identificador unico do anexo.';
COMMENT ON COLUMN pdca.anexo.id_empresa IS 'Empresa dona do anexo.';
COMMENT ON COLUMN pdca.anexo.id_ciclo IS 'Ciclo PDCA relacionado ao anexo.';
COMMENT ON COLUMN pdca.anexo.criado_por IS 'Usuario que enviou o anexo.';
COMMENT ON COLUMN pdca.anexo.categoria IS 'Categoria funcional do anexo.';
COMMENT ON COLUMN pdca.anexo.id_origem IS 'Identificador do registro relacionado a categoria do anexo.';
COMMENT ON COLUMN pdca.anexo.nome_arquivo IS 'Nome original ou apresentado do arquivo.';
COMMENT ON COLUMN pdca.anexo.tipo_arquivo IS 'Tipo MIME do arquivo.';
COMMENT ON COLUMN pdca.anexo.tamanho_arquivo IS 'Tamanho do arquivo em bytes.';
COMMENT ON COLUMN pdca.anexo.bucket_arquivo IS 'Bucket de armazenamento do arquivo.';
COMMENT ON COLUMN pdca.anexo.caminho_arquivo IS 'Caminho ou chave do arquivo no armazenamento.';
COMMENT ON COLUMN pdca.anexo.status IS 'Situacao do processamento e disponibilidade do anexo.';
COMMENT ON COLUMN pdca.anexo.descricao IS 'Descricao opcional do anexo.';
COMMENT ON COLUMN pdca.anexo.criado_em IS 'Data e hora de criacao do registro.';
COMMENT ON COLUMN pdca.anexo.atualizado_em IS 'Data e hora da ultima atualizacao do registro.';
COMMENT ON COLUMN pdca.anexo.excluido_em IS 'Data e hora de exclusao logica do anexo.';

-- Schema auditoria
COMMENT ON TABLE auditoria.catalogo_dados IS 'Catalogo de metadados das tabelas e colunas do banco.';
COMMENT ON COLUMN auditoria.catalogo_dados.id IS 'Identificador unico do item de catalogo.';
COMMENT ON COLUMN auditoria.catalogo_dados.nome_schema IS 'Schema onde a coluna esta definida.';
COMMENT ON COLUMN auditoria.catalogo_dados.tabela IS 'Nome da tabela catalogada.';
COMMENT ON COLUMN auditoria.catalogo_dados.coluna IS 'Nome da coluna catalogada.';
COMMENT ON COLUMN auditoria.catalogo_dados.tipo_dado IS 'Tipo de dado da coluna.';
COMMENT ON COLUMN auditoria.catalogo_dados.eh_pk IS 'Indica se a coluna compoe a chave primaria.';
COMMENT ON COLUMN auditoria.catalogo_dados.eh_fk IS 'Indica se a coluna compoe uma chave estrangeira.';
COMMENT ON COLUMN auditoria.catalogo_dados.referencia IS 'Referencia da chave estrangeira, quando houver.';
COMMENT ON COLUMN auditoria.catalogo_dados.obrigatorio IS 'Indica se a coluna e obrigatoria.';
COMMENT ON COLUMN auditoria.catalogo_dados.regra_negocio IS 'Regra de negocio associada a coluna.';
COMMENT ON COLUMN auditoria.catalogo_dados.nivel_acesso IS 'Nivel de acesso ou sensibilidade da coluna.';
COMMENT ON COLUMN auditoria.catalogo_dados.observacao IS 'Observacoes adicionais sobre a coluna.';
COMMENT ON COLUMN auditoria.catalogo_dados.criado_em IS 'Data e hora de criacao do registro.';

COMMENT ON TABLE auditoria.atv_usuario_dia IS 'Resumo de atividade diaria dos usuarios.';
COMMENT ON COLUMN auditoria.atv_usuario_dia.id IS 'Identificador unico do registro de atividade.';
COMMENT ON COLUMN auditoria.atv_usuario_dia.id_usuario IS 'Usuario associado a atividade.';
COMMENT ON COLUMN auditoria.atv_usuario_dia.data_atv IS 'Data de referencia da atividade.';
COMMENT ON COLUMN auditoria.atv_usuario_dia.hora_inicio IS 'Inicio da janela de atividade.';
COMMENT ON COLUMN auditoria.atv_usuario_dia.hora_fim IS 'Fim da janela de atividade.';
COMMENT ON COLUMN auditoria.atv_usuario_dia.qnt_acoes IS 'Quantidade de acoes realizadas no periodo.';

COMMENT ON TABLE auditoria.log_auditoria IS 'Logs genericos de auditoria de operacoes em registros.';
COMMENT ON COLUMN auditoria.log_auditoria.id IS 'Identificador unico do log de auditoria.';
COMMENT ON COLUMN auditoria.log_auditoria.id_usuario IS 'Usuario associado a operacao auditada.';
COMMENT ON COLUMN auditoria.log_auditoria.id_registro IS 'Identificador do registro afetado.';
COMMENT ON COLUMN auditoria.log_auditoria.tabela IS 'Tabela onde a operacao ocorreu.';
COMMENT ON COLUMN auditoria.log_auditoria.operacao IS 'Tipo de operacao auditada.';
COMMENT ON COLUMN auditoria.log_auditoria.dados_antes IS 'Estado do registro antes da operacao.';
COMMENT ON COLUMN auditoria.log_auditoria.dados_depois IS 'Estado do registro depois da operacao.';
COMMENT ON COLUMN auditoria.log_auditoria.data_log IS 'Data e hora de criacao do log.';

COMMENT ON TABLE auditoria.log_status IS 'Historico de alteracoes de status de registros.';
COMMENT ON COLUMN auditoria.log_status.id IS 'Identificador unico do log de status.';
COMMENT ON COLUMN auditoria.log_status.id_usuario IS 'Usuario responsavel pela alteracao.';
COMMENT ON COLUMN auditoria.log_status.id_registro IS 'Identificador do registro alterado.';
COMMENT ON COLUMN auditoria.log_status.tabela IS 'Tabela do registro alterado.';
COMMENT ON COLUMN auditoria.log_status.status_anterior IS 'Status antes da alteracao.';
COMMENT ON COLUMN auditoria.log_status.status_atual IS 'Status depois da alteracao.';
COMMENT ON COLUMN auditoria.log_status.data_log IS 'Data e hora da alteracao de status.';

COMMENT ON TABLE auditoria.log_colaborador IS 'Logs de auditoria especificos de colaboradores.';
COMMENT ON COLUMN auditoria.log_colaborador.id IS 'Identificador unico do log de colaborador.';
COMMENT ON COLUMN auditoria.log_colaborador.id_colaborador IS 'Colaborador associado ao log.';
COMMENT ON COLUMN auditoria.log_colaborador.id_usuario IS 'Usuario responsavel pela operacao.';
COMMENT ON COLUMN auditoria.log_colaborador.operacao IS 'Tipo de operacao auditada.';
COMMENT ON COLUMN auditoria.log_colaborador.dados_antes IS 'Estado do registro antes da operacao.';
COMMENT ON COLUMN auditoria.log_colaborador.dados_depois IS 'Estado do registro depois da operacao.';
COMMENT ON COLUMN auditoria.log_colaborador.data_log IS 'Data e hora de criacao do log.';

COMMENT ON TABLE auditoria.log_acesso_usuario IS 'Logs de acesso de usuarios a ciclos e funcionalidades.';
COMMENT ON COLUMN auditoria.log_acesso_usuario.id IS 'Identificador unico do log de acesso.';
COMMENT ON COLUMN auditoria.log_acesso_usuario.id_usuario IS 'Usuario que realizou o acesso.';
COMMENT ON COLUMN auditoria.log_acesso_usuario.id_ciclo IS 'Ciclo PDCA acessado, quando aplicavel.';
COMMENT ON COLUMN auditoria.log_acesso_usuario.acao_realizada IS 'Acao realizada pelo usuario.';
COMMENT ON COLUMN auditoria.log_acesso_usuario.acessado_em IS 'Data e hora do acesso.';

COMMENT ON TABLE auditoria.log_tarefa IS 'Logs de auditoria especificos de tarefas.';
COMMENT ON COLUMN auditoria.log_tarefa.id IS 'Identificador unico do log de tarefa.';
COMMENT ON COLUMN auditoria.log_tarefa.id_tarefa IS 'Tarefa associada ao log.';
COMMENT ON COLUMN auditoria.log_tarefa.id_usuario IS 'Usuario responsavel pela operacao.';
COMMENT ON COLUMN auditoria.log_tarefa.dados_antes IS 'Estado da tarefa antes da operacao.';
COMMENT ON COLUMN auditoria.log_tarefa.dados_depois IS 'Estado da tarefa depois da operacao.';
COMMENT ON COLUMN auditoria.log_tarefa.data_log IS 'Data e hora de criacao do log.';
COMMENT ON COLUMN auditoria.log_tarefa.operacao IS 'Tipo de operacao auditada.';
