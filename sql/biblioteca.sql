







CREATE UNIQUE INDEX emprestimos_exemplares_ativo_unique
    ON emprestimos (exemplar_id)
    WHERE status = 'ativo';





-- ============================================================
-- ATENDER RESERVAS
-- ============================================================
-- Verifica reservas ativas, encontra exemplares disponíveis
-- e associa os exemplares às reservas respeitando a ordem
-- de criação.
--
-- A transação fica explicitamente fora de qualquer função.
-- ============================================================




-- ============================================================
-- EXPIRAR RESERVAS
-- ============================================================

BEGIN;

    WITH reservas_expiradas AS (
        SELECT
            id,
            exemplar_id
        FROM reservas AS rs
        WHERE status = 'processando'
        AND dataExpiracao < current_date
        FOR UPDATE
    ),

    reservas_atualizadas AS (
        UPDATE reservas
        SET
            status = 'expirada',
            dataExpiracaoFinal = now()
        FROM reservas_expiradas
        WHERE reservas.id = reservas_expiradas.id
        RETURNING reservas.*
    )

    UPDATE exemplares AS e
    SET status = 'disponivel'
    FROM reservas_atualizadas AS ra
    WHERE e.id = ra.exemplar_id;

COMMIT;


-- ============================================================
-- CANCELAR RESERVA
-- ============================================================
--
-- $1 = id da reserva
-- $2 = id do funcionário
--
-- A operação só permite cancelar reservas que estejam:
--
--     ativa
--     processando
--
-- Se nenhuma linha for retornada pelo UPDATE, a aplicação
-- deve tratar a operação como inválida.
-- ============================================================




-- ============================================================
-- FINALIZAR RESERVA
-- ============================================================
--
-- $1 = id da reserva
-- $2 = id do funcionário
--
-- A reserva precisa estar em estado "processando".
--
-- A operação:
--
-- 1. bloqueia a reserva;
-- 2. finaliza a reserva;
-- 3. cria o empréstimo;
-- 4. altera o exemplar para emprestado.
-- ============================================================

CREATE OR REPLACE FUNCTION finalizar_reserva(
    reserva_id_p bigint,
    funcionario_id_p integer
)
RETURNS void
LANGUAGE plpgsql
AS $$
    DECLARE
        reserva_valida RECORD;
BEGIN;


    SELECT
        id,
        cliente_id,
        exemplar_id
    FROM reservas
    INTO reserva_valida
    WHERE id = reserva_id_p
    FOR UPDATE;


        IF reserva_valida IS NULL 
            THEN
                RAISE EXCEPTION 'Reserva não encontrada.';
        ELSIF reserva_valida.status <> 'processando' 
            THEN
                RAISE EXCEPTION 'Reserva não pode ser finalizada.';
        END IF;

    WITH reservas_finalizadas AS (
        UPDATE reservas AS r
        SET
            status = 'finalizada',
            funcionario_finalizacao_id = funcionario_id_p,
            data_finalizacao = now()
        FROM reserva_valida AS rv
        WHERE r.id = rv.id
        RETURNING r.*
    ),

    criacao_emprestimo AS (
        INSERT INTO emprestimos (
            cliente_id,
            funcionario_criacao_id,
            exemplar_id,
            data_prevista_devolucao
        )
        SELECT
            rf.cliente_id,
            rf.funcionario_finalizacao_id,
            rf.exemplar_id,
            current_date + conf.tempo_expiracao_emprestimo
        FROM reservas_finalizadas AS rf
        CROSS JOIN configuracoes AS conf
        RETURNING exemplar_id
    )
    UPDATE exemplares AS e
    SET status = 'emprestado'
    FROM criacao_emprestimo AS ce
    WHERE e.id = ce.exemplar_id;
    END;
$$; 





CREATE FUNCTION renovar_reserva_function(
    reserva_id_p BIGINT,
    funcionario_id_p BIGINT,
    quantidade_dias INTEGER := NULL
)
RETURNS void
LANGUAGE plpgsql
AS $$
    DECLARE
        conf RECORD;
    BEGIN
        SELECT * FROM configuracoes INTO conf;
        UPDATE reservas
        SET
            dataExpiracao = current_date + COALESCE(quantidade_dias, conf.tempo_renovacao_reserva),
            quantidadeRenovacoes = quantidadeRenovacoes + 1
        WHERE id = reserva_id_p
        AND status IN ('ativa', 'processando')
        AND funcionario_finalizacao_id IS NULL
        AND funcionario_cancelamento_id IS NULL
        AND dataExpiracaoFinal IS NULL
        AND dataCancelamento IS NULL;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Reserva não encontrada ou não pode ser renovada.';
        END IF;
    END;
$$;





CREATE FUNCTION renovar_emprestimo_function(
    emprestimo_id_p BIGINT,
    funcionario_id_p BIGINT,
    quantidade_dias INTEGER := NULL
)
RETURNS void
LANGUAGE plpgsql
AS $$
    DECLARE
        conf RECORD;
    BEGIN
        SELECT * FROM configuracoes INTO conf;
        UPDATE emprestimos
        SET
            dataPrevistaDevolucao = dataPrevistaDevolucao + COALESCE(quantidade_dias, conf.tempo_renovacao_emprestimo),
            quantidadeRenovacoes = quantidadeRenovacoes + 1
        WHERE id = emprestimo_id_p
        AND status = 'ativo'
        AND funcionario_fim_id IS NULL;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Empréstimo não encontrado ou não pode ser renovado.';
        END IF;
    END;
$$;





CREATE FUNCTION finalizar_emprestimo_function(
    emprestimo_id_p BIGINT,
    funcionario_id_p BIGINT,
    status_exemplar_p status_exemplar_enum := 'aguardando_resposta'
)
RETURNS void
LANGUAGE plpgsql
AS $$
    BEGIN
        UPDATE emprestimos
        SET 
            status = 'finalizado',
            dataFim = now(),
            funcionario_fim_id = funcionario_id_p
        WHERE id = emprestimo_id_p
        AND status = 'ativo'
        AND funcionario_fim_id IS NULL;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Empréstimo não encontrado ou não pode ser finalizado.';
        END IF;

        UPDATE exemplares AS e
        SET status = status_exemplar_p
        FROM emprestimos AS emp 
        WHERE emp.id = emprestimo_id_p
        AND e.id = emp.exemplar_id;
    END;
$$;