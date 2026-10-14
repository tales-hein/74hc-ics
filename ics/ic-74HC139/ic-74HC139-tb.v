`timescale 1ns/1ps
module tb;
    reg a1, b1;
    reg a2, b2;                                          // Address select
    reg g1, g2;                                          // Strobe      active low
    wire y1_0, y1_1, y1_2, y1_3, y2_0, y2_1, y2_2, y2_3; // Outputs     active low
    reg [3:0] out1;
    reg [3:0] out2;
    integer i;
    integer errors;

    //Instanciar module sob teste
    ic_74HC139 dut(
        .a1(a1),
        .b1(b1),
        .a2(a2),
        .b2(b2),
        .g1(g1),
        .g2(g2),
        .y1_0(y1_0),
        .y1_1(y1_1),
        .y1_2(y1_2),
        .y1_3(y1_3),
        .y2_0(y2_0),
        .y2_1(y2_1),
        .y2_2(y2_2),
        .y2_3(y2_3)
    );

    // Dump das ondas para visualização
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);
    end
    
    initial begin
        errors = 0;
        for (i = 0; i < 64; i = i + 1) begin
            {b2, a2, b1, a1, g2, g1} = i;
            #10;
            out1 = {y1_0, y1_1, y1_2, y1_3};
            out2 = {y2_0, y2_1, y2_2, y2_3};
            $display("Testando com: t=%0t a1=%b b1=%b a2=%b b2=%b g1=%b g2=%b --- OUTPUT: y1_0=%b y1_1=%b y1_2=%b y1_3=%b y2_0=%b y2_1=%b y2_2=%b y2_3=%b",
                        $time, a1, b1, a2, b2, g1, g2, y1_0, y1_1, y1_2, y1_3, y2_0, y2_1, y2_2, y2_3);
            
            // Input enable HIGH, como é active low se for HIGH devemos ter todas as saídas como HIGH
            if (g1 == 1'b1) begin
                if (out1 !== 4'b1111) begin
                    $display("FALHOU: t=%0t a1=%b b1=%b g1=%b g2=%b y1_0=%b y1_1=%b y1_2=%b y1_3=%b expected: y1_0=1 y1_1=1 y1_2=1 y1_3=1",
                        $time, a1, b1, g1, g2, y1_0, y1_1, y1_2, y1_3);
                    errors = errors + 1;
                end
            end
            if (g2 == 1'b1) begin
                if (out2 !== 4'b1111) begin
                    $display("FALHOU: t=%0t a1=%b b1=%b g1=%b g2=%b y2_0=%b y2_1=%b y2_2=%b y2_3=%b expected: y2_0=1 y2_1=1 y2_2=1 y2_3=1",
                        $time, a1, b1, g1, g2, y2_0, y2_1, y2_2, y2_3);
                    errors = errors + 1;
                end
            end
            
            // g1 LOW, ou seja os outputs do lado 1 do ic devem ter algum resultado diferente de 1111
            if (g1 == 1'b0) begin
                // Para cada valor do par a1 e b1 devemos ter um bit zerado em out1
                case ({b1, a1})
                    2'b00: if (out1 !== 4'b0111) begin
                        $display("FALHOU: t=%0t a1=%b b1=%b g1=%b g2=%b y1_0=%b y1_1=%b y1_2=%b y1_3=%b expected: y1_0=0 y1_1=1 y1_2=1 y1_3=1",
                            $time, a1, b1, g1, g2, y1_0, y1_1, y1_2, y1_3);
                        errors = errors + 1;
                    end
                    2'b01: if (out1 !== 4'b1011) begin
                        $display("FALHOU: t=%0t a1=%b b1=%b g1=%b g2=%b y1_0=%b y1_1=%b y1_2=%b y1_3=%b expected: y1_0=1 y1_1=0 y1_2=1 y1_3=1",
                            $time, a1, b1, g1, g2, y1_0, y1_1, y1_2, y1_3);
                        errors = errors + 1;
                    end
                    2'b10: if (out1 !== 4'b1101) begin
                        $display("FALHOU: t=%0t a1=%b b1=%b g1=%b g2=%b y1_0=%b y1_1=%b y1_2=%b y1_3=%b expected: y1_0=1 y1_1=1 y1_2=0 y1_3=1",
                            $time, a1, b1, g1, g2, y1_0, y1_1, y1_2, y1_3);
                        errors = errors + 1;
                    end
                    2'b11: if (out1 !== 4'b1110) begin
                        $display("FALHOU: t=%0t a1=%b b1=%b g1=%b g2=%b y1_0=%b y1_1=%b y1_2=%b y1_3=%b expected: y1_0=1 y1_1=1 y1_2=1 y1_3=0",
                            $time, a1, b1, g1, g2, y1_0, y1_1, y1_2, y1_3);
                        errors = errors + 1;
                    end
                endcase
            end 

            // g2 LOW, ou seja os outputs do lado 1 do ic devem ter algum resultado diferente de 1111
            if (g2 == 1'b0) begin
                // Para cada valor do par a2 e b1 devemos ter um bit zerado em out2
                case ({b2, a2})
                    2'b00: if (out2 !== 4'b0111) begin
                        $display("FALHOU: t=%0t a2=%b b2=%b g1=%b g2=%b y2_0=%b y2_1=%b y2_2=%b y2_3=%b expected: y2_0=0 y2_1=1 y2_2=1 y2_3=1",
                            $time, a2, b2, g1, g2, y2_0, y2_1, y2_2, y2_3);
                        errors = errors + 1;
                    end
                    2'b01: if (out2 !== 4'b1011) begin
                        $display("FALHOU: t=%0t a2=%b b2=%b g1=%b g2=%b y2_0=%b y2_1=%b y2_2=%b y2_3=%b expected: y2_0=1 y2_1=0 y2_2=1 y2_3=1",
                            $time, a2, b2, g1, g2, y2_0, y2_1, y2_2, y2_3);
                        errors = errors + 1;
                    end
                    2'b10: if (out2 !== 4'b1101) begin
                        $display("FALHOU: t=%0t a2=%b b2=%b g1=%b g2=%b y2_0=%b y2_1=%b y2_2=%b y2_3=%b expected: y2_0=1 y2_1=1 y2_2=0 y2_3=1",
                            $time, a2, b2, g1, g2, y2_0, y2_1, y2_2, y2_3);
                        errors = errors + 1;
                    end
                    2'b11: if (out2 !== 4'b1110) begin
                        $display("FALHOU: t=%0t a2=%b b2=%b g1=%b g2=%b y2_0=%b y2_1=%b y2_2=%b y2_3=%b expected: y2_0=1 y2_1=1 y2_2=1 y2_3=0",
                            $time, a2, b2, g1, g2, y2_0, y2_1, y2_2, y2_3);
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