CREATE TYPE reservas_status AS ENUM (
    'ativa',
    'processando',
    'finalizada',
    'expirada',
    'cancelada'
);

CREATE TABLE reservas (
    id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cliente_id integer NOT NULL,
    livro_id integer NOT NULL,
    exemplar_id integer,
    data_processamento timestamptz,
    data_expiracao_processamento date,

    quantidade_renovacoes int DEFAULT 0,

    data_criacao timestamptz NOT NULL DEFAULT now(),
    funcionario_criacao_id integer NOT NULL,
    
    data_finalizacao timestamptz,
    funcionario_finalizacao_id integer,

    data_cancelamento timestamptz,
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
        ),
        
    CONSTRAINT reservas_quantidade_renovacoes
        CHECK (
            quantidade_renovacoes >= 0
        )
);