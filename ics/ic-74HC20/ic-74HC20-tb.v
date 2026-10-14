`timescale 1ns/1ps
module tb;
    reg a1, b1, c1, d1;
    reg a2, b2, c2, d2;
    wire y1, y2;
    integer i;
    integer errors;

    //Instanciar module sob teste
    ic_74HC20 dut(
        .a1(a1),
        .b1(b1),
        .c1(c1),
        .d1(d1),
        .a2(a2),
        .b2(b2),
        .c2(c2),
        .d2(d2),
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

        // Sinais e validação
        for (i = 0; i < 16; i = i + 1) begin
            // 1º nand
            {a1, b1, c1, d1} = i;
            #10;
            if (y1 !== ~(a1 & b1 & c1 & d1)) begin
                $display("1º nand FALHOU: t=%0t a1=%b b1=%b c1=%b d1=%b y1=%b expected=%b",
                         $time, a1, b1, c1, d1, y1, ~(a1 & b1 & c1 & d1));
                errors = errors + 1;
            end else begin
                $display("1º nand PASSOU: t=%0t a1=%b b1=%b c1=%b d1=%b y1=%b", $time, a1, b1, c1, d1, y1);
            end

            // 2º nand
            {a2, b2, c2, d2} = i;
            #10;
            if (y2 !== ~(a2 & b2 & c2 & d2)) begin
                $display("2º nand FALHOU: t=%0t a2=%b b2=%b c2=%b d2=%b y2=%b expected=%b",
                         $time, a2, b2, c2, d2, y2, ~(a2 & b2 & c2 & d2));
                errors = errors + 1;
            end else begin
                $display("2º nand PASSOU: t=%0t a2=%b b2=%b c2=%b d2=%b y2=%b", $time, a2, b2, c2, d2, y2);
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