CREATE OR REPLACE PROCEDURE finalizacao_reserva_procedure(
    reserva_id_p BIGINT,
    funcionario_id_p BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    reserva_v reservas;
    funcionario_v funcionarios;
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


    -- Validações
    BEGIN

        IF reserva_v.id IS NULL THEN

            RAISE EXCEPTION
                'Reserva % não existe.',
                reserva_id_p;

        ELSIF reserva_v.status != 'processando' THEN

            RAISE EXCEPTION
                'Reserva % está % e não pode ser finalizada.',
                reserva_v.id,
                reserva_v.status;

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


        IF reserva_v.exemplar_id IS NULL THEN

            RAISE EXCEPTION
                'Reserva % não possui exemplar associado.',
                reserva_v.id;

        END IF;


        IF reserva_v.data_expiracao_processamento < current_date THEN

            RAISE EXCEPTION
                'Reserva % já expirou.',
                reserva_v.id;

        END IF;

    END;


    CALL criar_emprestimo_procedure(
        reserva_v.cliente_id,
        reserva_v.exemplar_id,
        funcionario_id_p
    );


    UPDATE reservas
    SET
        status = 'finalizada',
        data_finalizacao = now(),
        funcionario_finalizacao_id = funcionario_id_p
    WHERE id = reserva_id_p;

END;
$$;