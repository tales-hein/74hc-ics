`timescale 1ns/1ps
module tb;
    reg e_n;          // Data enable (active low)
    reg cp;           // Clock
    reg [7:0] d;      // Data input
    wire [7:0] q;     // Outputs
    integer i;
    integer errors;

    //Instanciar module sob teste
    ic_74HC377 dut(
        .e_n(e_n),
        .cp(cp),
        .d(d),
        .q(q)
    );

    initial cp = 0;
    always #30 cp = ~cp;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);

        e_n = 1'b0;
        d = 8'b0000_0000;
        errors = 0;

        // Com enable ativo carregar todos os valores possiveis de d
        for (i = 0; i < 256; i = i + 1) begin
            @(negedge cp) d = i;
            @(posedge cp) begin
                #10;
                if (q !== d) begin
                    $display("q com e_n L falhou: e_n=%b d=%b q=%b, expected %b", e_n, d, q, d);
                    errors = errors + 1;
                end
            end
        end
        // Carregar um valor conhecido antes de testar o hold
        @(negedge cp) d = 8'b1010_0101;
        @(posedge cp);
        // Mudar d sem borda do cp nao pode mudar q
        @(negedge cp) begin
            d = 8'b0101_1010;
            #10;
            if (q !== 8'b1010_0101) begin
                $display("q mudou sem posedge de cp: e_n=%b d=%b q=%b, expected %b", e_n, d, q, 8'b1010_0101);
                errors = errors + 1;
            end
            // Voltar d pro valor conhecido pq o proximo posedge ainda tem e_n L
            d = 8'b1010_0101;
        end
        // Desativar enable, q deve segurar o valor mesmo com d mudando e cp pulsando
        @(negedge cp) e_n = 1'b1;
        for (i = 0; i < 256; i = i + 1) begin
            @(negedge cp) d = i;
            @(posedge cp) begin
                #10;
                if (q !== 8'b1010_0101) begin
                    $display("q com e_n H (hold) falhou: e_n=%b d=%b q=%b, expected %b", e_n, d, q, 8'b1010_0101);
                    errors = errors + 1;
                end
            end
        end
        // Reativar enable, q so deve mudar no proximo posedge do cp
        @(negedge cp) begin
            e_n = 1'b0;
            d = 8'b0011_1100;
            #10;
            if (q !== 8'b1010_0101) begin
                $display("q com e_n L antes do cp falhou: e_n=%b d=%b q=%b, expected %b", e_n, d, q, 8'b1010_0101);
                errors = errors + 1;
            end
        end
        @(posedge cp) begin
            #10;
            if (q !== 8'b0011_1100) begin
                $display("q com e_n L apos reativar falhou: e_n=%b d=%b q=%b, expected %b", e_n, d, q, 8'b0011_1100);
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
