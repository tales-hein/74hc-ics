`timescale 1ns/1ps
module tb;
    reg a1, a2, a3, a4, a5, a6;
    wire y1, y2, y3, y4, y5, y6;
    integer i;
    integer errors;

    //Instanciar module sob teste
    ic_74HC04 dut(
        .a1(a1),
        .a2(a2),
        .a3(a3),
        .a4(a4),
        .a5(a5),
        .a6(a6),
        .y1(y1),
        .y2(y2),
        .y3(y3),
        .y4(y4),
        .y5(y5),
        .y6(y6)
    );

    // Dump das ondas para visualização
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);
    end
    
    initial begin
        errors = 0;

        // Sinais e validação
        for (i = 0; i < 2; i = i + 1) begin
            // 1º inversor
            a1 = i;
            #10;
            if (y1 !== ~a1) begin
                $display("1º inversor FALHOU: t=%0t a1=%b y1=%b expected=%b",
                         $time, a1, y1, ~a1);
                errors = errors + 1;
            end else begin
                $display("1º inversor PASSOU: t=%0t a1=%b y1=%b", $time, a1, y1);
            end

            // 2º inversor
            a2 = i;
            #10;
            if (y2 !== ~a2) begin
                $display("2º inversor FALHOU: t=%0t a2=%b y2=%b expected=%b",
                         $time, a2, y2, ~a2);
                errors = errors + 1;
            end else begin
                $display("2º inversor PASSOU: t=%0t a2=%b y2=%b", $time, a2, y2);
            end

            // 3º inversor
            a3 = i;
            #10;
            if (y3 !== ~a3) begin
                $display("3º inversor FALHOU: t=%0t a3=%b y3=%b expected=%b",
                         $time, a3, y3, ~a3);
                errors = errors + 1;
            end else begin
                $display("3º inversor PASSOU: t=%0t a3=%b y3=%b", $time, a3, y3);
            end

            // 4º inversor
            a4 = i;
            #10;
            if (y4 !== ~a4) begin
                $display("4º inversor FALHOU: t=%0t a4=%b y4=%b expected=%b",
                         $time, a4, y4, ~a4);
                errors = errors + 1;
            end else begin
                $display("4º inversor PASSOU: t=%0t a4=%b y4=%b", $time, a4, y4);
            end

            // 5º inversor
            a5 = i;
            #10;
            if (y5 !== ~a5) begin
                $display("5º inversor FALHOU: t=%0t a5=%b y5=%b expected=%b",
                         $time, a5, y5, ~a5);
                errors = errors + 1;
            end else begin
                $display("5º inversor PASSOU: t=%0t a5=%b y5=%b", $time, a5, y5);
            end

            // 6º inversor
            a6 = i;
            #10;
            if (y6 !== ~a6) begin
                $display("6º inversor FALHOU: t=%0t a6=%b y6=%b expected=%b",
                         $time, a6, y6, ~a6);
                errors = errors + 1;
            end else begin
                $display("6º inversor PASSOU: t=%0t a6=%b y6=%b", $time, a6, y6);
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