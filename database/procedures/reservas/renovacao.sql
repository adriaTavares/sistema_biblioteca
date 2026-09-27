CREATE OR REPLACE PROCEDURE renovacao_reserva_procedure(
    reserva_id_p BIGINT,
    funcionario_id_p BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    reserva_v reservas;
    funcionario_v funcionarios;
    configuracoes_v configuracoes;
BEGIN

    SELECT *
    INTO reserva_v
    FROM reservas
    WHERE id = reserva_id_p
    FOR UPDATE;


    SELECT id, ativo, nome
    INTO funcionario_v
    FROM funcionarios
    WHERE id = funcionario_id_p
    FOR UPDATE;


    SELECT
        tempo_adicionado_renovacao_reserva_processando,
        maximo_renovacoes_por_reserva
    INTO configuracoes_v
    FROM configuracoes
    LIMIT 1;


    -- Validações
    BEGIN

        IF reserva_v.id IS NULL THEN

            RAISE EXCEPTION
                'Reserva % não existe.',
                emprestimo_id_p;

        ELSIF reserva_v.status != 'processando' THEN

            RAISE EXCEPTION
                'Reserva % está % e não pode ser renovada.',
                reserva_v.id,
                reserva_v.status;

        ELSIF 
            reserva_v.quantidade_renovacoes >= 
            configuracoes_v.maximo_renovacoes_por_reserva

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


        IF reserva_v.quantidade_renovacoes >=
           configuracoes_v.maximo_renovacoes_por_emprestimo
        THEN

            RAISE EXCEPTION
                'Empréstimo % já atingiu o número máximo de renovações: %.',
                reserva_v.id,
                configuracoes_v.maximo_renovacoes_por_emprestimo;

        END IF;

    END;


    UPDATE reservas
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