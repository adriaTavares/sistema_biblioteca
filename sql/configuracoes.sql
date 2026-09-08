-- Configurações do sistema
/*
 tempo_expiracao_reserva, serve para dizer o tempo padrão de expiração que cada reserva recebe após entrar em um estado de processamento

tempo_adicionado_renovacao_reserva, serve aumentar o tempo de expiração da reserva

 maximo_reservas_mesmo_livro, serve para dizer o máximo de exemplares do mesmo que o cliente pode ter

 maximo_renovacoes_por_reserva, serve para dar um limite de renovações por reserva

*/

/*

*/

CREATE TABLE configuracoes (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tempo_expiracao_reserva integer NOT NULL DEFAULT 1,
    tempo_adicionado_renovacao_reserva integer NOT NULL DEFAULT 1,
    maximo_reservas_mesmo_livro integer NOT NULL DEFAULT 1,
    maximo_renovacoes_por_reserva integer DEFAULT 2

    tempo_expiracao_emprestimo integer NOT NULL DEFAULT 30,
    tempo_adicionado_renovacao_emprestimo integer NOT NULL DEFAULT 30,
    maximo_renovacoes_por_emprestimo integer DEFAULT 5
    valor_multa_por_dia numeric(10, 2) NOT NULL DEFAULT 1.00,


    CONSTRAINT configuracoes_tempo_expiracao_reserva_check
        CHECK (tempo_expiracao_reserva > 0),

    CONSTRAINT configuracoes_tempo_adicionado_renovacao_reserva_check
        CHECK (tempo_adicionado_renovacao_reserva > 0),

    CONSTRAINT configuracoes_maximo_reservas_mesmo_livro_check
        CHECK(maximo_reservas_mesmo_livro >= 1),

    CONSTRAINT configuracoes_maximo_renovacoes_por_reserva_check
        CHECK(maximo_renovacoes_por_reserva >= 0)



    CONSTRAINT configuracoes_tempo_expiracao_emprestimo_check
        CHECK (tempo_expiracao_emprestimo > 0),
    
    
    CONSTRAINT configuracoes_tempo_adicionado_renovacao_emprestimo_check
        CHECK (tempo_renovacao_reserva > 0),
    
    CONSTRAINT configuracoes_maximo_renovacoes_por_emprestimo_check
        CHECK (maximo_renovacoes_por_emprestimo >= 0),
    
    CONSTRAINT configuracoes_valor_multa_por_dia_check
        CHECK (valor_multa_por_dia >= 0)
);

INSERT INTO configuracoes DEFAULT VALUES;


CREATE FUNCTION verificacao_contato_function()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
    DECLARE 
        nome_tabela text;
    BEGIN

        nome_tabela := TG_TABLE_NAME::text;

        IF (
            NULLIF(btrim(NEW.email), '') IS NOT NULL
            OR 
            NULLIF(btrim(NEW.telefone), '') IS NOT NULL
        )
        THEN
            CASE
                WHEN btrim(NEW.email) = ''
                    THEN NEW.email := NULL;
                WHEN btrim(NEW.telefone) = ''
                    THEN NEW.telefone := NULL;
            END CASE;
            RETURN NEW;
        ELSE 
            RAISE EXCEPTION '% deve ter pelo menos um meio de contato contato (telefone ou email).', initcap(tipo_tabela);
        END IF;
    END;
$$;

