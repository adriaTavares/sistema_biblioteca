CREATE OR REPLACE PROCEDURE criar_reserva_procedure(
    cliente_id_p BIGINT,
    livro_id_p BIGINT,
    funcionario_id_p BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    livro_v livros;
    clientes_v clientes;
    funcionario_v funcionarios;
BEGIN

    -- Livro
    SELECT id, ativo, titulo
    INTO livro_v
    FROM livros
    WHERE id = livro_id_p
    FOR UPDATE;


    -- Cliente
    SELECT id, ativo, nome
    INTO clientes_v
    FROM clientes
    WHERE id = cliente_id_p
    FOR UPDATE;


    -- Funcionário
    SELECT id, ativo, nome
    INTO funcionario_v
    FROM funcionarios
    WHERE id = funcionario_id_p
    FOR UPDATE;


    -- Validações
    BEGIN

        -- Livro

        IF livro_v.id IS NULL THEN

            RAISE EXCEPTION
                'O livro % não existe.',
                livro_id_p;

        ELSIF NOT livro_v.ativo THEN

            RAISE EXCEPTION
                'O livro "%" está desativado no sistema.',
                livro_v.titulo;

        END IF;


        -- Cliente

        IF clientes_v.id IS NULL THEN

            RAISE EXCEPTION
                'Cliente % não existe.',
                cliente_id_p;

        ELSIF NOT clientes_v.ativo THEN

            RAISE EXCEPTION
                'Cliente % está desativado no sistema.',
                clientes_v.nome;

        END IF;


        -- Funcionário

        IF funcionario_v.id IS NULL THEN

            RAISE EXCEPTION
                'Funcionário % não existe.',
                funcionario_id_p;

        ELSIF NOT funcionario_v.ativo THEN

            RAISE EXCEPTION
                'Funcionário % está desativado.',
                funcionario_v.nome;

        END IF;

    END;


    -- Criação da reserva

    INSERT INTO reservas (
        cliente_id,
        funcionario_criacao_id,
        livro_id
    )
    VALUES (
        cliente_id_p,
        funcionario_id_p,
        livro_id_p
    );

END;
$$;