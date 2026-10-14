
`timescale 1ns/1ps
module tb;
    reg e;                // Input enable active low
    reg s;                // Input select
    reg [1:0] i1;         // Data input
    reg [1:0] i2;         // Data input
    reg [1:0] i3;         // Data input
    reg [1:0] i4;         // Data input
    wire y1, y2, y3, y4;   // Output
    integer i;
    integer errors;

    //Instanciar module sob teste
    ic_74HC157 dut(
        .e(e),
        .s(s),
        .i1(i1),
        .i2(i2),
        .i3(i3),
        .i4(i4),
        .y1(y1),
        .y2(y2),
        .y3(y3),
        .y4(y4)
    );

    // Dump das ondas para visualização
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);
    end

    initial begin
        errors = 0;
        for (i = 0; i < 1024; i = i + 1) begin
            {e, s, i1, i2, i3, i4} = i;
            #10;

            if (e == 1'b1 && (y1 !== 1'b0 || y2 !== 1'b0 || y3 !== 1'b0 || y4 !== 1'b0)) begin
                $display("FALHOU l.41: t=%0t e=%b s=%b i1[0]=%b i1[1]=%b i2[0]=%b i2[1]=%b i3[0]=%b i3[1]=%b i4[0]=%b i4[1]=%b --- OUTPUT: y1=%b y2=%b y3=%b y4=%b",
                    $time, e, s, i1[0], i1[1], i2[0], i2[1], i3[0], i3[1], i4[0], i4[1], y1, y2, y3, y4);
                errors = errors + 1;
            end

            if (e == 1'b0) begin
                case (s)
                    1'b0: if (y1 !== i1[0] || y2 !== i2[0] || y3 !== i3[0] || y4 !== i4[0]) begin
                        $display("FALHOU l.49: t=%0t e=%b s=%b i1[0]=%b i1[1]=%b i2[0]=%b i2[1]=%b i3[0]=%b i3[1]=%b i4[0]=%b i4[1]=%b --- OUTPUT: y1=%b y2=%b y3=%b y4=%b",
                            $time, e, s, i1[0], i1[1], i2[0], i2[1], i3[0], i3[1], i4[0], i4[1], y1, y2, y3, y4);
                        errors = errors + 1;
                    end
                    1'b1: if (y1 !== i1[1] || y2 !== i2[1] || y3 !== i3[1] || y4 !== i4[1]) begin
                        $display("FALHOU l.54: t=%0t e=%b s=%b i1[0]=%b i1[1]=%b i2[0]=%b i2[1]=%b i3[0]=%b i3[1]=%b i4[0]=%b i4[1]=%b --- OUTPUT: y1=%b y2=%b y3=%b y4=%b",
                            $time, e, s, i1[0], i1[1], i2[0], i2[1], i3[0], i3[1], i4[0], i4[1], y1, y2, y3, y4);
                        errors = errors + 1;
                    end
                endcase
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