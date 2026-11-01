# Procedimentos de Backup e Recuperação do Banco

Este documento descreve como gerar backups e realizar a restauração do banco de dados PostgreSQL do ACTA, garantindo a segurança dos dados caso ocorra algum problema.

## Backup

O backup deve ser feito diariamente, de preferência em horários de baixo uso, e obrigatoriamente antes de qualquer deploy ou alteração.

Comando para gerar o backup:

```
pg_dump -Fc -f meu_backup.dump nome_do_banco
```

O que esse comando faz:

* `-Fc` gera o backup em formato customizado;
* `-f` define o nome do arquivo que será criado;
* `nome_do_banco` nome do banco de dados que você quer copiar.

## O backup deve guardar:

O arquivo .dump gerado inclui toda a estrutura e massa de dados do banco:

* Schemas (public, pdca, auditoria);
* Tabelas, colunas, chaves primárias e estrangeiras;
* Triggers, funções, procedures e views;
* Tabela de logs de auditoria.

## Validação do Arquivo de Backup

Depois de criar o backup, é necessário verificar se o arquivo foi gerado corretamente:

```
pg_restore --list meu_backup.dump
```

Se o terminal listar as tabelas, funções e schemas sem erros, o arquivo está íntegro e pronto para uso.

## Procedimento de Restauração

Caso ocorra uma falha, os dados podem ser recuperados utilizando o arquivo de backup. Porém, por precaução, é sempre importante ter uma banco de teste para executar esses comandos e depois passar para o banco em produção.

```
createdb -h localhost -U postgres acta_restaurado
```

Depois, o backup pode ser restaurado nesse banco:

```
pg_restore -h localhost -U postgres -d acta_restaurado --clean --if-exists -v "meu_backup.dump"
```

Nesse comando:

* `--clean` limpa objetos antigos antes de recriá-los;
* `--if-exists` evita mensagens de erro caso algum objeto ainda não exista na base limpa;
* `-v` ativa o detalhamento do log do processo, assim o terminal mostra o que está sendo restaurado;

## Testes após a recuperação

Após restaurar o banco, devem ser realizados alguns testes:

* verificar se as principais tabelas existem;
* verificar se os registros foram recuperados;
* testar o cadastro de uma informação;
* verificar se os relacionamentos continuam funcionando;
* verificar se os registros de auditoria continuam sendo criados;
* testar o acesso do sistema ao banco.

## Registro da operação

Cada backup ou recuperação deve ser registrado com:

* data da operação;
* nome do responsável;
* tipo de operação;
* nome do arquivo utilizado;
* resultado da operação;

Esse registro ajuda a saber quando o backup foi realizado, quem realizou a operação e se ocorreu algum problema.