`timescale 1ns/1ps
module tb;
    reg mr_n;           // Master reset assincrono (active low)
    reg cp;             // Clock
    reg cep;            // Count enable
    reg cet;            // Count enable carry (tambem habilita o tc)
    reg pe_n;           // Parallel enable (active low), carga sincrona
    reg [3:0] d;        // Data inputs
    wire [3:0] q;       // Outputs
    wire tc;            // Terminal count
    reg [3:0] expected; // Contagem esperada
    integer i;
    integer errors;

    //Instanciar module sob teste
    ic_74HC161 dut(
        .mr_n(mr_n),
        .cp(cp),
        .cep(cep),
        .cet(cet),
        .pe_n(pe_n),
        .d(d),
        .q(q),
        .tc(tc)
    );

    initial cp = 0;
    always #30 cp = ~cp;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);

        mr_n = 1'b0;
        cep = 1'b1;
        cet = 1'b1;
        pe_n = 1'b0;
        d = 4'b1111;
        errors = 0;

        // Reset ativo: q e tc L mesmo com carga e contagem habilitadas e cp pulsando
        repeat (2) @(posedge cp) begin
            #10;
            if (q !== 4'b0000 || tc !== 1'b0) begin
                $display("reset com mr_n L falhou: mr_n=%b pe_n=%b d=%b q=%b tc=%b, expected q=%b tc=%b", mr_n, pe_n, d, q, tc, 4'b0000, 1'b0);
                errors = errors + 1;
            end
        end

        // Parallel load: sincrono e independente de cep e cet (desligados aqui)
        @(negedge cp) begin
            mr_n = 1'b1;
            cep = 1'b0;
            cet = 1'b0;
            d = 4'b0000;   // proximo posedge ja carrega esse valor
        end
        expected = 4'b0000;
        for (i = 0; i < 16; i = i + 1) begin
            // Antes da borda q ainda tem o valor anterior
            @(negedge cp) begin
                d = ~i;
                #10;
                if (q !== expected) begin
                    $display("q com pe_n L antes do cp falhou: pe_n=%b d=%b q=%b, expected %b", pe_n, d, q, expected);
                    errors = errors + 1;
                end
            end
            @(posedge cp) begin
                expected = d;
                #10;
                // cet L: tc fica L mesmo com q em 15
                if (q !== expected || tc !== 1'b0) begin
                    $display("q com pe_n L falhou: pe_n=%b cep=%b cet=%b d=%b q=%b tc=%b, expected q=%b tc=%b", pe_n, cep, cet, d, q, tc, expected, 1'b0);
                    errors = errors + 1;
                end
            end
        end

        // Count (pe_n, cep e cet H): 31 bordas saindo de 0 passa pelo 15 -> 0 e para no 15
        @(negedge cp) begin
            pe_n = 1'b1;
            cep = 1'b1;
            cet = 1'b1;
        end
        for (i = 0; i < 31; i = i + 1) begin
            @(posedge cp) begin
                expected = expected + 1;
                #10;
                // tc H so com cet H e q em 15
                if (q !== expected || tc !== (expected == 4'b1111)) begin
                    $display("count falhou: pe_n=%b cep=%b cet=%b q=%b tc=%b, expected q=%b tc=%b", pe_n, cep, cet, q, tc, expected, (expected == 4'b1111));
                    errors = errors + 1;
                end
            end
        end

        // Hold com cep L: q nao muda e tc continua H (tc so depende do cet)
        @(negedge cp) cep = 1'b0;
        repeat (3) @(posedge cp) begin
            #10;
            if (q !== expected || tc !== 1'b1) begin
                $display("hold com cep L falhou: cep=%b cet=%b q=%b tc=%b, expected q=%b tc=%b", cep, cet, q, tc, expected, 1'b1);
                errors = errors + 1;
            end
        end

        // Hold com cet L: q nao muda e tc vai pra L
        @(negedge cp) begin
            cep = 1'b1;
            cet = 1'b0;
            #10;
            if (tc !== 1'b0) begin
                $display("tc com cet L falhou: cep=%b cet=%b q=%b tc=%b, expected %b", cep, cet, q, tc, 1'b0);
                errors = errors + 1;
            end
        end
        repeat (3) @(posedge cp) begin
            #10;
            if (q !== expected || tc !== 1'b0) begin
                $display("hold com cet L falhou: cep=%b cet=%b q=%b tc=%b, expected q=%b tc=%b", cep, cet, q, tc, expected, 1'b0);
                errors = errors + 1;
            end
        end

        // Voltar a contar: 15 -> 0
        @(negedge cp) cet = 1'b1;
        @(posedge cp) begin
            expected = expected + 1;
            #10;
            if (q !== expected || tc !== 1'b0) begin
                $display("count apos hold falhou: cep=%b cet=%b q=%b tc=%b, expected q=%b tc=%b", cep, cet, q, tc, expected, 1'b0);
                errors = errors + 1;
            end
        end

        // Contar mais um pouco pra q nao ficar em 0 antes do reset
        repeat (5) @(posedge cp);
        expected = expected + 5;

        // Reset assincrono: q vai pra L sem precisar de borda do cp
        @(negedge cp) begin
            mr_n = 1'b0;
            pe_n = 1'b0;
            d = 4'b1111;
            #10;
            if (q !== 4'b0000 || tc !== 1'b0) begin
                $display("reset com mr_n L antes do cp falhou: mr_n=%b q=%b tc=%b, expected q=%b tc=%b", mr_n, q, tc, 4'b0000, 1'b0);
                errors = errors + 1;
            end
        end
        // Esperar ver se o posedge do cp n ta zoando (reset prevalece sobre a carga)
        @(posedge cp) begin
            #10;
            if (q !== 4'b0000 || tc !== 1'b0) begin
                $display("reset com mr_n L apos posedge de cp falhou: mr_n=%b pe_n=%b d=%b q=%b tc=%b, expected q=%b tc=%b", mr_n, pe_n, d, q, tc, 4'b0000, 1'b0);
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
