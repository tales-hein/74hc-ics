`timescale 1ns/1ps
module tb;
    reg mr_n;           // Master reset assincrono (active low)
    reg cp;             // Clock
    reg s0, s1;         // Mode select
    reg oe1_n, oe2_n;   // Output enable 3-state (active low)
    reg dsr;            // Serial data shift right
    reg dsl;            // Serial data shift left
    wire [7:0] io;      // Barramento I/O0 a I/O7: entrada na carga paralela, saida 3-state no resto
    wire q0, q7;        // Saidas seriais (nao sao 3-state)
    reg [7:0] io_in;    // Valor que o tb coloca no barramento
    reg io_drive;       // tb dirigindo o barramento
    reg [7:0] expected; // Estado esperado do registrador
    reg [15:0] pattern; // Bits jogados nas entradas seriais
    integer i;
    integer errors;

    // tb so dirige o barramento na carga paralela, no resto deixa em z pra ler a saida
    assign io = io_drive ? io_in : 8'bz;

    //Instanciar module sob teste
    ic_74HC299 dut(
        .mr_n(mr_n),
        .cp(cp),
        .s0(s0),
        .s1(s1),
        .oe1_n(oe1_n),
        .oe2_n(oe2_n),
        .dsr(dsr),
        .dsl(dsl),
        .io(io),
        .q0(q0),
        .q7(q7)
    );

    initial cp = 0;
    always #30 cp = ~cp;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);

        mr_n = 1'b0;
        s0 = 1'b1;
        s1 = 1'b0;
        oe1_n = 1'b0;
        oe2_n = 1'b0;
        dsr = 1'b1;
        dsl = 1'b0;
        io_in = 8'b0000_0000;
        io_drive = 1'b0;
        pattern = 16'b1011_0010_1110_0100;
        errors = 0;

        // Reset ativo: tudo L mesmo em shift right com dsr H e cp pulsando
        repeat (2) @(posedge cp) begin
            #10;
            if (io !== 8'b0000_0000 || q0 !== 1'b0 || q7 !== 1'b0) begin
                $display("reset com mr_n L falhou: mr_n=%b s1=%b s0=%b io=%b q0=%b q7=%b, expected io=%b q0=%b q7=%b", mr_n, s1, s0, io, q0, q7, 8'b0000_0000, 1'b0, 1'b0);
                errors = errors + 1;
            end
        end
        @(negedge cp) begin
            mr_n = 1'b1;
            s0 = 1'b0;
            dsr = 1'b0;
        end

        // Parallel load (S1 H, S0 H): todos os valores possiveis pelo barramento
        for (i = 0; i < 256; i = i + 1) begin
            @(negedge cp) begin
                s1 = 1'b1;
                s0 = 1'b1;
                io_drive = 1'b0;
                #5;
                // S0 e S1 H desabilitam os buffers mesmo com oe1_n e oe2_n L
                if (io !== 8'bz) begin
                    $display("io com s1 e s0 H falhou: s1=%b s0=%b oe1_n=%b oe2_n=%b io=%b, expected %b", s1, s0, oe1_n, oe2_n, io, 8'bz);
                    errors = errors + 1;
                end
                io_in = i;
                io_drive = 1'b1;
            end
            @(posedge cp) begin
                expected = io_in;
                #10;
                if (q0 !== expected[0] || q7 !== expected[7]) begin
                    $display("parallel load falhou: s1=%b s0=%b io=%b q0=%b q7=%b, expected q0=%b q7=%b", s1, s0, io, q0, q7, expected[0], expected[7]);
                    errors = errors + 1;
                end
            end
            // Soltar o barramento e ir pra hold pra ler o que foi carregado
            @(negedge cp) begin
                io_drive = 1'b0;
                s1 = 1'b0;
                s0 = 1'b0;
                #10;
                if (io !== expected || q0 !== expected[0] || q7 !== expected[7]) begin
                    $display("leitura apos parallel load falhou: s1=%b s0=%b io=%b q0=%b q7=%b, expected io=%b q0=%b q7=%b", s1, s0, io, q0, q7, expected, expected[0], expected[7]);
                    errors = errors + 1;
                end
            end
        end

        // Shift right (S1 L, S0 H): DSR -> Q0, Q0 -> Q1 ... Q6 -> Q7
        for (i = 0; i < 16; i = i + 1) begin
            @(negedge cp) begin
                s1 = 1'b0;
                s0 = 1'b1;
                dsr = pattern[i];
            end
            @(posedge cp) begin
                expected = {expected[6:0], dsr};
                #10;
                if (io !== expected || q0 !== expected[0] || q7 !== expected[7]) begin
                    $display("shift right falhou: s1=%b s0=%b dsr=%b io=%b q0=%b q7=%b, expected io=%b q0=%b q7=%b", s1, s0, dsr, io, q0, q7, expected, expected[0], expected[7]);
                    errors = errors + 1;
                end
            end
        end

        // Shift left (S1 H, S0 L): DSL -> Q7, Q7 -> Q6 ... Q1 -> Q0
        for (i = 0; i < 16; i = i + 1) begin
            @(negedge cp) begin
                s1 = 1'b1;
                s0 = 1'b0;
                dsl = pattern[i];
            end
            @(posedge cp) begin
                expected = {dsl, expected[7:1]};
                #10;
                if (io !== expected || q0 !== expected[0] || q7 !== expected[7]) begin
                    $display("shift left falhou: s1=%b s0=%b dsl=%b io=%b q0=%b q7=%b, expected io=%b q0=%b q7=%b", s1, s0, dsl, io, q0, q7, expected, expected[0], expected[7]);
                    errors = errors + 1;
                end
            end
        end

        // Hold (S1 L, S0 L): nada muda mesmo com entradas seriais mudando e cp pulsando
        for (i = 0; i < 4; i = i + 1) begin
            @(negedge cp) begin
                s1 = 1'b0;
                s0 = 1'b0;
                dsr = ~dsr;
                dsl = ~dsl;
            end
            @(posedge cp) begin
                #10;
                if (io !== expected || q0 !== expected[0] || q7 !== expected[7]) begin
                    $display("hold falhou: s1=%b s0=%b dsr=%b dsl=%b io=%b q0=%b q7=%b, expected io=%b q0=%b q7=%b", s1, s0, dsr, dsl, io, q0, q7, expected, expected[0], expected[7]);
                    errors = errors + 1;
                end
            end
        end

        // oe1_n H: barramento em z, mas q0 e q7 continuam funcionando
        @(negedge cp) begin
            oe1_n = 1'b1;
            #10;
            if (io !== 8'bz || q0 !== expected[0] || q7 !== expected[7]) begin
                $display("oe1_n H falhou: oe1_n=%b oe2_n=%b io=%b q0=%b q7=%b, expected io=%b q0=%b q7=%b", oe1_n, oe2_n, io, q0, q7, 8'bz, expected[0], expected[7]);
                errors = errors + 1;
            end
        end
        // oe2_n H: mesma coisa
        @(negedge cp) begin
            oe1_n = 1'b0;
            oe2_n = 1'b1;
            #10;
            if (io !== 8'bz || q0 !== expected[0] || q7 !== expected[7]) begin
                $display("oe2_n H falhou: oe1_n=%b oe2_n=%b io=%b q0=%b q7=%b, expected io=%b q0=%b q7=%b", oe1_n, oe2_n, io, q0, q7, 8'bz, expected[0], expected[7]);
                errors = errors + 1;
            end
        end
        // Com o barramento desabilitado o registrador continua deslocando
        for (i = 0; i < 4; i = i + 1) begin
            @(negedge cp) begin
                s1 = 1'b0;
                s0 = 1'b1;
                dsr = 1'b1;
            end
            @(posedge cp) begin
                expected = {expected[6:0], dsr};
                #10;
                if (io !== 8'bz || q0 !== expected[0] || q7 !== expected[7]) begin
                    $display("shift right com oe2_n H falhou: oe2_n=%b s1=%b s0=%b dsr=%b io=%b q0=%b q7=%b, expected io=%b q0=%b q7=%b", oe2_n, s1, s0, dsr, io, q0, q7, 8'bz, expected[0], expected[7]);
                    errors = errors + 1;
                end
            end
        end
        // Reabilitar o barramento deve mostrar o valor deslocado enquanto estava em z
        @(negedge cp) begin
            s1 = 1'b0;
            s0 = 1'b0;
            oe2_n = 1'b0;
            #10;
            if (io !== expected) begin
                $display("io apos reabilitar oe2_n falhou: oe1_n=%b oe2_n=%b io=%b, expected %b", oe1_n, oe2_n, io, expected);
                errors = errors + 1;
            end
        end

        // Reset assincrono: tudo vai pra L sem precisar de borda do cp
        @(negedge cp) begin
            mr_n = 1'b0;
            s1 = 1'b0;
            s0 = 1'b1;
            dsr = 1'b1;
            #10;
            if (io !== 8'b0000_0000 || q0 !== 1'b0 || q7 !== 1'b0) begin
                $display("reset com mr_n L antes do cp falhou: mr_n=%b io=%b q0=%b q7=%b, expected io=%b q0=%b q7=%b", mr_n, io, q0, q7, 8'b0000_0000, 1'b0, 1'b0);
                errors = errors + 1;
            end
        end
        // Esperar ver se o posedge do cp n ta zoando
        @(posedge cp) begin
            #10;
            if (io !== 8'b0000_0000 || q0 !== 1'b0 || q7 !== 1'b0) begin
                $display("reset com mr_n L apos posedge de cp falhou: mr_n=%b s1=%b s0=%b dsr=%b io=%b q0=%b q7=%b, expected io=%b q0=%b q7=%b", mr_n, s1, s0, dsr, io, q0, q7, 8'b0000_0000, 1'b0, 1'b0);
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
