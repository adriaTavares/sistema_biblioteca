CREATE TRIGGER verificacao_contato_clientes_trigger
BEFORE INSERT OR UPDATE
ON clientes
FOR EACH ROW
EXECUTE verificacao_contato_function();