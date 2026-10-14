`timescale 1ns/1ps
module tb;
    reg e_n;          // Enable (active low)
    reg [7:0] p;      // Palavra P
    reg [7:0] q;      // Palavra Q
    wire eq_n;        // Saida P=Q (active low)
    integer i;
    integer errors;

    //Instanciar module sob teste
    ic_74HC688 dut(
        .e_n(e_n),
        .p(p),
        .q(q),
        .eq_n(eq_n)
    );

    // Dump das ondas para visualização
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);
    end

    initial begin
        errors = 0;
        for (i = 0; i < 131072; i = i + 1) begin
            {e_n, p, q} = i;
            #10;
            case (e_n)
                1'b0: if (eq_n !== ((p == q) ? 1'b0 : 1'b1)) begin
                    $display("Comparacao FALHOU: t=%0t e_n=%b p=%b q=%b eq_n=%b expected=%b",
                        $time, e_n, p, q, eq_n, (p == q) ? 1'b0 : 1'b1);
                    errors = errors + 1;
                end
                default: if (eq_n !== 1'b1) begin
                    $display("Enable FALHOU: t=%0t e_n=%b p=%b q=%b eq_n=%b expected=%b",
                        $time, e_n, p, q, eq_n, 1'b1);
                    errors = errors + 1;
                end
            endcase
        end
        if (errors == 0)
            $display("TESTES PASSARAM");
        else
            $display("%0d TESTE(S) FALHOU(FALHARAM)", errors);

        $finish;
    end
endmodule
