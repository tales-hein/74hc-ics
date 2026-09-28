`timescale 1ns/1ps
module tb;
    reg a0, a1, a2;                      // Address select
    reg g0, g1, g2;                      // Strobe       g0,g1 active low
    wire y0, y1, y2, y3, y4, y5, y6, y7; // Outputs      active low
    reg addres_enable;
    reg [2:0] address_code;
    integer i;
    integer j;
    integer errors;

    //Instanciar module sob teste
    ic_74HC138 dut(
        .a0(a0),
        .a1(a1),
        .a2(a2),
        .g0(g0),
        .g1(g1),
        .g2(g2),
        .y0(y0),
        .y1(y1),
        .y2(y2),
        .y3(y3),
        .y4(y4),
        .y5(y5),
        .y6(y6),
        .y7(y7)
    );

    // Dump das ondas para visualização
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);
    end
    
    initial begin
        errors = 0;

        for (i = 0; i < 8; i = i + 1) begin
            $display("Alterando combinação de input de teste");
            
            {a2, a1, a0} = i;
            #10;
            address_code = {a2, a1, a0};

            for (j = 0; j < 8; j = j + 1) begin
                $display("Alterando combinação de input enable de teste");
            
                {g0, g1, g2} = j;
                #10;
                addres_enable = (~g0 & ~g1 & g2);

                if (addres_enable) begin
                    case (address_code)
                        3'b000: if (y0 == 0 & y1 == 1 & y2 == 1 & y3 == 1 & y4 == 1 & y5 == 1 & y6 == 1 & y7 == 1) begin
                                $display("Output y0 PASSOU: t=%0t a0=%b a1=%b a2=%b g0=%b g1=%b g2=%b y0=%b y1=%b y2=%b y3=%b y4=%b y5=%b y6=%b y7=%b",
                                    $time, a0, a1, a2, g0, g1, g2, y0, y1, y2, y3, y4, y5, y6, y7);
                            end else begin
                                $display("FALHOU: t=%0t a0=%b a1=%b a2=%b g0=%b g1=%b g2=%b y0=%b y1=%b y2=%b y3=%b y4=%b y5=%b y6=%b y7=%b expected: y0=0 y1=1 y2=1 y3=1 y4=1 y5=1 y6=1 y7=1",
                                    $time, a0, a1, a2, g0, g1, g2, y0, y1, y2, y3, y4, y5, y6, y7);
                                errors = errors + 1;
                            end
                        3'b001: if (y1 == 0 & y0 == 1 & y2 == 1 & y3 == 1 & y4 == 1 & y5 == 1 & y6 == 1 & y7 == 1) begin
                                $display("Output y1 PASSOU: t=%0t a0=%b a1=%b a2=%b g0=%b g1=%b g2=%b y0=%b y1=%b y2=%b y3=%b y4=%b y5=%b y6=%b y7=%b",
                                    $time, a0, a1, a2, g0, g1, g2, y0, y1, y2, y3, y4, y5, y6, y7);
                            end else begin
                                $display("FALHOU: t=%0t a0=%b a1=%b a2=%b g0=%b g1=%b g2=%b y0=%b y1=%b y2=%b y3=%b y4=%b y5=%b y6=%b y7=%b expected: y0=1 y1=0 y2=1 y3=1 y4=1 y5=1 y6=1 y7=1",
                                    $time, a0, a1, a2, g0, g1, g2, y0, y1, y2, y3, y4, y5, y6, y7);
                                errors = errors + 1;
                            end
                        3'b010: if (y2 == 0 & y1 == 1 & y0 == 1 & y3 == 1 & y4 == 1 & y5 == 1 & y6 == 1 & y7 == 1) begin
                                $display("Output y0 PASSOU: t=%0t a0=%b a1=%b a2=%b g0=%b g1=%b g2=%b y0=%b y1=%b y2=%b y3=%b y4=%b y5=%b y6=%b y7=%b",
                                    $time, a0, a1, a2, g0, g1, g2, y0, y1, y2, y3, y4, y5, y6, y7);
                            end else begin
                                $display("FALHOU: t=%0t a0=%b a1=%b a2=%b g0=%b g1=%b g2=%b y0=%b y1=%b y2=%b y3=%b y4=%b y5=%b y6=%b y7=%b expected: y0=1 y1=1 y2=0 y3=1 y4=1 y5=1 y6=1 y7=1",
                                    $time, a0, a1, a2, g0, g1, g2, y0, y1, y2, y3, y4, y5, y6, y7);
                                errors = errors + 1;
                            end
                        3'b011: 
                            if (y3 == 0 & y1 == 1 & y2 == 1 & y0 == 1 & y4 == 1 & y5 == 1 & y6 == 1 & y7 == 1) begin
                                $display("Output y0 PASSOU: t=%0t a0=%b a1=%b a2=%b g0=%b g1=%b g2=%b y0=%b y1=%b y2=%b y3=%b y4=%b y5=%b y6=%b y7=%b",
                                    $time, a0, a1, a2, g0, g1, g2, y0, y1, y2, y3, y4, y5, y6, y7);
                            end else begin
                                $display("FALHOU: t=%0t a0=%b a1=%b a2=%b g0=%b g1=%b g2=%b y0=%b y1=%b y2=%b y3=%b y4=%b y5=%b y6=%b y7=%b expected: y0=1 y1=1 y2=1 y3=0 y4=1 y5=1 y6=1 y7=1",
                                    $time, a0, a1, a2, g0, g1, g2, y0, y1, y2, y3, y4, y5, y6, y7);
                                errors = errors + 1;
                            end
                        3'b100: 
                            if (y4 == 0 & y1 == 1 & y2 == 1 & y3 == 1 & y0 == 1 & y5 == 1 & y6 == 1 & y7 == 1) begin
                                $display("Output y0 PASSOU: t=%0t a0=%b a1=%b a2=%b g0=%b g1=%b g2=%b y0=%b y1=%b y2=%b y3=%b y4=%b y5=%b y6=%b y7=%b",
                                    $time, a0, a1, a2, g0, g1, g2, y0, y1, y2, y3, y4, y5, y6, y7);
                            end else begin
                                $display("FALHOU: t=%0t a0=%b a1=%b a2=%b g0=%b g1=%b g2=%b y0=%b y1=%b y2=%b y3=%b y4=%b y5=%b y6=%b y7=%b expected: y0=1 y1=1 y2=1 y3=1 y4=0 y5=1 y6=1 y7=1",
                                    $time, a0, a1, a2, g0, g1, g2, y0, y1, y2, y3, y4, y5, y6, y7);
                                errors = errors + 1;
                            end
                        3'b101: 
                            if (y5 == 0 & y1 == 1 & y2 == 1 & y3 == 1 & y4 == 1 & y0 == 1 & y6 == 1 & y7 == 1) begin
                                $display("Output y0 PASSOU: t=%0t a0=%b a1=%b a2=%b g0=%b g1=%b g2=%b y0=%b y1=%b y2=%b y3=%b y4=%b y5=%b y6=%b y7=%b",
                                    $time, a0, a1, a2, g0, g1, g2, y0, y1, y2, y3, y4, y5, y6, y7);
                            end else begin
                                $display("FALHOU: t=%0t a0=%b a1=%b a2=%b g0=%b g1=%b g2=%b y0=%b y1=%b y2=%b y3=%b y4=%b y5=%b y6=%b y7=%b expected: y0=1 y1=1 y2=1 y3=1 y4=1 y5=0 y6=1 y7=1",
                                    $time, a0, a1, a2, g0, g1, g2, y0, y1, y2, y3, y4, y5, y6, y7);
                                errors = errors + 1;
                            end
                        3'b110: if (y6 == 0 & y1 == 1 & y2 == 1 & y3 == 1 & y4 == 1 & y5 == 1 & y0 == 1 & y7 == 1) begin
                                $display("Output y0 PASSOU: t=%0t a0=%b a1=%b a2=%b g0=%b g1=%b g2=%b y0=%b y1=%b y2=%b y3=%b y4=%b y5=%b y6=%b y7=%b",
                                    $time, a0, a1, a2, g0, g1, g2, y0, y1, y2, y3, y4, y5, y6, y7);
                            end else begin
                                $display("FALHOU: t=%0t a0=%b a1=%b a2=%b g0=%b g1=%b g2=%b y0=%b y1=%b y2=%b y3=%b y4=%b y5=%b y6=%b y7=%b expected: y0=1 y1=1 y2=1 y3=1 y4=1 y5=1 y6=0 y7=1",
                                    $time, a0, a1, a2, g0, g1, g2, y0, y1, y2, y3, y4, y5, y6, y7);
                                errors = errors + 1;
                            end
                        3'b111: if (y7 == 0 & y1 == 1 & y2 == 1 & y3 == 1 & y4 == 1 & y5 == 1 & y6 == 1 & y0 == 1) begin
                                $display("Output y0 PASSOU: t=%0t a0=%b a1=%b a2=%b g0=%b g1=%b g2=%b y0=%b y1=%b y2=%b y3=%b y4=%b y5=%b y6=%b y7=%b",
                                    $time, a0, a1, a2, g0, g1, g2, y0, y1, y2, y3, y4, y5, y6, y7);
                            end else begin
                                $display("FALHOU: t=%0t a0=%b a1=%b a2=%b g0=%b g1=%b g2=%b y0=%b y1=%b y2=%b y3=%b y4=%b y5=%b y6=%b y7=%b expected: y0=1 y1=1 y2=1 y3=1 y4=1 y5=1 y6=1 y7=0",
                                    $time, a0, a1, a2, g0, g1, g2, y0, y1, y2, y3, y4, y5, y6, y7);
                                errors = errors + 1;
                            end
                        default: if (y7 == 1 & y1 == 1 & y2 == 1 & y3 == 1 & y4 == 1 & y5 == 1 & y6 == 1 & y0 == 1) begin
                                $display("Output y0 PASSOU: t=%0t a0=%b a1=%b a2=%b g0=%b g1=%b g2=%b y0=%b y1=%b y2=%b y3=%b y4=%b y5=%b y6=%b y7=%b",
                                    $time, a0, a1, a2, g0, g1, g2, y0, y1, y2, y3, y4, y5, y6, y7);
                            end else begin
                                $display("FALHOU: t=%0t a0=%b a1=%b a2=%b g0=%b g1=%b g2=%b y0=%b y1=%b y2=%b y3=%b y4=%b y5=%b y6=%b y7=%b expected: y0=1 y1=1 y2=1 y3=1 y4=1 y5=1 y6=1 y7=1",
                                    $time, a0, a1, a2, g0, g1, g2, y0, y1, y2, y3, y4, y5, y6, y7);
                                errors = errors + 1;
                            end
                    endcase
                end else begin // Input select desativado logo se for diferente de high (ou true) tem algo errado
                    if (y0 !== 1'b1 | y1 !== 1'b1 | y2 !== 1'b1 | y3 !== 1'b1 | y4 !== 1'b1 | y5 !== 1'b1 | y6 !== 1'b1 | y7 !== 1'b1) begin
                        $display("Input select FALHOU: t=%0t a0=%b a1=%b a2=%b g0=%b g1=%b g2=%b y0=%b y1=%b y2=%b y3=%b y4=%b y5=%b y6=%b y7=%b expected: y0=1 y1=1 y2=1 y3=1 y4=1 y5=1 y6=1 y7=1",
                            $time, a0, a1, a2, g0, g1, g2, y0, y1, y2, y3, y4, y5, y6, y7);
                        errors = errors + 1;
                    end
                end
            end
            $display("-------------------------");
        end

        // Resultado
        if (errors == 0)
            $display("TESTES PASSARAM");
        else
            $display("%0d TESTE(S) FALHOU(FALHARAM)", errors);

        $finish;
    end
endmodule