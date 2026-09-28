`timescale 1ns/1ps
module tb;
    reg a1, b1;
    reg a2, b2;
    reg a3, b3;
    reg a4, b4;
    wire y1, y2, y3, y4;
    integer i;
    integer errors;

    //Instanciar module sob teste
    ic_74HC32 dut(
        .a1(a1),
        .b1(b1),
        .a2(a2),
        .b2(b2),
        .a3(a3),
        .b3(b3),
        .a4(a4),
        .b4(b4),
        .y1(y1),
        .y2(y2),
        .y3(y3),
        .y4(y4)
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
            // 1º or
            {a1, b1} = i;
            #10;
            if (y1 !== (a1 | b1)) begin
                $display("1º or FALHOU: t=%0t a1=%b b1=%b y1=%b expected=%b",
                         $time, a1, b1, y1, (a1 | b1));
                errors = errors + 1;
            end else begin
                $display("1º or PASSOU: t=%0t a1=%b b1=%b y1=%b", $time, a1, b1, y1);
            end

            // 2º or
            {a2, b2} = i;
            #10;
            if (y2 !== (a2 | b2)) begin
                $display("2º or FALHOU: t=%0t a2=%b b2=%b y2=%b expected=%b",
                         $time, a2, b2, y2, (a2 | b2));
                errors = errors + 1;
            end else begin
                $display("2º or PASSOU: t=%0t a2=%b b2=%b y2=%b", $time, a2, b2, y2);
            end

            // 3º or
            {a3, b3} = i;
            #10;
            if (y3 !== (a3 | b3)) begin
                $display("3º or FALHOU: t=%0t a3=%b b3=%b y3=%b expected=%b",
                         $time, a3, b3, y3, (a3 | b3));
                errors = errors + 1;
            end else begin
                $display("3º or PASSOU: t=%0t a3=%b b3=%b y3=%b", $time, a3, b3, y3);
            end

            // 4º or
            {a4, b4} = i;
            #10;
            if (y4 !== (a4 | b4)) begin
                $display("4º or FALHOU: t=%0t a4=%b b4=%b y4=%b expected=%b",
                         $time, a4, b4, y4, (a4 | b4));
                errors = errors + 1;
            end else begin
                $display("4º or PASSOU: t=%0t a4=%b b4=%b y4=%b", $time, a4, b4, y4);
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