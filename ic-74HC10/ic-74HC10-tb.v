`timescale 1ns/1ps
module tb;
    reg a1, b1, c1;
    reg a2, b2, c2;
    reg a3, b3, c3;
    wire y1, y2, y3;
    integer i;
    integer errors;

    //Instanciar module sob teste
    ic_74HC10 dut(
        .a1(a1),
        .b1(b1),
        .c1(c1),
        .a2(a2),
        .b2(b2),
        .c2(c2),
        .a3(a3),
        .b3(b3),
        .c3(c3),
        .y1(y1),
        .y2(y2),
        .y3(y3)
    );

    // Dump das ondas para visualização
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);
    end
    
    initial begin
        errors = 0;

        // Sinais e validação
        for (i = 0; i < 4; i = i + 1) begin
            // 1º nand
            {a1, b1} = i;
            c1 = a1;
            #10;
            if (y1 !== ~(a1 & b1 & c1)) begin
                $display("1º nand FALHOU: t=%0t a1=%b b1=%b c1=%b y1=%b expected=%b",
                         $time, a1, b1, c1, y1, ~(a1 & b1 & c1));
                errors = errors + 1;
            end else begin
                $display("1º nand PASSOU: t=%0t a1=%b b1=%b c1=%b y1=%b", $time, a1, b1, c1, y1);
            end

            // 2º nand
            {a2, b2} = i;
            c2 = a2;
            #10;
            if (y2 !== ~(a2 & b2 & c2)) begin
                $display("2º nand FALHOU: t=%0t a2=%b b2=%b c2=%b y2=%b expected=%b",
                         $time, a2, b2, c2, y2, ~(a2 & b2 & c2));
                errors = errors + 1;
            end else begin
                $display("2º nand PASSOU: t=%0t a2=%b b2=%b c2=%b y2=%b", $time, a2, b2, c2, y2);
            end

            // 3º nand
            {a3, b3} = i;
            c3 = a3;
            #10;
            if (y3 !== ~(a3 & b3 & c3)) begin
                $display("3º nand FALHOU: t=%0t a3=%b b3=%b c3=%b y3=%b expected=%b",
                         $time, a3, b3, c3, y3, ~(a3 & b3 & c3));
                errors = errors + 1;
            end else begin
                $display("3º nand PASSOU: t=%0t a3=%b b3=%b c3=%b y3=%b", $time, a3, b3, c3, y3);
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