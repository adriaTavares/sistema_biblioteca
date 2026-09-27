BEGIN;
    WITH reservas_ativas AS (
        SELECT
            id,
            livro_id,
            ROW_NUMBER() OVER (
                PARTITION BY livro_id
                ORDER BY data_criacao ASC, id ASC
            ) AS rn
        FROM reservas
        WHERE status = 'ativa'
        FOR UPDATE SKIP LOCKED
        LIMIT 20
    ),

    exemplares_disponiveis AS (
        SELECT
            e.id AS exemplar_id,
            e.livro_id,
            ROW_NUMBER() OVER (
                PARTITION BY e.livro_id
                ORDER BY e.id ASC
            ) AS rn
        FROM exemplares AS e
        WHERE e.status = 'disponível'
        AND EXISTS (
            SELECT 1
            FROM reservas_ativas AS ra
            WHERE ra.livro_id = e.livro_id
        )
        FOR UPDATE SKIP LOCKED
        LIMIT 20
    ),

    reservas_atendidas AS (
        UPDATE reservas AS r
        SET
            status = 'processando',
            data_processamento = now(),
            exemplar_id = ed.exemplar_id,
            data_expiracao_processamento = current_date
                + (conf.tempo_expiracao_reserva_processando * INTERVAL '1 day')
        FROM exemplares_disponiveis AS ed
        INNER JOIN reservas_ativas AS ra
            ON ed.livro_id = ra.livro_id
            AND ed.rn = ra.rn
        CROSS JOIN configuracoes AS conf
        WHERE r.id = ra.id
        RETURNING r.*
    )

    UPDATE exemplares AS e
    SET status = 'processando'
    FROM reservas_atendidas AS ra
    WHERE e.id = ra.exemplar_id;
COMMIT;
