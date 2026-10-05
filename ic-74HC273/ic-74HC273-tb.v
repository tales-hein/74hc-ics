`timescale 1ns/1ps
module tb;
    reg mr;     // Reset (junto com sd controlamos operação normal, preset (isso "grava" o flip flop achei confuso n sei pq) e clear)
    reg cp;           // Clock
    reg [7:0] d;      // Data input
    wire [7:0] q;     // Outputs
    integer i;
    integer errors;

    //Instanciar module sob teste
    ic_74HC273 dut(
        .mr(mr),
        .d(d),
        .cp(cp),
        .q(q)
    );

    initial cp = 0;
    always #30 cp = ~cp;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);

        mr = 1'b0;
        d = 8'b0000_0000;
        errors = 0;

        // Aguardar um pouco em reset
        repeat (3) @(posedge cp);
        @(negedge cp) mr = 1'b1;

        // Pulso em d para setar q high e low
        for (i = 0; i < 8; i = i + 1) begin
            @(negedge cp) d[i] = 1'b1;
            @(posedge cp) begin
                #10;
                if (q[i] !== 1'b1) begin
                    $display("q[%0d] com d H falhou: d=%b q=%b, expected %b", i, d[i], q[i], 1'b1);
                    errors = errors + 1;
                end
            end
            @(negedge cp) d[i] = 1'b0;
            @(posedge cp) begin
                #10;
                if (q[i] !== 1'b0) begin
                    $display("q[%0d] com d L falhou: d=%b q=%b, expected %b", i, d[i], q[i], 1'b0);
                    errors = errors + 1;
                end
            end
            // Setar data para testar se o reset muda o estado para low
            @(negedge cp) d[i] = 1'b1;
            @(posedge cp) begin
                #5;
                if (q[i] !== 1'b1) begin
                    $display("q[%0d] com d H logo antes de reset falhou: d=%b q=%b, expected %b", i, d[i], q[i], 1'b1);
                    errors = errors + 1;
                end
            end
            // Testar reset
            @(negedge cp) begin
                mr = 1'b0;
                #5;
                // Testar se o reset ja funciona antes de um posedge do cp
                if (q[i] !== 1'b0) begin
                    $display("q[%0d] com d H e reset ativo falhou: d=%b q=%b, expected %b", i, d[i], q[i], 1'b0);
                    errors = errors + 1;
                end
            end
            // Esperar ver se o posedge do cp n ta zoando 
            repeat (2) @(posedge cp);
            #10;
            if (q[i] !== 1'b0) begin
                $display("q[%0d] com d H e reset ativo falhou após posedge de cp: d=%b q=%b, expected %b", i, d[i], q[i], 1'b0);
                errors = errors + 1;
            end
            // Testar se seta depois de desativar reset
            @(negedge cp) mr = 1'b1;
            @(posedge cp) begin
                #10;
                if (q[i] !== 1'b1) begin
                    $display("q[%d] com d H falhou: d=%b q=%b, expected %b", i, d[i], q[i], 1'b1);
                    errors = errors + 1;
                end
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