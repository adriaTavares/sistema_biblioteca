CREATE OR REPLACE PROCEDURE adicionar_clientes_procedure(
    nome_p TEXT,
    email_p TEXT,
    cpf_p TEXT
    telefone_p TEXT,
    data_nascimento_p DATE,
    funcionario_criacao_id_p BIGINT
)
LANGUAGE plpgsql AS $$
DECLARE 
    funcionario_v funcionarios;
    dados_duplicados record;
    configuracoes_v configuracoes;

BEGIN

    SELECT * 
    INTO funcionario_v
    FROM funcionarios
    WHERE id = funcionario_criacao_id_p;

    SELECT * 
    INTO configuracoes_v
    FROM configuracoes;

    SELECT
        email,
        telefone,
        cpf,
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
        funcionario_v.id IS NULL 
    THEN
        RAISE EXCEPTION
            'Funcionário % não existe.',
            funcionario_id_p;
    ELSIF 
        NOT funcionario_v.ativo 
    THEN
        RAISE EXCEPTION
            'Cliente % está desativado.',
            funcionario_v.nome;
    ELSIF
        dados_duplicados.email_encontrado
    THEN
        RAISE EXCEPTION
            'Já existe um cliente com o e-mail: %.',
            dados_duplicados.email;
    ELSIF
        dados_duplicados.telefone_encontrado
    THEN 
        RAISE EXCEPTION
            'Já existe um cliente com o telefone: %.',
            dados_duplicados.telefone;
    ELSIF
        dados_duplicados.cpf_encontrado
    THEN
        RAISE EXCEPTION
            'Já existe um cliente com o cpf: %.',
            dados_duplicados.cpf;
    ELSIF
        dados_duplicados.login
    THEN
        RAISE EXCEPTION
            'Já existe um cliente com o login: %.',
            dados_duplicados.login;

    ELSIF
        configuracoes_v.idade_minima_clientes != 0
        AND
        CAST(data_nascimento AS DATE) <

    THEN 
        RAISE EXCEPTION
            'Idade do cliente abaixo do configurado: %', 
            configuracoes_v.idade_minima_clientes
    END IF;
END; 
$$;