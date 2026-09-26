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