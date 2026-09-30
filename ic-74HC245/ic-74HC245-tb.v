`timescale 1ns/1ps
module tb;
    reg dir;
    reg oe;
    reg [7:0] a_input, b_input;
    wire [7:0] a, b;
    integer i;
    integer errors;

    // Quando for inout tem que lembrar de conduzir os wires aqui a partir dos
    // regs que esses sim dá pra setar no meio do teste.
    // O TB só conduz o lado que é ENTRADA do chip; o outro fica em z
    assign a = (oe == 1'b0 && dir == 1'b1) ? a_input : 8'bz;
    assign b = (oe == 1'b0 && dir == 1'b0) ? b_input : 8'bz;

    //Instanciar module sob teste
    ic_74HC245 dut(
        .dir(dir),
        .oe(oe),
        .a(a),
        .b(b)
    );

    // Dump das ondas para visualização
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);
    end
    
    initial begin
        errors = 0;
        for (i = 0; i < 262144; i = i + 1) begin
            {dir, oe, a_input, b_input} = i;
            #10;
            if (oe == 1'b1) begin
                if ({a, b} !== 16'bz) begin
                    $display("Output enable FALHOU: t=%0t dir=%b oe=%b expected=%b",
                        $time, dir, oe, 16'bz);
                    errors = errors + 1;
                end
            end else if (dir == 1'b1) begin
                if (b !== a_input) begin
                    $display("Output A -> B FALHOU: t=%0t dir=%b oe=%b b=%b expected=%b",
                        $time, dir, oe, b, a_input);
                    errors = errors + 1;
                end
            end else if (dir == 1'b0) begin
                if (a !== b_input) begin
                    $display("Output B -> A FALHOU: t=%0t dir=%b oe=%b a=%b expected=%b",
                        $time, dir, oe, a, b_input);
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