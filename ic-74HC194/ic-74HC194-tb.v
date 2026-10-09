`timescale 1ns/1ps
module tb;
    reg mr_n;           // Master reset assincrono (active low)
    reg cp;             // Clock
    reg s0, s1;         // Mode select
    reg dsr;            // Serial data shift right
    reg dsl;            // Serial data shift left
    reg [3:0] d;        // Parallel data inputs
    wire [3:0] q;       // Outputs
    reg [3:0] expected; // Estado esperado do registrador
    reg [15:0] pattern; // Bits jogados nas entradas seriais
    integer i;
    integer errors;

    //Instanciar module sob teste
    ic_74HC194 dut(
        .mr_n(mr_n),
        .cp(cp),
        .s0(s0),
        .s1(s1),
        .dsr(dsr),
        .dsl(dsl),
        .d(d),
        .q(q)
    );

    initial cp = 0;
    always #30 cp = ~cp;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);

        mr_n = 1'b0;
        s0 = 1'b1;
        s1 = 1'b1;
        dsr = 1'b0;
        dsl = 1'b0;
        d = 4'b1111;
        pattern = 16'b1011_0010_1110_0100;
        errors = 0;

        // Reset ativo: q fica L mesmo em modo parallel load com cp pulsando
        repeat (2) @(posedge cp) begin
            #10;
            if (q !== 4'b0000) begin
                $display("q com mr_n L falhou: mr_n=%b s1=%b s0=%b d=%b q=%b, expected %b", mr_n, s1, s0, d, q, 4'b0000);
                errors = errors + 1;
            end
        end
        @(negedge cp) mr_n = 1'b1;

        // Parallel load (S1 H, S0 H): todos os valores possiveis de d
        for (i = 0; i < 16; i = i + 1) begin
            @(negedge cp) d = i;
            @(posedge cp) begin
                #10;
                if (q !== d) begin
                    $display("q com parallel load falhou: s1=%b s0=%b d=%b q=%b, expected %b", s1, s0, d, q, d);
                    errors = errors + 1;
                end
            end
        end
        expected = 4'b1111;

        // Shift right (S1 L, S0 H): DSR -> Q0, Q0 -> Q1, Q1 -> Q2, Q2 -> Q3
        for (i = 0; i < 16; i = i + 1) begin
            @(negedge cp) begin
                s1 = 1'b0;
                s0 = 1'b1;
                dsr = pattern[i];
            end
            @(posedge cp) begin
                expected = {expected[2:0], dsr};
                #10;
                if (q !== expected) begin
                    $display("q com shift right falhou: s1=%b s0=%b dsr=%b q=%b, expected %b", s1, s0, dsr, q, expected);
                    errors = errors + 1;
                end
            end
        end

        // Shift left (S1 H, S0 L): DSL -> Q3, Q3 -> Q2, Q2 -> Q1, Q1 -> Q0
        for (i = 0; i < 16; i = i + 1) begin
            @(negedge cp) begin
                s1 = 1'b1;
                s0 = 1'b0;
                dsl = pattern[i];
            end
            @(posedge cp) begin
                expected = {dsl, expected[3:1]};
                #10;
                if (q !== expected) begin
                    $display("q com shift left falhou: s1=%b s0=%b dsl=%b q=%b, expected %b", s1, s0, dsl, q, expected);
                    errors = errors + 1;
                end
            end
        end

        // Hold (S1 L, S0 L): q nao muda mesmo com d e entradas seriais mudando e cp pulsando
        for (i = 0; i < 4; i = i + 1) begin
            @(negedge cp) begin
                s1 = 1'b0;
                s0 = 1'b0;
                d = ~expected;
                dsr = ~dsr;
                dsl = ~dsl;
            end
            @(posedge cp) begin
                #10;
                if (q !== expected) begin
                    $display("q com hold falhou: s1=%b s0=%b d=%b dsr=%b dsl=%b q=%b, expected %b", s1, s0, d, dsr, dsl, q, expected);
                    errors = errors + 1;
                end
            end
        end

        // Carregar um valor conhecido antes de testar o reset
        @(negedge cp) begin
            s1 = 1'b1;
            s0 = 1'b1;
            d = 4'b1010;
        end
        @(posedge cp);

        // Reset assincrono: q vai pra L sem precisar de borda do cp
        @(negedge cp) begin
            mr_n = 1'b0;
            #10;
            if (q !== 4'b0000) begin
                $display("q com mr_n L antes do cp falhou: mr_n=%b s1=%b s0=%b d=%b q=%b, expected %b", mr_n, s1, s0, d, q, 4'b0000);
                errors = errors + 1;
            end
        end
        // Esperar ver se o posedge do cp n ta zoando
        @(posedge cp) begin
            #10;
            if (q !== 4'b0000) begin
                $display("q com mr_n L apos posedge de cp falhou: mr_n=%b s1=%b s0=%b d=%b q=%b, expected %b", mr_n, s1, s0, d, q, 4'b0000);
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
