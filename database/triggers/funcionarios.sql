CREATE TRIGGER verificacao_contato_funcionarios_trigger
BEFORE INSERT OR UPDATE
ON funcionarios
FOR EACH ROW
EXECUTE verificacao_contato_function();