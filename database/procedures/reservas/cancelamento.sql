CREATE OR REPLACE PROCEDURE cancelamento_reserva_procedure(
    reserva_id_p BIGINT,
    funcionario_id_p BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    reserva_v reservas;
    funcionario_v funcionarios;
BEGIN

    -- Reserva
    SELECT *
    INTO reserva_v
    FROM reservas
    WHERE id = reserva_id_p
    FOR UPDATE;


    -- Funcionário
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

        ELSIF reserva_v.status NOT IN ('ativa', 'processando') THEN

            RAISE EXCEPTION
                'Reserva % está % e não pode ser cancelada.',
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

    END;


    -- Cancelamento
    UPDATE reservas
    SET
        status = 'cancelada',
        data_cancelamento = now(),
        funcionario_cancelamento_id = funcionario_id_p
    WHERE id = reserva_id_p;


    -- Se havia exemplar reservado, libera
    IF reserva_v.exemplar_id IS NOT NULL THEN

        UPDATE exemplares
        SET status = 'disponível'
        WHERE id = reserva_v.exemplar_id;

    END IF;

END;
$$;