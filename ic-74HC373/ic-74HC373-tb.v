`timescale 1ns/1ps
module tb;
    reg oe_n;         // Output enable (active low)
    reg le;           // Latch enable
    reg [7:0] d;      // Data input
    wire [7:0] q;     // Outputs 3-state
    integer i;
    integer errors;

    //Instanciar module sob teste
    ic_74HC373 dut(
        .oe_n(oe_n),
        .le(le),
        .d(d),
        .q(q)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);

        oe_n = 1'b0;
        le = 1'b1;
        d = 8'b0000_0000;
        errors = 0;
        // Modo transparente: com le H q segue d
        for (i = 0; i < 256; i = i + 1) begin
            d = i;
            #10;
            if (q !== d) begin
                $display("q com le H (transparente) falhou: oe_n=%b le=%b d=%b q=%b, expected %b", oe_n, le, d, q, d);
                errors = errors + 1;
            end
        end
        // Latch: d estavel antes da borda de descida do le, depois q segura o valor
        d = 8'b1010_0101;
        #10;
        le = 1'b0;
        #10;
        for (i = 0; i < 256; i = i + 1) begin
            d = i;
            #10;
            if (q !== 8'b1010_0101) begin
                $display("q com le L (latch) falhou: oe_n=%b le=%b d=%b q=%b, expected %b", oe_n, le, d, q, 8'b1010_0101);
                errors = errors + 1;
            end
        end
        // Voltar le pra H, q deve seguir d de novo
        le = 1'b1;
        #10;
        if (q !== d) begin
            $display("q apos le voltar H falhou: oe_n=%b le=%b d=%b q=%b, expected %b", oe_n, le, d, q, d);
            errors = errors + 1;
        end
        // Desabilitar saida, q deve ir pra z
        oe_n = 1'b1;
        #10;
        if (q !== 8'bz) begin
            $display("q com oe_n H falhou: oe_n=%b le=%b d=%b q=%b, expected %b", oe_n, le, d, q, 8'bz);
            errors = errors + 1;
        end
        // Com saida desabilitada o latch continua funcionando (oe nao afeta o latch)
        d = 8'b0011_1100;
        #10;
        if (q !== 8'bz) begin
            $display("q com oe_n H e le H falhou: oe_n=%b le=%b d=%b q=%b, expected %b", oe_n, le, d, q, 8'bz);
            errors = errors + 1;
        end
        le = 1'b0;
        #10;
        d = 8'b1111_1111;
        #10;
        if (q !== 8'bz) begin
            $display("q com oe_n H e le L falhou: oe_n=%b le=%b d=%b q=%b, expected %b", oe_n, le, d, q, 8'bz);
            errors = errors + 1;
        end
        // Reabilitar saida deve mostrar o valor travado enquanto estava desabilitada
        oe_n = 1'b0;
        #10;
        if (q !== 8'b0011_1100) begin
            $display("q apos reabilitar oe_n falhou: oe_n=%b le=%b d=%b q=%b, expected %b", oe_n, le, d, q, 8'b0011_1100);
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
