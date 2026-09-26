CREATE FUNCTION criar_reserva (
    livro_id_c integer,
    cliente_id_c integer,
    funcionario_id_c integer
)
RETURNS reservas
LANGUAGE plpgsql
AS $$
    DECLARE 
        livros_parcial livros,
        clientes_parcial clientes,
        funcionarios_parcial funcionarios;
    BEGIN

        SELECT id, status, nome
        INTO livros_parcial
        FROM livros
        WHERE id = livro_id_c;

        IF
        livros_parcial.status = false OR livros_parcial.id IS NULL
        THEN RAISE EXCEPTION 'Livro %, não está mais ativo ou não existe.', initcap(livros_parcial.nome);

        SELECT id, status, nome
        INTO clientes_parcial
        FROM clientes
        WHERE id = cliente_id_c;

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


       RETURN (
            INSERT INTO reservas(
                cliente_id,
                funcionario_id,
                livro_id
            )
            VALUES(
                cliente_id_c,
                funcionario_id_c,
                livro_id_c
            ) RETURNING *
        )
    END;
$$;




