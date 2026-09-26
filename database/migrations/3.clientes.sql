
CREATE TABLE clientes (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome varchar(100) NOT NULL,
    email varchar(255),
    telefone varchar(25),
    data_nascimento date NOT NULL,
    ativo boolean NOT NULL DEFAULT true,

    CONSTRAINT clientes_nome_check
        CHECK (btrim(nome) <> ''),

    CONSTRAINT clientes_email_unique
        UNIQUE (email),

    CONSTRAINT clientes_telefone_unique
        UNIQUE (telefone),

    CONSTRAINT clientes_data_nascimento_check
        CHECK (data_nascimento <= current_date)
);