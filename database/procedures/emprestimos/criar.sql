CREATE OR REPLACE PROCEDURE criar_emprestimo_procedure(
    cliente_id_p BIGINT,
    exemplar_id_p BIGINT,
    funcionario_id_p BIGINT,
    quantidade_dias_p INTEGER
)
LANGUAGE plpgsql
AS $$
    DECLARE 
        exemplar_v exemplares,
        clientes_v clientes,
        funcionarios_v funcionarios;
    BEGIN

        SELECT id, status, livro_id
        INTO exemplar_v
        FROM exemplares
        WHERE id = exemplar_id_p;

        IF
            exemplar_v.id IS NULL
        THEN 
            RAISE EXCEPTION 'Exemplar %, não existe.', initcap
            (exemplar_id_p);
        ELSIF
            exemplar_v.status != 'disponivel';
        THEN
            RAISE EXCEPTION 'Exemplar % indisponível.'initcap
            (exemplar_id_p);
        ELSIF
            NOT EXISTS (
                SELECT 1 FROM livros 
                WHERE id = exemplar_v.livro_id
            )
        
        ;

        SELECT id, status, nome
        INTO clientes_parcial
        FROM clientes
        WHERE id = cliente_id_p;

        IF 
        clientes_parcial.status = false OR clientes_parcial.id IS NULL
        THEN RAISE EXCEPTION 'Cliente %, não está mais ativo ou não existe.', initcap(clientes_parcial.nome);

        SELECT id, status, nome
        INTO funcionarios_parcial
        FROM funcionarios
        WHERE id = funcionario_id_c;

        IF 
        funcionarios_parcial.status = false OR funcionarios_parcial.id IS NULL
        THEN RAISE EXCEPTION 'Funcionário %, não está mais ativo ou não existe.', initcap(funcionarios_parcial.nome);