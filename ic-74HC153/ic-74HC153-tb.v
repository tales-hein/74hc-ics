
`timescale 1ns/1ps
module tb;
    reg a, b;                   // Line select
    reg g1, g2;                 // Input enable active low
    reg c1_0, c1_1, c1_2, c1_3; // Data in
    reg c2_0, c2_1, c2_2, c2_3; // Data in
    wire y1, y2;                // Output    
    integer i;
    integer errors;

    //Instanciar module sob teste
    ic_74HC153 dut(
        .a(a),
        .b(b),
        .g1(g1),
        .g2(g2),
        .c1_0(c1_0),
        .c1_1(c1_1),
        .c1_2(c1_2),
        .c1_3(c1_3),
        .c2_0(c2_0),
        .c2_1(c2_1),
        .c2_2(c2_2),
        .c2_3(c2_3),
        .y1(y1),
        .y2(y2)
    );

    // Dump das ondas para visualização
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);
    end
    
    initial begin
        errors = 0;
        for (i = 0; i < 4096; i = i + 1) begin
            {b, a, g1, g2, c1_0, c1_1, c1_2, c1_3, c2_0, c2_1, c2_2, c2_3} = i;
            #10;

            if (g1 == 1'b1 && y1 !== 1'b0) begin
                $display("FALHOU l.43: t=%0t b=%b a=%b g1=%b g2=%b c1_0=%b c1_1=%b c1_2=%b c1_3=%b c2_0=%b c2_1=%b c2_2=%b c2_3=%b --- OUTPUT: y1=%b y2=%b",
                    $time, b, a, g1, g2, c1_0, c1_1, c1_2, c1_3, c2_0, c2_1, c2_2, c2_3, y1, y2);
                errors = errors + 1;
            end
            if (g2 == 1'b1 && y2 !== 1'b0) begin
                $display("FALHOU l.48: t=%0t b=%b a=%b g1=%b g2=%b c1_0=%b c1_1=%b c1_2=%b c1_3=%b c2_0=%b c2_1=%b c2_2=%b c2_3=%b --- OUTPUT: y1=%b y2=%b",
                    $time, b, a, g1, g2, c1_0, c1_1, c1_2, c1_3, c2_0, c2_1, c2_2, c2_3, y1, y2);
                errors = errors + 1;
            end
            
            if (g1 == 1'b0) begin
                case ({b, a})
                    2'b00: if (y1 !== c1_0) begin
                        $display("FALHOU l.56: t=%0t b=%b a=%b g1=%b g2=%b c1_0=%b c1_1=%b c1_2=%b c1_3=%b c2_0=%b c2_1=%b c2_2=%b c2_3=%b --- OUTPUT: y1=%b y2=%b",
                            $time, b, a, g1, g2, c1_0, c1_1, c1_2, c1_3, c2_0, c2_1, c2_2, c2_3, y1, y2);
                        errors = errors + 1;
                    end
                    2'b01: if (y1 !== c1_1) begin
                        $display("FALHOU l.61: t=%0t b=%b a=%b g1=%b g2=%b c1_0=%b c1_1=%b c1_2=%b c1_3=%b c2_0=%b c2_1=%b c2_2=%b c2_3=%b --- OUTPUT: y1=%b y2=%b",
                            $time, b, a, g1, g2, c1_0, c1_1, c1_2, c1_3, c2_0, c2_1, c2_2, c2_3, y1, y2);
                        errors = errors + 1;
                    end
                    2'b10: if (y1 !== c1_2) begin
                        $display("FALHOU l.66: t=%0t b=%b a=%b g1=%b g2=%b c1_0=%b c1_1=%b c1_2=%b c1_3=%b c2_0=%b c2_1=%b c2_2=%b c2_3=%b --- OUTPUT: y1=%b y2=%b",
                            $time, b, a, g1, g2, c1_0, c1_1, c1_2, c1_3, c2_0, c2_1, c2_2, c2_3, y1, y2);
                        errors = errors + 1;
                    end
                    2'b11: if (y1 !== c1_3) begin
                        $display("FALHOU l.71: t=%0t b=%b a=%b g1=%b g2=%b c1_0=%b c1_1=%b c1_2=%b c1_3=%b c2_0=%b c2_1=%b c2_2=%b c2_3=%b --- OUTPUT: y1=%b y2=%b",
                            $time, b, a, g1, g2, c1_0, c1_1, c1_2, c1_3, c2_0, c2_1, c2_2, c2_3, y1, y2);
                        errors = errors + 1;
                    end
                endcase
            end 

            if (g2 == 1'b0) begin
                case ({b, a})
                    2'b00: if (y2 !== c2_0) begin
                        $display("FALHOU l.81: t=%0t b=%b a=%b g1=%b g2=%b c1_0=%b c1_1=%b c1_2=%b c1_3=%b c2_0=%b c2_1=%b c2_2=%b c2_3=%b --- OUTPUT: y1=%b y2=%b",
                            $time, b, a, g1, g2, c1_0, c1_1, c1_2, c1_3, c2_0, c2_1, c2_2, c2_3, y1, y2);
                        errors = errors + 1;
                    end
                    2'b01: if (y2 !== c2_1) begin
                        $display("FALHOU l.86: t=%0t b=%b a=%b g1=%b g2=%b c1_0=%b c1_1=%b c1_2=%b c1_3=%b c2_0=%b c2_1=%b c2_2=%b c2_3=%b --- OUTPUT: y1=%b y2=%b",
                            $time, b, a, g1, g2, c1_0, c1_1, c1_2, c1_3, c2_0, c2_1, c2_2, c2_3, y1, y2);
                        errors = errors + 1;
                    end
                    2'b10: if (y2 !== c2_2) begin
                        $display("FALHOU l.91: t=%0t b=%b a=%b g1=%b g2=%b c1_0=%b c1_1=%b c1_2=%b c1_3=%b c2_0=%b c2_1=%b c2_2=%b c2_3=%b --- OUTPUT: y1=%b y2=%b",
                            $time, b, a, g1, g2, c1_0, c1_1, c1_2, c1_3, c2_0, c2_1, c2_2, c2_3, y1, y2);
                        errors = errors + 1;
                    end
                    2'b11: if (y2 !== c2_3) begin
                        $display("FALHOU l.96: t=%0t b=%b a=%b g1=%b g2=%b c1_0=%b c1_1=%b c1_2=%b c1_3=%b c2_0=%b c2_1=%b c2_2=%b c2_3=%b --- OUTPUT: y1=%b y2=%b",
                            $time, b, a, g1, g2, c1_0, c1_1, c1_2, c1_3, c2_0, c2_1, c2_2, c2_3, y1, y2);
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