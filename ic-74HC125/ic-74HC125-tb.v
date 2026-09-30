`timescale 1ns/1ps
module tb;
    reg [3:0] oe, a;
    wire [3:0] y;
    integer i, j;
    integer errors;

    //Instanciar module sob teste
    ic_74HC125 dut(
        .oe(oe),
        .a(a),
        .y(y)
    );

    // Dump das ondas para visualização
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);
    end
    
    initial begin
        errors = 0;
        for (i = 0; i < 256; i = i + 1) begin
            {oe, a} = i;
            #10;
            for (j = 0; j < 4; j = j + 1) begin
                if (oe[j] == 1'b1) begin
                    if (y[j] !== 1'bz) begin
                        $display("Buffer FALHOU: t=%0t oe=%b a=%b y=%b expected=%b",
                            $time, oe[j], a[j], y[j], 1'bz);
                        errors = errors + 1;
                    end
                end else if (y[j] !== a[j]) begin
                    $display("Output enable Buffer FALHOU: t=%0t oe=%b a=%b y=%b expected=%b",
                         $time, oe[j], a[j], y[j], a[j]);
                    errors = errors + 1;
                end
            end
        end
        if (errors == 0)
            $display("TESTES PASSARAM");
        else
            $display("%0d TESTE(S) FALHOU(FALHARAM)", errors);

        $finish;
    end
endmodule