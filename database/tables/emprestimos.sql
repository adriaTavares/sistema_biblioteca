CREATE EXTENSION btree_gist;

CREATE TYPE status_emprestimo_enum AS ENUM (
    'ativo',
    'finalizado',
    'cancelado'
);


CREATE TABLE emprestimos (
    id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cliente_id integer NOT NULL,
    exemplar_id integer NOT NULL,

    funcionario_criacao_id integer NOT NULL,
    data_criacao timestamptz NOT NULL DEFAULT now(),

    funcionario_finalizacao_id integer,
    data_finalizacao timestamptz,

    funcionario_cancelamento_id integer,
    data_cancelamento timestamptz,

    data_prevista_devolucao date NOT NULL,
    quantidade_renovacoes integer NOT NULL DEFAULT 0,
    status status_emprestimo_enum NOT NULL DEFAULT 'ativo',
    periodo tstzrange GENERATED ALWAYS AS (
        tstzrange(
            data_criacao,
            data_finalizacao,
            '[)'
        )
    ) STORED,

    CONSTRAINT emprestimos_clientes_id_fk
        FOREIGN KEY (cliente_id)
        REFERENCES clientes (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT emprestimos_exemplares_id_fk
        FOREIGN KEY (exemplar_id)
        REFERENCES exemplares (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT emprestimos_funcionario_criacao_id_fk
        FOREIGN KEY (funcionario_criacao_id)
        REFERENCES funcionarios (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT emprestimos_funcionario_finalizacao_id_fk
        FOREIGN KEY (funcionario_finalizacao_id)
        REFERENCES funcionarios (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT emprestimos_quantidade_renovacoes_check
        CHECK (quantidadeRenovacoes >= 0),

    CONSTRAINT emprestimos_data_prevista_check
        CHECK (
            data_prevista_devolucao >= data_criacao::date
        ),

    CONSTRAINT emprestimos_data_finalizacao_check
        CHECK (
            data_finalizacao IS NULL
            OR data_finalizacao >= data_criacao
        ),

    CONSTRAINT emprestimos_status_data_finalizacao_check
        CHECK (
            (
                status = 'ativo'
                AND data_finalizacao IS NULL
                AND funcionario_finalizacao_id IS NULL
            )
            OR
            (
                status = 'finalizado'
                AND data_finalizacao IS NOT NULL
                AND funcionario_finalizacao_id IS NOT NULL
            )
        ),
    CONSTRAINT emprestimos_status_cancelamento_check
        CHECK (
            (
                status = 'ativo'
                AND data_cancelamento IS NULL
                AND funcionario_cancelamento_id IS NULL
            )
            OR
            (
                status = 'cancelado'
                AND data_cancelamento IS NOT NULL
                AND funcionario_cancelamento_id IS NOT NULL
            )
        ),

    CONSTRAINT emprestimos_exemplar_periodo_exclude
        EXCLUDE USING gist (
            exemplar_id WITH =,
            periodo WITH &&
        )
        DEFERRABLE INITIALLY IMMEDIATE
);


