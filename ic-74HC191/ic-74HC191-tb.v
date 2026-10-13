`timescale 1ns/1ps
module tb;
    reg pl_n;           // Parallel load assincrono (active low)
    reg u_d;            // Up/down: L conta pra cima, H conta pra baixo
    reg ce_n;           // Count enable (active low)
    reg cp;             // Clock
    reg [3:0] d;        // Data inputs
    wire [3:0] q;       // Outputs
    wire tc;            // Terminal count
    wire rc_n;          // Ripple clock (active low)
    reg [3:0] expected; // Contagem esperada
    integer i;
    integer errors;

    //Instanciar module sob teste
    ic_74HC191 dut(
        .pl_n(pl_n),
        .u_d(u_d),
        .ce_n(ce_n),
        .cp(cp),
        .d(d),
        .q(q),
        .tc(tc),
        .rc_n(rc_n)
    );

    initial cp = 0;
    always #30 cp = ~cp;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);

        pl_n = 1'b0;
        u_d = 1'b0;
        ce_n = 1'b0;
        d = 4'b0000;
        errors = 0;

        // Parallel load assincrono, de 15 ate 0 pra ja deixar o contador zerado
        for (i = 15; i >= 0; i = i - 1) begin
            @(negedge cp) begin
                d = i;
                #10;
                if (q !== d) begin
                    $display("q com pl_n L falhou: pl_n=%b d=%b q=%b, expected %b", pl_n, d, q, d);
                    errors = errors + 1;
                end
            end
            // Carga prevalece sobre a contagem mesmo com ce_n L
            @(posedge cp) begin
                #10;
                if (q !== d) begin
                    $display("q com pl_n L e cp pulsando falhou: pl_n=%b ce_n=%b d=%b q=%b, expected %b", pl_n, ce_n, d, q, d);
                    errors = errors + 1;
                end
            end
        end
        pl_n = 1'b1;
        expected = 4'b0000;

        // Count up (u_d L): 2 voltas completas pra passar pelo 15 -> 0
        for (i = 0; i < 32; i = i + 1) begin
            // Com cp L rc_n vai pra L so no terminal count (15 contando pra cima)
            @(negedge cp) begin
                #10;
                if (rc_n !== ~(expected == 4'b1111)) begin
                    $display("rc_n com count up e cp L falhou: u_d=%b ce_n=%b q=%b rc_n=%b, expected %b", u_d, ce_n, q, rc_n, ~(expected == 4'b1111));
                    errors = errors + 1;
                end
            end
            @(posedge cp) begin
                expected = expected + 1;
                #10;
                if (q !== expected || tc !== (expected == 4'b1111) || rc_n !== 1'b1) begin
                    $display("count up falhou: u_d=%b ce_n=%b q=%b tc=%b rc_n=%b, expected q=%b tc=%b rc_n=%b", u_d, ce_n, q, tc, rc_n, expected, (expected == 4'b1111), 1'b1);
                    errors = errors + 1;
                end
            end
        end

        // u_d so pode mudar com ce_n ou cp H, aqui cp ainda ta H
        u_d = 1'b1;
        #10;
        // Contador em 0 contando pra baixo ja e terminal count
        if (tc !== (expected == 4'b0000)) begin
            $display("tc apos mudar u_d falhou: u_d=%b q=%b tc=%b, expected %b", u_d, q, tc, (expected == 4'b0000));
            errors = errors + 1;
        end

        // Count down (u_d H): 2 voltas completas pra passar pelo 0 -> 15
        for (i = 0; i < 32; i = i + 1) begin
            // Com cp L rc_n vai pra L so no terminal count (0 contando pra baixo)
            @(negedge cp) begin
                #10;
                if (rc_n !== ~(expected == 4'b0000)) begin
                    $display("rc_n com count down e cp L falhou: u_d=%b ce_n=%b q=%b rc_n=%b, expected %b", u_d, ce_n, q, rc_n, ~(expected == 4'b0000));
                    errors = errors + 1;
                end
            end
            @(posedge cp) begin
                expected = expected - 1;
                #10;
                if (q !== expected || tc !== (expected == 4'b0000) || rc_n !== 1'b1) begin
                    $display("count down falhou: u_d=%b ce_n=%b q=%b tc=%b rc_n=%b, expected q=%b tc=%b rc_n=%b", u_d, ce_n, q, tc, rc_n, expected, (expected == 4'b0000), 1'b1);
                    errors = errors + 1;
                end
            end
        end

        // ce_n so pode subir com cp H, aqui cp ainda ta H
        ce_n = 1'b1;

        // Hold: com ce_n H q nao muda e rc_n fica H mesmo no terminal count
        for (i = 0; i < 4; i = i + 1) begin
            @(negedge cp) begin
                d = ~d;
                #10;
                if (q !== expected || rc_n !== 1'b1) begin
                    $display("hold com ce_n H e cp L falhou: u_d=%b ce_n=%b q=%b rc_n=%b, expected q=%b rc_n=%b", u_d, ce_n, q, rc_n, expected, 1'b1);
                    errors = errors + 1;
                end
            end
            @(posedge cp) begin
                #10;
                // tc nao depende do ce_n
                if (q !== expected || tc !== (expected == 4'b0000) || rc_n !== 1'b1) begin
                    $display("hold com ce_n H falhou: u_d=%b ce_n=%b q=%b tc=%b rc_n=%b, expected q=%b tc=%b rc_n=%b", u_d, ce_n, q, tc, rc_n, expected, (expected == 4'b0000), 1'b1);
                    errors = errors + 1;
                end
            end
        end

        // Mudar u_d com ce_n H: 0 contando pra cima nao e terminal count, tc tem que ir pra L
        u_d = 1'b0;
        #10;
        if (tc !== 1'b0) begin
            $display("tc apos mudar u_d com ce_n H falhou: u_d=%b ce_n=%b q=%b tc=%b, expected %b", u_d, ce_n, q, tc, 1'b0);
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
