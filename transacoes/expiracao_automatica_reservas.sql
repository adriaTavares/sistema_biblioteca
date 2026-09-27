BEGIN
    WITH reservas_expiradas AS (
        SELECT id, exemplar_id
        FROM reservas
        WHERE 
            status = 'processando'
            AND
            data_expiracao_processamento < current_date
    ),
    reservas_atualizadas(
        UPDATE reservas
        SET status = 'expirada'
        WHERE id = SOME(reservas_expiradas.id)
        RETURNING *
    )
    UPDATE exemplares
    SET status = 'disponível'
    WHERE id = SOMEE(reservas_atualizadas.exemplar_id);

END;