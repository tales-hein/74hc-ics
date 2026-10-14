`timescale 1ns/1ps
module tb;
    reg [3:0] a;        // Operando A: a[0] = A1 (LSB) ... a[3] = A4
    reg [3:0] b;        // Operando B: b[0] = B1 (LSB) ... b[3] = B4
    reg cin;            // Carry in
    wire [3:0] s;       // Soma: s[0] = S1 (LSB) ... s[3] = S4
    wire cout;          // Carry out
    reg [4:0] expected; // {cout, s} esperado
    integer i;
    integer errors;

    //Instanciar module sob teste
    ic_74HC283 dut(
        .a(a),
        .b(b),
        .cin(cin),
        .s(s),
        .cout(cout)
    );

    // Dump das ondas para visualização
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);
    end

    initial begin
        errors = 0;
        // Todas as combinações de a, b e carry in
        for (i = 0; i < 512; i = i + 1) begin
            {cin, a, b} = i;
            #10;
            expected = a + b + cin;
            if ({cout, s} !== expected) begin
                $display("Soma FALHOU: t=%0t a=%b b=%b cin=%b --- OUTPUT: cout=%b s=%b expected cout=%b s=%b",
                    $time, a, b, cin, cout, s, expected[4], expected[3:0]);
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
