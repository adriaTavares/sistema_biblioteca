CREATE TYPE reservas_status AS ENUM (
    'ativa',
    'processando',
    'finalizada',
    'expirada',
    'cancelada'
)

CREATE TABLE reservas (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cliente_id integer NOT NULL,
    livro_id integer NOT NULL,
    exemplar_id integer,
    data_criacao timestamptz NOT NULL DEFAULT now(),
    data_processamento timestamptz,
    data_expiracao date,
    data_finalizacao timestamptz,
    data_cancelamento timestamptz,
    funcionario_criacao_id integer NOT NULL,
    funcionario_finalizacao_id integer,
    funcionario_cancelamento_id integer,
    status reservas_status NOT NULL DEFAULT 'ativa',

    CONSTRAINT reservas_clientes_id_fk
        FOREIGN KEY (cliente_id)
        REFERENCES clientes (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT reservas_livros_id_fk
        FOREIGN KEY (livro_id)
        REFERENCES livros (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT reservas_exemplares_id_fk
        FOREIGN KEY (exemplar_id, livro_id)
        REFERENCES exemplares (id, livro_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT reservas_funcionario_criacao_id_fk
        FOREIGN KEY (funcionario_criacao_id)
        REFERENCES funcionarios (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT reservas_funcionario_cancelamento_id_fk
        FOREIGN KEY (funcionario_cancelamento_id)
        REFERENCES funcionarios (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT reservas_funcionario_finalizacao_id_fk
        FOREIGN KEY (funcionario_finalizacao_id)
        REFERENCES funcionarios (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT reservas_consistencia_funcionario_data_criacao
        CHECK (
            (
                data_criacao IS NOT NULL 
                AND
                funcionario_criacao_id IS NOT NULL
            )
            OR 
            (
                data_criacao IS NULL
                AND 
                funcionario_criacao_id IS NULL
            )
        ),

    CONSTRAINT reservas_consistencia_funcionario_data_finalizacao
        CHECK (
            (
                data_finalizacao IS NULL 
                AND
                funcionario_finalizacao_id IS NULL
            )
            OR 
            (
                data_finalizacao IS NOT NULL
                AND 
                funcionario_finalizacao_id IS NOT NULL
            )
        ),

    CONSTRAINT reservas_consistencia_funcionario_data_cancelamento
        CHECK (
            (
                data_cancelamento IS NULL 
                AND
                funcionario_cancelamento_id IS NULL
            )
            OR 
            (
                data_cancelamento IS NOT NULL
                AND 
                funcionario_cancelamento_id IS NOT NULL
            )
        )
);

CREATE INDEX reservas

CREATE FUNCTION criar_reserva (
    livro_id_c integer,
    cliente_id_c integer,
    funcionario_id_c integer
)
RETURNS reservas
LANGUAGE plpgsql
AS $$
    DECLARE 
        livros_parcial livros,
        clientes_parcial clientes,
        funcionarios_parcial funcionarios;
    BEGIN

        SELECT id, status, nome
        INTO livros_parcial
        FROM livros
        WHERE id = livro_id_c;

        IF
        livros_parcial.status = false OR livros_parcial.id IS NULL
        THEN RAISE EXCEPTION 'Livro %, não está mais ativo ou não existe.', initcap(livros_parcial.nome);

        SELECT id, status, nome
        INTO clientes_parcial
        FROM clientes
        WHERE id = cliente_id_c;

        IF 
        clientes_parcial.status = false OR clientes_parcial.id IS NULL
        THEN RAISE EXCEPTION 'Cliente %, não está mais ativo ou não existe.', initcap(clientes_parcial.nome);



        SELECT id, status, nome
        INTO funcionarios_parcial
        FROM funcionarios
        WHERE id = funcionario_id_c;

        IF 
        funcionarios_parcial.status = false OR funcionarios_parcial.id IS NULL
        THEN RAISE EXCEPTION 'Funcionário %, não está mais ativo ou não existe.', initcap(funcionarios_parcial.nome);


       RETURN (
            INSERT INTO reservas(
                cliente_id,
                funcionario_id,
                livro_id
            )
            VALUES(
                cliente_id_c,
                funcionario_id_c,
                livro_id_c
            ) RETURNING *
        )
    END;
$$;

-- carregar reservas e atualizar

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
        WHERE e.status = 'disponivel'
        AND EXISTS (
            SELECT 1
            FROM reservas_ativas AS ra
            WHERE ra.livro_id = e.livro_id
        )
        ORDER BY e.livro_id, e.id
        FOR UPDATE SKIP LOCKED
    ),

    reservas_atendidas AS (
        UPDATE reservas AS r
        SET
            status = 'processando',
            dataProcessamento = now(),
            exemplar_id = ed.exemplar_id,
            dataExpiracao = current_date
                + conf.tempo_expiracao_reserva:: INTEGER * INTERVAL '1 day'
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