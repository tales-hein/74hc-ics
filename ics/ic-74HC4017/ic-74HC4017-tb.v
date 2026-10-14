`timescale 1ns/1ps
module tb;
    reg mr;              // Master reset assincrono (active high)
    reg cp0;             // Clock LOW-to-HIGH (conta com cp1 L)
    reg cp1;             // Clock HIGH-to-LOW (conta com cp0 H)
    wire [9:0] q;        // Saidas decodificadas Q0 a Q9 (so uma H por vez)
    wire q5_9_n;         // Carry: L nos estados 5 a 9
    reg [9:0] expected;  // Saida decodificada esperada
    integer i;
    integer errors;

    //Instanciar module sob teste
    ic_74HC4017 dut(
        .mr(mr),
        .cp0(cp0),
        .cp1(cp1),
        .q(q),
        .q5_9_n(q5_9_n)
    );

    // Sem clock continuo aqui: tem 2 jeitos de avancar e varias combinacoes que nao podem contar,
    // entao os pulsos em cp0 e cp1 sao feitos na mao

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);

        mr = 1'b1;
        cp0 = 1'b0;
        cp1 = 1'b0;
        errors = 0;
        expected = 10'b00_0000_0001;
        #10;

        // Reset: Q0 = Q5-9 = H, Q1 a Q9 = L
        if (q !== expected || q5_9_n !== 1'b1) begin
            $display("reset com mr H falhou: mr=%b q=%b q5_9_n=%b, expected q=%b q5_9_n=%b", mr, q, q5_9_n, expected, 1'b1);
            errors = errors + 1;
        end
        // Pulso em cp0 com mr H nao conta
        cp0 = 1'b1;
        #10;
        cp0 = 1'b0;
        #10;
        if (q !== expected || q5_9_n !== 1'b1) begin
            $display("reset com mr H e pulso em cp0 falhou: mr=%b q=%b q5_9_n=%b, expected q=%b q5_9_n=%b", mr, q, q5_9_n, expected, 1'b1);
            errors = errors + 1;
        end
        mr = 1'b0;
        #10;

        // Conta na borda de subida de cp0 com cp1 L: 2 voltas pra passar pelo 9 -> 0
        for (i = 0; i < 20; i = i + 1) begin
            cp0 = 1'b1;
            expected = {expected[8:0], expected[9]};
            #10;
            if (q !== expected || q5_9_n !== ~|expected[9:5]) begin
                $display("count com cp0 subindo falhou: cp0=%b cp1=%b q=%b q5_9_n=%b, expected q=%b q5_9_n=%b", cp0, cp1, q, q5_9_n, expected, ~|expected[9:5]);
                errors = errors + 1;
            end
            // Borda de descida de cp0 com cp1 L nao conta
            cp0 = 1'b0;
            #10;
            if (q !== expected || q5_9_n !== ~|expected[9:5]) begin
                $display("q apos cp0 descer falhou: cp0=%b cp1=%b q=%b q5_9_n=%b, expected q=%b q5_9_n=%b", cp0, cp1, q, q5_9_n, expected, ~|expected[9:5]);
                errors = errors + 1;
            end
        end

        // Preparar pra contar com cp1: subir cp1 com cp0 L e depois cp0 com cp1 H, nenhum dos 2 conta
        cp1 = 1'b1;
        #10;
        cp0 = 1'b1;
        #10;
        if (q !== expected || q5_9_n !== ~|expected[9:5]) begin
            $display("q ao preparar cp0 H e cp1 H falhou: cp0=%b cp1=%b q=%b q5_9_n=%b, expected q=%b q5_9_n=%b", cp0, cp1, q, q5_9_n, expected, ~|expected[9:5]);
            errors = errors + 1;
        end

        // Conta na borda de descida de cp1 com cp0 H: 2 voltas
        for (i = 0; i < 20; i = i + 1) begin
            cp1 = 1'b0;
            expected = {expected[8:0], expected[9]};
            #10;
            if (q !== expected || q5_9_n !== ~|expected[9:5]) begin
                $display("count com cp1 descendo falhou: cp0=%b cp1=%b q=%b q5_9_n=%b, expected q=%b q5_9_n=%b", cp0, cp1, q, q5_9_n, expected, ~|expected[9:5]);
                errors = errors + 1;
            end
            // Borda de subida de cp1 com cp0 H nao conta
            cp1 = 1'b1;
            #10;
            if (q !== expected || q5_9_n !== ~|expected[9:5]) begin
                $display("q apos cp1 subir falhou: cp0=%b cp1=%b q=%b q5_9_n=%b, expected q=%b q5_9_n=%b", cp0, cp1, q, q5_9_n, expected, ~|expected[9:5]);
                errors = errors + 1;
            end
        end

        // cp1 H: pulsos em cp0 nao contam
        for (i = 0; i < 3; i = i + 1) begin
            cp0 = 1'b0;
            #10;
            cp0 = 1'b1;
            #10;
            if (q !== expected || q5_9_n !== ~|expected[9:5]) begin
                $display("q com cp1 H e pulso em cp0 falhou: cp0=%b cp1=%b q=%b q5_9_n=%b, expected q=%b q5_9_n=%b", cp0, cp1, q, q5_9_n, expected, ~|expected[9:5]);
                errors = errors + 1;
            end
        end

        // cp0 L: pulsos em cp1 nao contam
        cp0 = 1'b0;
        #10;
        for (i = 0; i < 3; i = i + 1) begin
            cp1 = 1'b0;
            #10;
            cp1 = 1'b1;
            #10;
            if (q !== expected || q5_9_n !== ~|expected[9:5]) begin
                $display("q com cp0 L e pulso em cp1 falhou: cp0=%b cp1=%b q=%b q5_9_n=%b, expected q=%b q5_9_n=%b", cp0, cp1, q, q5_9_n, expected, ~|expected[9:5]);
                errors = errors + 1;
            end
        end

        // Voltar cp1 pra L (cp0 L, nao conta) e avancar 7 estados pra sair do 0 antes do reset
        cp1 = 1'b0;
        #10;
        for (i = 0; i < 7; i = i + 1) begin
            cp0 = 1'b1;
            expected = {expected[8:0], expected[9]};
            #10;
            cp0 = 1'b0;
            #10;
        end
        if (q !== expected || q5_9_n !== ~|expected[9:5]) begin
            $display("q antes do reset falhou: cp0=%b cp1=%b q=%b q5_9_n=%b, expected q=%b q5_9_n=%b", cp0, cp1, q, q5_9_n, expected, ~|expected[9:5]);
            errors = errors + 1;
        end

        // Reset assincrono no meio da contagem, sem precisar de borda
        mr = 1'b1;
        expected = 10'b00_0000_0001;
        #10;
        if (q !== expected || q5_9_n !== 1'b1) begin
            $display("reset com mr H no meio da contagem falhou: mr=%b q=%b q5_9_n=%b, expected q=%b q5_9_n=%b", mr, q, q5_9_n, expected, 1'b1);
            errors = errors + 1;
        end

        if (errors == 0) begin
            $display("TESTES PASSARAM");
        end else begin
            $display("%0d ERRO(S)", errors);
        end
        $finish;
    end

endmodule
