`timescale 1ns/1ps
module tb;
    reg [1:0] oe;
    reg [7:0] a;
    wire [7:0] y;
    integer i;
    integer errors;

    //Instanciar module sob teste
    ic_74HC541 dut(
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
        for (i = 0; i < 1024; i = i + 1) begin
            {oe, a} = i;
            #10;
            case (oe)
                2'b00: if (y !== a) begin
                    $display("Buffer FALHOU: t=%0t oe=%b a=%b y=%b expected=%b",
                        $time, oe, a, y, a);
                    errors = errors + 1;
                end
                default: if (y !== 8'bz) begin
                    $display("Output enable FALHOU: t=%0t oe=%b a=%b y=%b expected=%b",
                        $time, oe, a, y, a);
                    errors = errors + 1;
                end
            endcase
        end
        if (errors == 0)
            $display("TESTES PASSARAM");
        else
            $display("%0d TESTE(S) FALHOU(FALHARAM)", errors);

        $finish;
    end
endmodule