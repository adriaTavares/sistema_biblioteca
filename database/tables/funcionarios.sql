CREATE TABLE cargos_funcionarios (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome varchar(100) NOT NULL,

    CONSTRAINT cargos_funcionarios_nome_unique
        UNIQUE (nome),

    CONSTRAINT cargos_funcionarios_nome_check
        CHECK (btrim(nome) <> '')
);


INSERT INTO cargos_funcionarios (nome)
VALUES
    ('admin'),
    ('gerente'),
    ('bibliotecário');


CREATE TABLE funcionarios (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome varchar(100) NOT NULL,
    cargo_id integer NOT NULL,
    email varchar(255),
    telefone varchar(25),
    cpf varchar(11) NOT NULL,
    data_nascimento date NOT NULL,
    senha varchar(255) NOT NULL,
    ativo boolean NOT NULL DEFAULT true,

    CONSTRAINT funcionarios_nome_check
        CHECK (btrim(nome) <> ''),

    CONSTRAINT funcionarios_email_unique
        UNIQUE (email),

    CONSTRAINT funcionarios_telefone_unique
        UNIQUE (telefone),
    
    CONSTRAINT funcionarios_cpf_unique
        UNIQUE (cpf),

    CONSTRAINT cargos_funcionarios_id_fk
        FOREIGN KEY (cargo_id)
        REFERENCES cargos_funcionarios (id)
        ON DELETE SET DEFAULT
        ON UPDATE CASCADE,

    CONSTRAINT funcionario_cpf_check 
        CHECK (btrim(cpf) <> ''),

    CONSTRAINT funcionarios_senha_check
        CHECK (btrim(senha) <> '')
);

CREATE TRIGGER verificacao_contato_funcionarios_trigger
BEFORE INSERT OR UPDATE
ON funcionarios
FOR EACH ROW
EXECUTE verificacao_contato_function();
