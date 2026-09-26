CREATE OR REPLACE PROCEDURE criar_emprestimo_procedure(
    cliente_id_p BIGINT,
    exemplar_id_p BIGINT,
    funcionario_id_p BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    exemplar_v exemplares;
    livro_v livros;
    clientes_v clientes;
    funcionario_v funcionarios;
    configuracoes_v configuracoes;
BEGIN

    -- Exemplar
    SELECT id, status, livro_id, codigo
    INTO exemplar_v
    FROM exemplares
    WHERE id = exemplar_id_p
    FOR UPDATE;


    -- Livro
    SELECT id, ativo, titulo
    INTO livro_v
    FROM livros
    WHERE id = exemplar_v.livro_id
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


    -- Configurações
    SELECT
        tempo_expiracao_emprestimo,
        tempo_adicionado_renovacao_emprestimo,
        maximo_renovacoes_por_emprestimo,
        maximo_emprestimos_por_cliente,
        maximo_emprestimos_mesmo_livro
    INTO configuracoes_v
    FROM configuracoes
    LIMIT 1;


    -- Validações
    BEGIN

        -- Exemplar

        IF exemplar_v.id IS NULL THEN

            RAISE EXCEPTION
                'Exemplar % não existe.',
                exemplar_id_p;

        ELSIF exemplar_v.status != 'disponível' THEN

            RAISE EXCEPTION
                'Exemplar % está atualmente %.',
                exemplar_v.codigo,
                exemplar_v.status;

        ELSIF livro_v.id IS NULL THEN

            RAISE EXCEPTION
                'O livro associado ao exemplar % não existe.',
                exemplar_v.codigo;

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


        -- Limite de empréstimos do cliente

        IF configuracoes_v.maximo_emprestimos_por_cliente IS NOT NULL
           AND configuracoes_v.maximo_emprestimos_por_cliente > 0
        THEN

            IF (
                SELECT COUNT(*)
                FROM emprestimos
                WHERE cliente_id = clientes_v.id
                  AND status = 'ativo'
            ) >= configuracoes_v.maximo_emprestimos_por_cliente
            THEN

                RAISE EXCEPTION
                    'Cliente % já atingiu o número máximo de empréstimos: %.',
                    clientes_v.nome,
                    configuracoes_v.maximo_emprestimos_por_cliente;

            END IF;

        END IF;


        -- Limite de empréstimos do mesmo livro

        IF configuracoes_v.maximo_emprestimos_mesmo_livro IS NOT NULL
           AND configuracoes_v.maximo_emprestimos_mesmo_livro > 0
        THEN

            IF (
                SELECT COUNT(*)
                FROM emprestimos e
                INNER JOIN exemplares ex
                    ON ex.id = e.exemplar_id
                WHERE e.cliente_id = cliente_id_p
                  AND ex.livro_id = livro_v.id
                  AND e.status = 'ativo'
            ) >= configuracoes_v.maximo_emprestimos_mesmo_livro
            THEN

                RAISE EXCEPTION
                    'Cliente % já atingiu o número máximo de empréstimos para o livro "%".',
                    clientes_v.nome,
                    livro_v.titulo;

            END IF;

        END IF;

    END;


    -- Criação do empréstimo

    INSERT INTO emprestimos (
        cliente_id,
        funcionario_criacao_id,
        exemplar_id,
        data_prevista_devolucao
    )
    VALUES (
        cliente_id_p,
        funcionario_id_p,
        exemplar_id_p,
        current_date +
            (configuracoes_v.tempo_expiracao_emprestimo * INTERVAL '1 day')
    );


    -- Atualização do exemplar

    UPDATE exemplares
    SET status = 'emprestado'
    WHERE id = exemplar_v.id;

END;
$$;