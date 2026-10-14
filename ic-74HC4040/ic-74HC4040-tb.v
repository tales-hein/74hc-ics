`timescale 1ns/1ps
module tb;
    reg cp;              // Clock (HIGH-to-LOW)
    reg mr;              // Master reset assincrono (active high)
    wire [11:0] q;       // Outputs Q0 a Q11
    reg [11:0] expected; // Contagem esperada
    integer i;
    integer errors;

    //Instanciar module sob teste
    ic_74HC4040 dut(
        .cp(cp),
        .mr(mr),
        .q(q)
    );

    initial cp = 0;
    always #30 cp = ~cp;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);

        mr = 1'b1;
        errors = 0;

        // Reset ativo: q fica em 0 com cp pulsando
        repeat (3) @(negedge cp) begin
            #10;
            if (q !== 12'd0) begin
                $display("reset com mr H falhou: mr=%b q=%b, expected %b", mr, q, 12'd0);
                errors = errors + 1;
            end
        end

        // Soltar o reset com cp H e contar uma volta completa + um pouco (4095 -> 0)
        @(posedge cp) mr = 1'b0;
        expected = 12'd0;
        for (i = 0; i < 4100; i = i + 1) begin
            // Conta na borda de descida
            @(negedge cp) begin
                expected = expected + 1;
                #10;
                if (q !== expected) begin
                    $display("count falhou: mr=%b q=%b, expected %b", mr, q, expected);
                    errors = errors + 1;
                end
            end
            // Borda de subida nao conta
            @(posedge cp) begin
                #10;
                if (q !== expected) begin
                    $display("q apos posedge de cp falhou: mr=%b q=%b, expected %b", mr, q, expected);
                    errors = errors + 1;
                end
            end
        end

        // Reset assincrono no meio da contagem com cp H, sem precisar de borda
        mr = 1'b1;
        #5;
        if (q !== 12'd0) begin
            $display("reset com mr H antes do cp falhou: mr=%b q=%b, expected %b", mr, q, 12'd0);
            errors = errors + 1;
        end
        // Esperar ver se o negedge do cp n ta zoando
        @(negedge cp) begin
            #10;
            if (q !== 12'd0) begin
                $display("reset com mr H apos negedge de cp falhou: mr=%b q=%b, expected %b", mr, q, 12'd0);
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
