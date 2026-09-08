CREATE TYPE status_emprestimo_enum AS ENUM (
    'ativo',
    'finalizado'
);


CREATE TABLE emprestimos (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    cliente_id integer NOT NULL,
    exemplar_id integer NOT NULL,

    funcionario_criacao_id integer NOT NULL,
    funcionario_fim_id integer,

    dataCriacao timestamptz NOT NULL DEFAULT now(),
    dataPrevistaDevolucao date NOT NULL,
    dataFim timestamptz,

    quantidadeRenovacoes integer NOT NULL DEFAULT 0,
    status status_emprestimo_enum NOT NULL DEFAULT 'ativo',

    periodo tstzrange GENERATED ALWAYS AS (
        tstzrange(
            data_criacao,
            data_fim,
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

    CONSTRAINT emprestimos_funcionario_fim_id_fk
        FOREIGN KEY (funcionario_fim_id)
        REFERENCES funcionarios (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT emprestimos_quantidade_renovacoes_check
        CHECK (quantidadeRenovacoes >= 0),

    CONSTRAINT emprestimos_data_prevista_check
        CHECK (
            dataPrevistaDevolucao >= dataCriacao::date
        ),

    CONSTRAINT emprestimos_data_fim_check
        CHECK (
            dataFim IS NULL
            OR dataFim >= dataCriacao
        ),

    CONSTRAINT emprestimos_status_data_fim_check
        CHECK (
            (
                status = 'ativo'
                AND dataFim IS NULL
                AND funcionario_fim_id IS NULL
            )
            OR
            (
                status = 'finalizado'
                AND data_fim IS NOT NULL
                AND funcionario_fim_id IS NOT NULL
            )
        ),

    CONSTRAINT emprestimos_exemplar_periodo_exclude
        EXCLUDE USING gist (
            exemplar_id WITH =,
            periodo WITH &&
        )
        DEFERRABLE INITIALLY IMMEDIATE
);