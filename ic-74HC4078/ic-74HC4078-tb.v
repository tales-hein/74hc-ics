`timescale 1ns/1ps
module tb;
    reg a, b, c, d, e, f, g, h; // Data inputs
    wire x;                     // Saida NOR
    wire y;                     // Saida OR
    integer i;
    integer errors;

    //Instanciar module sob teste
    ic_74HC4078 dut(
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .e(e),
        .f(f),
        .g(g),
        .h(h),
        .x(x),
        .y(y)
    );

    // Dump das ondas para visualização
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);
    end

    initial begin
        errors = 0;
        // Todas as combinações das 8 entradas
        for (i = 0; i < 256; i = i + 1) begin
            {a, b, c, d, e, f, g, h} = i;
            #10;
            // Todas L: x = H e y = L, qualquer outra combinação: x = L e y = H
            if (x !== ~(a | b | c | d | e | f | g | h)) begin
                $display("NOR FALHOU: t=%0t a=%b b=%b c=%b d=%b e=%b f=%b g=%b h=%b x=%b expected=%b",
                    $time, a, b, c, d, e, f, g, h, x, ~(a | b | c | d | e | f | g | h));
                errors = errors + 1;
            end
            if (y !== (a | b | c | d | e | f | g | h)) begin
                $display("OR FALHOU: t=%0t a=%b b=%b c=%b d=%b e=%b f=%b g=%b h=%b y=%b expected=%b",
                    $time, a, b, c, d, e, f, g, h, y, (a | b | c | d | e | f | g | h));
                errors = errors + 1;
            end
        end

        // Resultado
        if (errors == 0)
            $display("TESTES PASSARAM");
        else
            $display("%0d TESTE(S) FALHOU(FALHARAM)", errors);

        $finish;
    end
endmodule
