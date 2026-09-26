CREATE OR REPLACE PROCEDURE renovacao_emprestimo_procedure(
    emprestimo_id_p BIGINT,
    funcionario_id_p BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    emprestimo_v emprestimos;
    funcionario_v funcionarios;
    configuracoes_v configuracoes;
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


    -- Configurações
    SELECT
        tempo_adicionado_renovacao_emprestimo,
        maximo_renovacoes_por_emprestimo
    INTO configuracoes_v
    FROM configuracoes
    LIMIT 1;


    -- Validações
    BEGIN

        IF emprestimo_v.id IS NULL THEN

            RAISE EXCEPTION
                'Empréstimo % não existe.',
                emprestimo_id_p;

        ELSIF emprestimo_v.status != 'ativo' THEN

            RAISE EXCEPTION
                'Empréstimo % está % e não pode ser renovado.',
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


        IF emprestimo_v.quantidade_renovacoes >=
           configuracoes_v.maximo_renovacoes_por_emprestimo
        THEN

            RAISE EXCEPTION
                'Empréstimo % já atingiu o número máximo de renovações: %.',
                emprestimo_v.id,
                configuracoes_v.maximo_renovacoes_por_emprestimo;

        END IF;

    END;


    -- Atualização do empréstimo
    UPDATE emprestimos
    SET
        data_prevista_devolucao =
            data_prevista_devolucao +
            (
                configuracoes_v.tempo_adicionado_renovacao_emprestimo
                * INTERVAL '1 day'
            ),
        quantidade_renovacoes = quantidade_renovacoes + 1
    WHERE id = emprestimo_id_p;

END;
$$;