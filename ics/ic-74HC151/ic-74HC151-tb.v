
`timescale 1ns/1ps
module tb;
    reg a, b, c;   // Input select
    reg g;         // Input enable active low
    reg [7:0] d;   // Data inputs
    wire y, w;     // Outputs w é inversao do data input selecionado
    integer i;
    integer errors;

    //Instanciar module sob teste
    ic_74HC151 dut(
        .a(a),
        .b(b),
        .c(c),
        .g(g),
        .d(d),
        .y(y),
        .w(w)
    );

    // Dump das ondas para visualização
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);
    end

    initial begin
        errors = 0;
        for (i = 0; i < 4096; i = i + 1) begin
            {a, b, c, g, d} = i;
            #10;

            if (g == 1'b1 && ({y, w} !== 2'b01)) begin
                $display("FALHOU l.35: t=%0t a=%b b=%b c=%b g=%b d[0]=%b d[1]=%b d[2]=%b d[3]=%b d[4]=%b d[5]=%b d[6]=%b d[7]=%b --- OUTPUT: y=%b w=%b",
                    $time, a, b, c, g, d[0], d[1], d[2], d[3], d[4], d[5], d[6], d[7], y, w);
                errors = errors + 1;
            end

            if (g == 1'b0) begin
                case ({c, b, a})
                    3'b000: if (y !== d[0] || w !== ~d[0]) begin
                        $display("FALHOU l.43: t=%0t a=%b b=%b c=%b g=%b d[0]=%b d[1]=%b d[2]=%b d[3]=%b d[4]=%b d[5]=%b d[6]=%b d[7]=%b --- OUTPUT: y=%b w=%b",
                            $time, a, b, c, g, d[0], d[1], d[2], d[3], d[4], d[5], d[6], d[7], y, w);
                        errors = errors + 1;
                    end
                    3'b001: if (y !== d[1] || w !== ~d[1]) begin
                        $display("FALHOU l.48: t=%0t a=%b b=%b c=%b g=%b d[0]=%b d[1]=%b d[2]=%b d[3]=%b d[4]=%b d[5]=%b d[6]=%b d[7]=%b --- OUTPUT: y=%b w=%b",
                            $time, a, b, c, g, d[0], d[1], d[2], d[3], d[4], d[5], d[6], d[7], y, w);
                        errors = errors + 1;
                    end
                    3'b010: if (y !== d[2] || w !== ~d[2]) begin
                        $display("FALHOU l.53: t=%0t a=%b b=%b c=%b g=%b d[0]=%b d[1]=%b d[2]=%b d[3]=%b d[4]=%b d[5]=%b d[6]=%b d[7]=%b --- OUTPUT: y=%b w=%b",
                            $time, a, b, c, g, d[0], d[1], d[2], d[3], d[4], d[5], d[6], d[7], y, w);
                        errors = errors + 1;
                    end
                    3'b011: if (y !== d[3] || w !== ~d[3]) begin
                        $display("FALHOU l.58: t=%0t a=%b b=%b c=%b g=%b d[0]=%b d[1]=%b d[2]=%b d[3]=%b d[4]=%b d[5]=%b d[6]=%b d[7]=%b --- OUTPUT: y=%b w=%b",
                            $time, a, b, c, g, d[0], d[1], d[2], d[3], d[4], d[5], d[6], d[7], y, w);
                        errors = errors + 1;
                    end
                    3'b100: if (y !== d[4] || w !== ~d[4]) begin
                        $display("FALHOU l.63: t=%0t a=%b b=%b c=%b g=%b d[0]=%b d[1]=%b d[2]=%b d[3]=%b d[4]=%b d[5]=%b d[6]=%b d[7]=%b --- OUTPUT: y=%b w=%b",
                            $time, a, b, c, g, d[0], d[1], d[2], d[3], d[4], d[5], d[6], d[7], y, w);
                        errors = errors + 1;
                    end
                    3'b101: if (y !== d[5] || w !== ~d[5]) begin
                        $display("FALHOU l.68: t=%0t a=%b b=%b c=%b g=%b d[0]=%b d[1]=%b d[2]=%b d[3]=%b d[4]=%b d[5]=%b d[6]=%b d[7]=%b --- OUTPUT: y=%b w=%b",
                            $time, a, b, c, g, d[0], d[1], d[2], d[3], d[4], d[5], d[6], d[7], y, w);
                        errors = errors + 1;
                    end
                    3'b110: if (y !== d[6] || w !== ~d[6]) begin
                        $display("FALHOU l.73: t=%0t a=%b b=%b c=%b g=%b d[0]=%b d[1]=%b d[2]=%b d[3]=%b d[4]=%b d[5]=%b d[6]=%b d[7]=%b --- OUTPUT: y=%b w=%b",
                            $time, a, b, c, g, d[0], d[1], d[2], d[3], d[4], d[5], d[6], d[7], y, w);
                        errors = errors + 1;
                    end
                    3'b111: if (y !== d[7] || w !== ~d[7]) begin
                        $display("FALHOU l.78: t=%0t a=%b b=%b c=%b g=%b d[0]=%b d[1]=%b d[2]=%b d[3]=%b d[4]=%b d[5]=%b d[6]=%b d[7]=%b --- OUTPUT: y=%b w=%b",
                            $time, a, b, c, g, d[0], d[1], d[2], d[3], d[4], d[5], d[6], d[7], y, w);
                        errors = errors + 1;
                    end
                endcase
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