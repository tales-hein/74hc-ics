`timescale 1ns/1ps
module tb;
    reg pl_n;           // Parallel load assincrono (active low)
    reg cp;             // Clock
    reg ce_n;           // Clock enable (active low)
    reg ds;             // Serial data input
    reg [7:0] d;        // Parallel data inputs
    wire q7;            // Serial output do ultimo estagio
    wire q7_n;          // Q7 invertido
    reg [7:0] expected; // Estado esperado do registrador interno (Q0 a Q7)
    integer i;
    integer j;
    integer errors;

    //Instanciar module sob teste
    ic_74HC165 dut(
        .pl_n(pl_n),
        .cp(cp),
        .ce_n(ce_n),
        .ds(ds),
        .d(d),
        .q7(q7),
        .q7_n(q7_n)
    );

    initial cp = 0;
    always #30 cp = ~cp;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);

        pl_n = 1'b0;
        ce_n = 1'b0;
        ds = 1'b0;
        d = 8'b0000_0000;
        errors = 0;

        // Para cada valor: carga paralela e depois deslocar tudo pra fora por q7
        for (i = 0; i < 256; i = i + 1) begin
            // Carga paralela assincrona, nao precisa de borda do cp
            @(negedge cp) begin
                pl_n = 1'b0;
                d = i;
                expected = i;
                #10;
                if (q7 !== expected[7] || q7_n !== ~expected[7]) begin
                    $display("q7 com pl_n L falhou: pl_n=%b d=%b q7=%b q7_n=%b, expected q7=%b q7_n=%b", pl_n, d, q7, q7_n, expected[7], ~expected[7]);
                    errors = errors + 1;
                end
            end
            // Com pl_n L o posedge do cp nao pode deslocar
            @(posedge cp) begin
                #10;
                if (q7 !== expected[7] || q7_n !== ~expected[7]) begin
                    $display("q7 com pl_n L e cp pulsando falhou: pl_n=%b d=%b q7=%b q7_n=%b, expected q7=%b q7_n=%b", pl_n, d, q7, q7_n, expected[7], ~expected[7]);
                    errors = errors + 1;
                end
            end
            // Serial shift: DS -> Q0, Q0 -> Q1 ... Q6 -> Q7, entra o valor invertido por ds
            for (j = 7; j >= 0; j = j - 1) begin
                @(negedge cp) begin
                    pl_n = 1'b1;
                    ds = ~d[j];
                end
                @(posedge cp) begin
                    expected = {expected[6:0], ds};
                    #10;
                    if (q7 !== expected[7] || q7_n !== ~expected[7]) begin
                        $display("q7 com serial shift falhou: pl_n=%b ce_n=%b d=%b ds=%b q7=%b q7_n=%b, expected q7=%b q7_n=%b", pl_n, ce_n, d, ds, q7, q7_n, expected[7], ~expected[7]);
                        errors = errors + 1;
                    end
                end
            end
        end

        // Carregar padrao alternado, assim qualquer deslocamento indevido muda q7
        @(negedge cp) begin
            pl_n = 1'b0;
            d = 8'b1010_1010;
            expected = d;
        end
        // ce_n so pode subir com cp H, cp e ce funcionam como um OR internamente
        // (ce_n subindo com cp L tambem desloca, testado mais abaixo)
        @(posedge cp) begin
            #10;
            ce_n = 1'b1;
        end
        @(negedge cp) pl_n = 1'b1;

        // Hold: com ce_n H q7 nao muda mesmo com ds mudando e cp pulsando
        for (i = 0; i < 8; i = i + 1) begin
            @(negedge cp) ds = ~ds;
            @(posedge cp) begin
                #10;
                if (q7 !== expected[7] || q7_n !== ~expected[7]) begin
                    $display("q7 com ce_n H (hold) falhou: pl_n=%b ce_n=%b ds=%b q7=%b q7_n=%b, expected q7=%b q7_n=%b", pl_n, ce_n, ds, q7, q7_n, expected[7], ~expected[7]);
                    errors = errors + 1;
                end
            end
        end

        // Descer ce_n com cp H nao gera borda
        @(posedge cp) begin
            #10;
            ce_n = 1'b0;
            #10;
            if (q7 !== expected[7] || q7_n !== ~expected[7]) begin
                $display("q7 apos descer ce_n com cp H falhou: pl_n=%b ce_n=%b ds=%b q7=%b q7_n=%b, expected q7=%b q7_n=%b", pl_n, ce_n, ds, q7, q7_n, expected[7], ~expected[7]);
                errors = errors + 1;
            end
        end
        // Tabela: ce_n subindo com cp L tambem desloca
        @(negedge cp) begin
            ds = 1'b0;
            #5;
            ce_n = 1'b1;
            expected = {expected[6:0], ds};
            #10;
            if (q7 !== expected[7] || q7_n !== ~expected[7]) begin
                $display("q7 com borda de ce_n e cp L falhou: pl_n=%b ce_n=%b ds=%b q7=%b q7_n=%b, expected q7=%b q7_n=%b", pl_n, ce_n, ds, q7, q7_n, expected[7], ~expected[7]);
                errors = errors + 1;
            end
        end
        // Agora com ce_n H o posedge do cp nao pode deslocar de novo
        @(posedge cp) begin
            #10;
            if (q7 !== expected[7] || q7_n !== ~expected[7]) begin
                $display("q7 apos borda de ce_n falhou: pl_n=%b ce_n=%b ds=%b q7=%b q7_n=%b, expected q7=%b q7_n=%b", pl_n, ce_n, ds, q7, q7_n, expected[7], ~expected[7]);
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
