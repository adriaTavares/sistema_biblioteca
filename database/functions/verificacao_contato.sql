
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
