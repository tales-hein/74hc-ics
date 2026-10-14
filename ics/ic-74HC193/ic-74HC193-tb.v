`timescale 1ns/1ps
module tb;
    reg mr;             // Master reset assincrono (active high)
    reg pl_n;           // Parallel load assincrono (active low)
    reg cpu;            // Clock count up
    reg cpd;            // Clock count down
    reg [3:0] d;        // Data inputs
    wire [3:0] q;       // Outputs
    wire tcu_n;         // Terminal count up / carry (active low)
    wire tcd_n;         // Terminal count down / borrow (active low)
    reg [3:0] expected; // Contagem esperada
    integer i;
    integer errors;

    //Instanciar module sob teste
    ic_74HC193 dut(
        .mr(mr),
        .pl_n(pl_n),
        .cpu(cpu),
        .cpd(cpd),
        .d(d),
        .q(q),
        .tcu_n(tcu_n),
        .tcd_n(tcd_n)
    );

    // Sem clock continuo aqui: sao 2 clocks e o que nao ta contando tem que ficar H,
    // entao os pulsos em cpu e cpd sao feitos na mao

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);

        mr = 1'b1;
        pl_n = 1'b1;
        cpu = 1'b1;
        cpd = 1'b1;
        d = 4'b1111;
        errors = 0;
        #10;

        // Reset (clear): q L e com os clocks H tcu_n e tcd_n ficam H
        if (q !== 4'b0000 || tcu_n !== 1'b1 || tcd_n !== 1'b1) begin
            $display("reset com mr H falhou: mr=%b pl_n=%b q=%b tcu_n=%b tcd_n=%b, expected q=%b tcu_n=%b tcd_n=%b", mr, pl_n, q, tcu_n, tcd_n, 4'b0000, 1'b1, 1'b1);
            errors = errors + 1;
        end
        // mr prevalece sobre pl_n
        pl_n = 1'b0;
        #10;
        if (q !== 4'b0000) begin
            $display("reset com mr H e pl_n L falhou: mr=%b pl_n=%b d=%b q=%b, expected %b", mr, pl_n, d, q, 4'b0000);
            errors = errors + 1;
        end
        // q em 0 e cpd L: tcd_n vai pra L
        cpd = 1'b0;
        #10;
        if (tcd_n !== 1'b0 || tcu_n !== 1'b1) begin
            $display("reset com mr H e cpd L falhou: mr=%b cpd=%b q=%b tcu_n=%b tcd_n=%b, expected tcu_n=%b tcd_n=%b", mr, cpd, q, tcu_n, tcd_n, 1'b1, 1'b0);
            errors = errors + 1;
        end
        cpd = 1'b1;
        #10;
        // Pulsos nos clocks com mr H nao podem contar
        cpu = 1'b0;
        #10;
        cpu = 1'b1;
        #10;
        if (q !== 4'b0000 || tcu_n !== 1'b1 || tcd_n !== 1'b1) begin
            $display("reset com mr H e pulsos nos clocks falhou: mr=%b q=%b tcu_n=%b tcd_n=%b, expected q=%b tcu_n=%b tcd_n=%b", mr, q, tcu_n, tcd_n, 4'b0000, 1'b1, 1'b1);
            errors = errors + 1;
        end

        // Parallel load assincrono (pl_n ja ta L): todos os valores possiveis de d
        mr = 1'b0;
        for (i = 0; i < 16; i = i + 1) begin
            d = i;
            #10;
            if (q !== d || tcu_n !== 1'b1 || tcd_n !== 1'b1) begin
                $display("q com pl_n L falhou: pl_n=%b d=%b q=%b tcu_n=%b tcd_n=%b, expected q=%b tcu_n=%b tcd_n=%b", pl_n, d, q, tcu_n, tcd_n, d, 1'b1, 1'b1);
                errors = errors + 1;
            end
            // cpu L: tcu_n vai pra L so com q em 15 (HHHH)
            cpu = 1'b0;
            #10;
            if (tcu_n !== ~(d == 4'b1111)) begin
                $display("tcu_n com pl_n L e cpu L falhou: pl_n=%b cpu=%b q=%b tcu_n=%b, expected %b", pl_n, cpu, q, tcu_n, ~(d == 4'b1111));
                errors = errors + 1;
            end
            // Borda de cpu com pl_n L nao conta
            cpu = 1'b1;
            #10;
            if (q !== d) begin
                $display("q com pl_n L e pulso em cpu falhou: pl_n=%b d=%b q=%b, expected %b", pl_n, d, q, d);
                errors = errors + 1;
            end
            // cpd L: tcd_n vai pra L so com q em 0 (LLLL)
            cpd = 1'b0;
            #10;
            if (tcd_n !== ~(d == 4'b0000)) begin
                $display("tcd_n com pl_n L e cpd L falhou: pl_n=%b cpd=%b q=%b tcd_n=%b, expected %b", pl_n, cpd, q, tcd_n, ~(d == 4'b0000));
                errors = errors + 1;
            end
            // Borda de cpd com pl_n L nao conta
            cpd = 1'b1;
            #10;
            if (q !== d) begin
                $display("q com pl_n L e pulso em cpd falhou: pl_n=%b d=%b q=%b, expected %b", pl_n, d, q, d);
                errors = errors + 1;
            end
        end

        // Carregar 0 e soltar o pl_n pra comecar a contar
        d = 4'b0000;
        #10;
        pl_n = 1'b1;
        expected = 4'b0000;
        #10;

        // Count up: pulsos em cpu com cpd H, 2 voltas completas pra passar pelo 15 -> 0
        for (i = 0; i < 32; i = i + 1) begin
            cpu = 1'b0;
            #10;
            // tcu_n copia o cpu quando q ta em 15
            if (q !== expected || tcu_n !== ~(expected == 4'b1111)) begin
                $display("count up com cpu L falhou: cpu=%b cpd=%b q=%b tcu_n=%b, expected q=%b tcu_n=%b", cpu, cpd, q, tcu_n, expected, ~(expected == 4'b1111));
                errors = errors + 1;
            end
            cpu = 1'b1;
            expected = expected + 1;
            #10;
            if (q !== expected || tcu_n !== 1'b1 || tcd_n !== 1'b1) begin
                $display("count up falhou: cpu=%b cpd=%b q=%b tcu_n=%b tcd_n=%b, expected q=%b tcu_n=%b tcd_n=%b", cpu, cpd, q, tcu_n, tcd_n, expected, 1'b1, 1'b1);
                errors = errors + 1;
            end
        end

        // Count down: pulsos em cpd com cpu H, 2 voltas completas pra passar pelo 0 -> 15
        for (i = 0; i < 32; i = i + 1) begin
            cpd = 1'b0;
            #10;
            // tcd_n copia o cpd quando q ta em 0
            if (q !== expected || tcd_n !== ~(expected == 4'b0000)) begin
                $display("count down com cpd L falhou: cpu=%b cpd=%b q=%b tcd_n=%b, expected q=%b tcd_n=%b", cpu, cpd, q, tcd_n, expected, ~(expected == 4'b0000));
                errors = errors + 1;
            end
            cpd = 1'b1;
            expected = expected - 1;
            #10;
            if (q !== expected || tcu_n !== 1'b1 || tcd_n !== 1'b1) begin
                $display("count down falhou: cpu=%b cpd=%b q=%b tcu_n=%b tcd_n=%b, expected q=%b tcu_n=%b tcd_n=%b", cpu, cpd, q, tcu_n, tcd_n, expected, 1'b1, 1'b1);
                errors = errors + 1;
            end
        end

        // Carregar um valor conhecido com um pulso em pl_n
        d = 4'b1010;
        pl_n = 1'b0;
        #10;
        pl_n = 1'b1;
        #10;
        if (q !== 4'b1010) begin
            $display("q apos pulso em pl_n falhou: pl_n=%b d=%b q=%b, expected %b", pl_n, d, q, 4'b1010);
            errors = errors + 1;
        end

        // Reset assincrono no meio da contagem, sem precisar de borda de clock
        cpu = 1'b0;
        #10;
        mr = 1'b1;
        #10;
        if (q !== 4'b0000) begin
            $display("q com mr H no meio da contagem falhou: mr=%b cpu=%b q=%b, expected %b", mr, cpu, q, 4'b0000);
            errors = errors + 1;
        end
        // Borda de cpu com mr H nao conta
        cpu = 1'b1;
        #10;
        if (q !== 4'b0000) begin
            $display("q com mr H e borda de cpu falhou: mr=%b cpu=%b q=%b, expected %b", mr, cpu, q, 4'b0000);
            errors = errors + 1;
        end
        // Soltar o reset e contar de novo
        mr = 1'b0;
        #10;
        cpu = 1'b0;
        #10;
        cpu = 1'b1;
        #10;
        if (q !== 4'b0001) begin
            $display("q com count up apos reset falhou: mr=%b cpu=%b q=%b, expected %b", mr, cpu, q, 4'b0001);
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
