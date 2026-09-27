CREATE OR REPLACE PROCEDURE adicionar_funcionario_procedure(
    nome_p TEXT,
    cargo_nome_p TEXT,
    email_p TEXT,
    telefone_p TEXT,
    cpf_p TEXT,
    login TEXT,
    data_nascimento_p DATE,
    senha_p TEXT,
    funcionario_criacao_id_p BIGINT
)
LANGUAGE plpgsql AS $$
DECLARE 
    funcionario_v funcionarios;
    cargo_v cargos;
    dados_duplicados record;

BEGIN

    SELECT * 
    INTO funcionario_v
    FROM funcionarios
    WHERE id = funcionario_criacao_id_p;

    SELECT nome
    INTO cargo_v
    FROM cargos_funcionarios
    WHERE nome = cargo_nome_p

    SELECT
        email,
        telefone,
        cpf,
        login,
        email = email_p AS email_encontrado,
        telefone = telefone_p AS telefone_encontrado,
        cpf = cpf_p AS cpf_encontrado
        login = login_p AS login_encontrado
    INTO dados_duplicados
    FROM funcionarios
    WHERE 
        email = email_p
        OR 
        telefone = telefone_p
        OR
        cpf = cpf_p
        OR 
        login = login_p;


    IF
        cargo_v IS NULL
    THEN 
        RAISE EXCETION 'Cargo % não existe.', cargo_nome_p;
    ELSIF 
        funcionario_v.id IS NULL 
    THEN
        RAISE EXCEPTION
            'Funcionário % não existe.',
            funcionario_id_p;
    ELSIF 
        NOT funcionario_v.ativo 
    THEN
        RAISE EXCEPTION
            'Funcionário % está desativado.',
            funcionario_v.nome;
    END IF;

    IF
        dados_duplicados.email_encontrado
    THEN
        RAISE EXCEPTION
            'Já existe um funcionário com o e-mail: %.',
            dados_duplicados.email;
    ELSIF
        dados_duplicados.telefone_encontrado
    THEN 
        RAISE EXCEPTION
            'Já existe um funcionário com o telefone: %.',
            dados_duplicados.telefone;
    ELSIF
        dados_duplicados.cpf_encontrado
    THEN
        RAISE EXCEPTION
            'Já existe um funcionário com o cpf: %.',
            dados_duplicados.cpf;
    ELSIF
        dados_duplicados.login
    THEN
        RAISE EXCEPTION
            'Já existe um funcionário com o login: %.',
            dados_duplicados.login;
    END IF;

    INSERT INTO funcionarios(
        nome,
        email,
        telefone,
        cpf,
        login,
        data_nascimento,
        senha
    )
END; 
$$;