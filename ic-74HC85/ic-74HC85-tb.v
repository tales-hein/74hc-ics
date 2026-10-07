`timescale 1ns/1ps
module tb;
    reg [3:0] a;              // Palavra A (a[3] MSB)
    reg [3:0] b;              // Palavra B (b[3] MSB)
    reg i_gt, i_eq, i_lt;     // Entradas de cascata IA>B, IA=B, IA<B
    wire q_gt, q_eq, q_lt;    // Saidas QA>B, QA=B, QA<B
    reg [2:0] expected;       // {q_gt, q_eq, q_lt} esperado
    integer i;
    integer errors;

    //Instanciar module sob teste
    ic_74HC85 dut(
        .a(a),
        .b(b),
        .i_gt(i_gt),
        .i_eq(i_eq),
        .i_lt(i_lt),
        .q_gt(q_gt),
        .q_eq(q_eq),
        .q_lt(q_lt)
    );

    // Dump das ondas para visualização
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);
    end

    initial begin
        errors = 0;
        // Todas as combinações de a, b e entradas de cascata
        for (i = 0; i < 2048; i = i + 1) begin
            {i_gt, i_eq, i_lt, a, b} = i;
            #10;
            if (a > b)
                expected = 3'b100;
            else if (a < b)
                expected = 3'b001;
            else begin
                // a = b: resultado vem das entradas de cascata (ultimas linhas da tabela)
                case ({i_gt, i_eq, i_lt})
                    3'b100: expected = 3'b100;
                    3'b001: expected = 3'b001;
                    3'b101: expected = 3'b000;
                    3'b000: expected = 3'b101;
                    default: expected = 3'b010; // i_eq H prevalece
                endcase
            end

            if ({q_gt, q_eq, q_lt} !== expected) begin
                $display("Comparacao FALHOU: t=%0t a=%b b=%b i_gt=%b i_eq=%b i_lt=%b --- OUTPUT: q_gt=%b q_eq=%b q_lt=%b expected q_gt=%b q_eq=%b q_lt=%b",
                    $time, a, b, i_gt, i_eq, i_lt, q_gt, q_eq, q_lt, expected[2], expected[1], expected[0]);
                errors = errors + 1;
            end
        end

        // Resultado
        if (errors == 0)
            $display("TESTES PASSARAM");
        else
            $display("%0d TESTE(S) FALHOU(FALHARAM)", errors);

        $finish;
    end
endmodule
