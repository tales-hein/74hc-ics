
`timescale 1ns/1ps
module tb;
    reg ab;       // a/b select (active low seleciona a)
    reg g;        // Input enable
    reg [3:0] a;  // Data input
    reg [3:0] b;  // Data input 
    wire [3:0] y; // Outputs invertidos
    integer i;
    integer errors;

    //Instanciar module sob teste
    ic_74HC258 dut(
        .ab(ab),
        .g(g),
        .a(a),
        .b(b),
        .y(y)
    );

    // Dump das ondas para visualização
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);
    end

    initial begin
        errors = 0;
        for (i = 0; i < 1024; i = i + 1) begin
            {ab, g, a, b} = i;
            #10;

            case (g)
                1'b1: if (y !== 4'bzzzz) begin
                    $display("FALHOU l.35: t=%0t ab=%b g=%b a[0]=%b a[1]=%b a[2]=%b a[3]=%b b[0]=%b b[1]=%b b[2]=%b b[3]=%b --- OUTPUT: y[0]=%b y[1]=%b y[2]=%b y[3]=%b",
                        $time, ab, g, a[0], a[1], a[2], a[3], b[0], b[1], b[2], b[3], y[0], y[1], y[2], y[3]);
                    errors = errors + 1;
                end
                1'b0: if (ab ? (y !== ~b) : (y !== ~a)) begin
                    $display("FALHOU l.40: t=%0t ab=%b g=%b a[0]=%b a[1]=%b a[2]=%b a[3]=%b b[0]=%b b[1]=%b b[2]=%b b[3]=%b --- OUTPUT: y[0]=%b y[1]=%b y[2]=%b y[3]=%b",
                        $time, ab, g, a[0], a[1], a[2], a[3], b[0], b[1], b[2], b[3], y[0], y[1], y[2], y[3]);
                    errors = errors + 1;
                end
            endcase
        end

        // Resultado
        if (errors == 0)
            $display("TESTES PASSARAM");
        else
            $display("%0d TESTE(S) FALHOU(FALHARAM)", errors);

        $finish;
    end
endmodule