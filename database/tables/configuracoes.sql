CREATE TABLE configuracoes (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    tempo_expiracao_reserva_processando integer NOT NULL DEFAULT 1,
    tempo_adicionado_renovacao_reserva_processando integer NOT NULL DEFAULT 1,
    maximo_renovacoes_por_reserva integer NOT NULL DEFAULT 2,

    tempo_expiracao_emprestimo integer NOT NULL DEFAULT 30,
    tempo_adicionado_renovacao_emprestimo integer NOT NULL DEFAULT 30,
    maximo_renovacoes_por_emprestimo integer NOT NULL DEFAULT 5,

    limitar_numero_emprestimos_cliente integer,
    limitar_numero_emprestimos_mesmo_livro integer,

    CONSTRAINT configuracoes_tempo_expiracao_reserva_processando_check
        CHECK (tempo_expiracao_reserva_processando > 0),

    CONSTRAINT configuracoes_tempo_adicionado_renovacao_reserva_processando_check
        CHECK (tempo_adicionado_renovacao_reserva_processando > 0),

    CONSTRAINT configuracoes_maximo_renovacoes_por_reserva_check
        CHECK (maximo_renovacoes_por_reserva >= 0),

    CONSTRAINT configuracoes_tempo_expiracao_emprestimo_check
        CHECK (tempo_expiracao_emprestimo > 0),

    CONSTRAINT configuracoes_tempo_adicionado_renovacao_emprestimo_check
        CHECK (tempo_adicionado_renovacao_emprestimo > 0),

    CONSTRAINT configuracoes_maximo_renovacoes_por_emprestimo_check
        CHECK (maximo_renovacoes_por_emprestimo >= 0),

    CONSTRAINT configuracoes_limitar_numero_emprestimos_cliente_check
        CHECK (limitar_numero_emprestimos_cliente >= 0),

    CONSTRAINT configuracoes_limitar_numero_emprestimos_mesmo_livro_check
        CHECK (limitar_numero_emprestimos_mesmo_livro >= 0)
);