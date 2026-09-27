CREATE OR REPLACE PROCEDURE finalizacao_emprestimo_procedure(
    emprestimo_id_p BIGINT,
    funcionario_id_p BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    emprestimo_v emprestimos;
    funcionario_v funcionarios;
BEGIN

    -- Empréstimo
    SELECT *
    INTO emprestimo_v
    FROM emprestimos
    WHERE id = emprestimo_id_p
    FOR UPDATE;


    -- Funcionário
    SELECT id, ativo, nome
    INTO funcionario_v
    FROM funcionarios
    WHERE id = funcionario_id_p
    FOR UPDATE;


    -- Validações
    BEGIN

        IF emprestimo_v.id IS NULL THEN

            RAISE EXCEPTION
                'Empréstimo % não existe.',
                emprestimo_id_p;

        ELSIF emprestimo_v.status != 'ativo' THEN

            RAISE EXCEPTION
                'Empréstimo % está % e não pode ser finalizado.',
                emprestimo_v.id,
                emprestimo_v.status;

        END IF;


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


    UPDATE emprestimos
    SET
        status = 'finalizado',
        funcionario_finalizacao_id = funcionario_id_p,
        data_finalizacao = now()
    WHERE id = emprestimo_id_p;


    UPDATE exemplares
    SET status = 'disponível'
    WHERE id = emprestimo_v.exemplar_id;

END;
$$;