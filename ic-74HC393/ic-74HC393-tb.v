`timescale 1ns/1ps
module tb;
    reg cp1, cp2;        // Clocks (HIGH-to-LOW)
    reg mr1, mr2;        // Master reset assincrono (active high)
    wire [3:0] q1, q2;   // Outputs de cada contador
    reg [3:0] expected1; // Contagem esperada do 1º contador
    reg [3:0] expected2; // Contagem esperada do 2º contador
    integer i;
    integer errors;

    //Instanciar module sob teste
    ic_74HC393 dut(
        .cp1(cp1),
        .mr1(mr1),
        .q1(q1),
        .cp2(cp2),
        .mr2(mr2),
        .q2(q2)
    );

    // Clocks com periodos diferentes pra ver se um contador nao usa o clock do outro
    initial cp1 = 0;
    always #30 cp1 = ~cp1;
    initial cp2 = 0;
    always #50 cp2 = ~cp2;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);

        mr1 = 1'b1;
        mr2 = 1'b1;
        errors = 0;

        // Reset ativo: os 2 contadores ficam em 0 com os clocks pulsando
        repeat (3) @(negedge cp1) begin
            #10;
            if (q1 !== 4'b0000 || q2 !== 4'b0000) begin
                $display("reset com mr1 e mr2 H falhou: mr1=%b mr2=%b q1=%b q2=%b, expected q1=%b q2=%b", mr1, mr2, q1, q2, 4'b0000, 4'b0000);
                errors = errors + 1;
            end
        end

        // 1º contador: soltar o reset com cp1 H e contar 2 voltas, 2º continua em reset
        @(posedge cp1) mr1 = 1'b0;
        expected1 = 4'b0000;
        for (i = 0; i < 32; i = i + 1) begin
            // Conta na borda de descida
            @(negedge cp1) begin
                expected1 = expected1 + 1;
                #10;
                if (q1 !== expected1 || q2 !== 4'b0000) begin
                    $display("count do 1º contador falhou: mr1=%b mr2=%b q1=%b q2=%b, expected q1=%b q2=%b", mr1, mr2, q1, q2, expected1, 4'b0000);
                    errors = errors + 1;
                end
            end
            // Borda de subida nao conta
            @(posedge cp1) begin
                #10;
                if (q1 !== expected1) begin
                    $display("q1 apos posedge de cp1 falhou: mr1=%b q1=%b, expected %b", mr1, q1, expected1);
                    errors = errors + 1;
                end
            end
        end

        // Deixar o 1º contador num valor diferente de 0 antes de resetar
        @(negedge cp1) expected1 = expected1 + 1;
        @(negedge cp1) expected1 = expected1 + 1;

        // Reset assincrono do 1º contador com cp1 H, sem precisar de borda
        @(posedge cp1) begin
            #10;
            mr1 = 1'b1;
            #5;
            if (q1 !== 4'b0000) begin
                $display("reset do 1º contador antes do cp1 falhou: mr1=%b q1=%b, expected %b", mr1, q1, 4'b0000);
                errors = errors + 1;
            end
        end

        // 2º contador: soltar o reset com cp2 H e contar 2 voltas, 1º continua em reset
        @(posedge cp2) mr2 = 1'b0;
        expected2 = 4'b0000;
        for (i = 0; i < 32; i = i + 1) begin
            // Conta na borda de descida
            @(negedge cp2) begin
                expected2 = expected2 + 1;
                #10;
                if (q2 !== expected2 || q1 !== 4'b0000) begin
                    $display("count do 2º contador falhou: mr1=%b mr2=%b q1=%b q2=%b, expected q1=%b q2=%b", mr1, mr2, q1, q2, 4'b0000, expected2);
                    errors = errors + 1;
                end
            end
            // Borda de subida nao conta
            @(posedge cp2) begin
                #10;
                if (q2 !== expected2) begin
                    $display("q2 apos posedge de cp2 falhou: mr2=%b q2=%b, expected %b", mr2, q2, expected2);
                    errors = errors + 1;
                end
            end
        end

        // Deixar o 2º contador num valor diferente de 0 antes de resetar
        @(negedge cp2) expected2 = expected2 + 1;
        @(negedge cp2) expected2 = expected2 + 1;

        // Reset assincrono do 2º contador com cp2 H, sem precisar de borda
        @(posedge cp2) begin
            #10;
            mr2 = 1'b1;
            #5;
            if (q2 !== 4'b0000) begin
                $display("reset do 2º contador antes do cp2 falhou: mr2=%b q2=%b, expected %b", mr2, q2, 4'b0000);
                errors = errors + 1;
            end
        end
        // Esperar ver se o negedge do cp2 n ta zoando
        @(negedge cp2) begin
            #10;
            if (q2 !== 4'b0000) begin
                $display("reset do 2º contador apos negedge de cp2 falhou: mr2=%b q2=%b, expected %b", mr2, q2, 4'b0000);
                errors = errors + 1;
            end
        end

        if (errors == 0) begin
            $display("TESTES PASSARAM");
        end else begin
            $display("%0d ERRO(S)", errors);
        end
        $finish;
    end

endmodule
