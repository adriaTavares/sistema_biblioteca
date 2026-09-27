CREATE TABLE cargos_funcionarios (
    nome varchar(100) NOT NULL PRIMARY KEY,

    CONSTRAINT cargos_funcionarios_nome_unique
        UNIQUE (nome),

    CONSTRAINT cargos_funcionarios_nome_check
        CHECK (btrim(nome) <> '')
);


INSERT INTO cargos_funcionarios(nome)
VALUES
    ('adm'),
    ('gerente'),
    ('bibliotecário');


CREATE TABLE funcionarios (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome varchar(100) NOT NULL,
    login TEXT NOT NULL,
    cargo_nome text NOT NULL DEFAULT 'bibliotecário',
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

    CONSTRAINT cargos_funcionarios_nome_fk
        FOREIGN KEY (cargo_nome)
        REFERENCES cargos_funcionarios (nome)
        ON DELETE SET DEFAULT
        ON UPDATE CASCADE,

    CONSTRAINT funcionario_cpf_check 
        CHECK (btrim(cpf) <> ''),

    CONSTRAINT funcionario_login_check
        CHECK (btrim(login) != '')

    CONSTRAINT funcionarios_senha_check
        CHECK (btrim(senha) <> ''),

    CONSTRAINT funcionarios_contato_check
        CHECK (
            (btrim(email)) <> '' 
            OR 
            (btrim(telefone)) <> ''
        )
);
