CREATE FUNCTION criar_emprestimo(
    cliente_id_p BIGINT,
    exemplar_id_p BIGINT,
    funcionario_id_p BIGINT,
    quantidade_dias INTEGER := NULL
)
LANGUAGE plpgsql
RETURNS emprestimos
AS $$
    DECLARE 
        exemplar_parcial exemplares,
        clientes_parcial clientes,
        funcionarios_parcial funcionarios;
    BEGIN

        SELECT id, status, nome
        INTO exemplar_parcial
        FROM exemplares
        WHERE id = exemplar_id_p;

        IF
        exemplar_parcial.status != "disponivel" OR exemplar_parcial.id IS NULL
        THEN RAISE EXCEPTION 'Exemplar %, não está disponível ou não existe.', initcap
        (exemplar_parcial.nome);

        SELECT id, status, nome
        INTO clientes_parcial
        FROM clientes
        WHERE id = cliente_id_p;

        IF 
        clientes_parcial.status = false OR clientes_parcial.id IS NULL
        THEN RAISE EXCEPTION 'Cliente %, não está mais ativo ou não existe.', initcap(clientes_parcial.nome);

        SELECT id, status, nome
        INTO funcionarios_parcial
        FROM funcionarios
        WHERE id = funcionario_id_c;

        IF 
        funcionarios_parcial.status = false OR funcionarios_parcial.id IS NULL
        THEN RAISE EXCEPTION 'Funcionário %, não está mais ativo ou não existe.', initcap(funcionarios_parcial.nome);