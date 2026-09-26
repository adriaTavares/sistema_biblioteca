
CREATE OR REPLACE FUNCTION cancelar_reserva(
    reserva_id_p bigint,
    funcionario_id_p integer
)
RETURNS reservas
LANGUAGE plpgsql
AS $$
    DECLARE
        reservas_parcial reservas,
        funcionarios_parcial funcionarios,
        retorno reservas;
    BEGIN

        SELECT id, status, nome
        INTO funcionarios_parcial
        FROM funcionarios
        WHERE id = funcionario_id_c;

        IF 
        funcionarios_parcial.status = false OR funcionarios_parcial.id IS NULL
        THEN RAISE EXCEPTION 'Funcionário %, não está mais ativo ou não existe.', initcap(funcionarios_parcial.nome);


        SELECT
            id,
            exemplar_id,
            status
        FROM reservas
        INTO reservas_parcial
        WHERE id = reserva_id_p
        FOR UPDATE;


        IF reservas_parcial IS NULL 
            THEN
                RAISE EXCEPTION 'Reserva não encontrada.';
        ELSIF reservas_parcial.status NOT IN ('ativa', 'processando') 
            THEN
                RAISE EXCEPTION 'Reserva não pode ser cancelada.';
        END IF;


        WITH reserva_atualizada AS (
            UPDATE reservas AS r
            SET
                status = 'cancelada',
                data_cancelamento = now(),
                funcionario_cancelamento_id = funcionario_id_p
            FROM reservas_parcial AS rv
            WHERE r.id = rv.id
            RETURNING r.*
            INTO retorno
        )
        IF reserva_atualizada.exemplar_id IS NOT NULL
        THEN (
                UPDATE exemplares AS e
                SET status = 'disponivel'
                FROM reserva_atualizada AS ra
                WHERE e.id = ra.exemplar_id
            )
        END IF;
        RETURN retorno;
    END;
$$;


CREATE FUNCTION finalizar_reserva(
    reserva_id_p bigint,
    funcionario_id_p integer
)
LANGUAGE plpgsql
RETURNS reservas
AS $$
    DECLARE
        reservas_parcial reservas;
    BEGIN