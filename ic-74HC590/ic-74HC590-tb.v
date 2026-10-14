`timescale 1ns/1ps
module tb;
    reg oe_n;               // Output enable (active low)
    reg cpr;                // Clock do registrador de saida
    reg mrc_n;              // Master reset do contador, assincrono (active low)
    reg ce_n;               // Count enable (active low)
    reg cpc;                // Clock do contador
    wire [7:0] q;           // Saidas 3-state do registrador
    wire rco_n;             // Ripple carry (active low): L com o contador interno em 255
    reg [7:0] expected;     // Valor esperado do contador interno
    reg [7:0] expected_reg; // Valor esperado do registrador de saida
    integer i;
    integer errors;

    //Instanciar module sob teste
    ic_74HC590 dut(
        .oe_n(oe_n),
        .cpr(cpr),
        .mrc_n(mrc_n),
        .ce_n(ce_n),
        .cpc(cpc),
        .q(q),
        .rco_n(rco_n)
    );

    // cpc roda sozinho, cpr e pulsado na mao (sempre com cpc L) pra copiar o contador pro registrador
    initial cpc = 0;
    always #30 cpc = ~cpc;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);

        oe_n = 1'b0;
        cpr = 1'b0;
        mrc_n = 1'b0;
        ce_n = 1'b0;
        errors = 0;
        expected = 8'd0;

        // Counter clear: contador fica em 0 com cpc pulsando, cpr copia o 0 pro registrador
        repeat (2) @(posedge cpc);
        @(negedge cpc) begin
            cpr = 1'b1;
            expected_reg = expected;
            #10;
            if (q !== expected_reg || rco_n !== 1'b1) begin
                $display("clear com mrc_n L falhou: mrc_n=%b q=%b rco_n=%b, expected q=%b rco_n=%b", mrc_n, q, rco_n, expected_reg, 1'b1);
                errors = errors + 1;
            end
            cpr = 1'b0;
            mrc_n = 1'b1;
        end

        // Count: 255 bordas de cpc, cpr copiando o contador depois de cada uma
        for (i = 0; i < 255; i = i + 1) begin
            @(posedge cpc) expected = expected + 1;
            @(negedge cpc) begin
                cpr = 1'b1;
                expected_reg = expected;
                #10;
                // rco_n L so com o contador em 255
                if (q !== expected_reg || rco_n !== ~(expected == 8'd255)) begin
                    $display("count falhou: ce_n=%b q=%b rco_n=%b, expected q=%b rco_n=%b", ce_n, q, rco_n, expected_reg, ~(expected == 8'd255));
                    errors = errors + 1;
                end
                cpr = 1'b0;
            end
        end

        // ce_n H (cpc ta L aqui): contador para em 255 e rco_n continua L (rco so depende do contador)
        ce_n = 1'b1;
        for (i = 0; i < 4; i = i + 1) begin
            @(negedge cpc) begin
                cpr = 1'b1;
                expected_reg = expected;
                #10;
                if (q !== expected_reg || rco_n !== 1'b0) begin
                    $display("no count com ce_n H falhou: ce_n=%b q=%b rco_n=%b, expected q=%b rco_n=%b", ce_n, q, rco_n, expected_reg, 1'b0);
                    errors = errors + 1;
                end
                cpr = 1'b0;
            end
        end
        // Mexer no ce_n com cpc H tambem nao pode contar (clock nao passa pelo ce)
        @(posedge cpc) begin
            #10;
            ce_n = 1'b0;
            #5;
            ce_n = 1'b1;
        end
        @(negedge cpc) begin
            cpr = 1'b1;
            #10;
            if (q !== expected_reg || rco_n !== 1'b0) begin
                $display("no count com ce_n mudando e cpc H falhou: ce_n=%b q=%b rco_n=%b, expected q=%b rco_n=%b", ce_n, q, rco_n, expected_reg, 1'b0);
                errors = errors + 1;
            end
            cpr = 1'b0;
            // Voltar a contar
            ce_n = 1'b0;
        end
        // 255 -> 0
        @(posedge cpc) expected = expected + 1;
        @(negedge cpc) begin
            cpr = 1'b1;
            expected_reg = expected;
            #10;
            if (q !== expected_reg || rco_n !== 1'b1) begin
                $display("count 255 -> 0 falhou: ce_n=%b q=%b rco_n=%b, expected q=%b rco_n=%b", ce_n, q, rco_n, expected_reg, 1'b1);
                errors = errors + 1;
            end
            cpr = 1'b0;
        end

        // Sem borda no cpr o registrador nao muda, mesmo com o contador andando
        for (i = 0; i < 5; i = i + 1) begin
            @(posedge cpc) expected = expected + 1;
            @(negedge cpc) begin
                #10;
                if (q !== expected_reg) begin
                    $display("registrador sem borda de cpr falhou: cpr=%b q=%b, expected %b", cpr, q, expected_reg);
                    errors = errors + 1;
                end
            end
        end
        // Borda de subida de cpr (cpc ainda ta L aqui) copia o valor atual do contador
        cpr = 1'b1;
        expected_reg = expected;
        #10;
        if (q !== expected_reg) begin
            $display("registrador apos borda de cpr falhou: cpr=%b q=%b, expected %b", cpr, q, expected_reg);
            errors = errors + 1;
        end
        // Borda de descida do cpr nao muda o registrador, mesmo com o contador ja tendo andado
        @(posedge cpc) begin
            expected = expected + 1;
            #10;
            cpr = 1'b0;
            #5;
            if (q !== expected_reg) begin
                $display("registrador apos cpr descer falhou: cpr=%b q=%b, expected %b", cpr, q, expected_reg);
                errors = errors + 1;
            end
        end

        // oe_n H: q vai pra z, mas contador e registrador continuam funcionando
        @(negedge cpc) begin
            oe_n = 1'b1;
            #10;
            if (q !== 8'bz) begin
                $display("q com oe_n H falhou: oe_n=%b q=%b, expected %b", oe_n, q, 8'bz);
                errors = errors + 1;
            end
        end
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge cpc) expected = expected + 1;
            @(negedge cpc) begin
                cpr = 1'b1;
                expected_reg = expected;
                #10;
                if (q !== 8'bz) begin
                    $display("q com oe_n H e cpr pulsando falhou: oe_n=%b q=%b, expected %b", oe_n, q, 8'bz);
                    errors = errors + 1;
                end
                cpr = 1'b0;
            end
        end
        // Reabilitar saida (cpc ainda ta L aqui) deve mostrar o que foi copiado enquanto estava em z
        oe_n = 1'b0;
        #10;
        if (q !== expected_reg) begin
            $display("q apos reabilitar oe_n falhou: oe_n=%b q=%b, expected %b", oe_n, q, expected_reg);
            errors = errors + 1;
        end

        // Counter clear assincrono: zera so o contador, o registrador continua com o valor antigo
        @(posedge cpc) expected = expected + 1;
        @(negedge cpc) begin
            mrc_n = 1'b0;
            expected = 8'd0;
            #10;
            if (q !== expected_reg || rco_n !== 1'b1) begin
                $display("registrador com mrc_n L falhou: mrc_n=%b q=%b rco_n=%b, expected q=%b rco_n=%b", mrc_n, q, rco_n, expected_reg, 1'b1);
                errors = errors + 1;
            end
            // Agora sim copia o contador zerado
            cpr = 1'b1;
            expected_reg = expected;
            #10;
            if (q !== expected_reg) begin
                $display("clear com mrc_n L antes do cpc falhou: mrc_n=%b q=%b, expected %b", mrc_n, q, expected_reg);
                errors = errors + 1;
            end
            cpr = 1'b0;
        end
        // Esperar ver se o posedge do cpc n ta zoando
        @(posedge cpc);
        @(negedge cpc) begin
            cpr = 1'b1;
            #10;
            if (q !== 8'd0) begin
                $display("clear com mrc_n L apos posedge de cpc falhou: mrc_n=%b q=%b, expected %b", mrc_n, q, 8'd0);
                errors = errors + 1;
            end
            cpr = 1'b0;
        end

        if (errors == 0) begin
            $display("TESTES PASSARAM");
        end else begin
            $display("%0d ERRO(S)", errors);
        end
        $finish;
    end

endmodule
