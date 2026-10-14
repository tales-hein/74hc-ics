`timescale 1ns/1ps
module tb;
    reg oe_n;         // Output enable (active low)
    reg cp;           // Clock
    reg [7:0] d;      // Data input
    wire [7:0] q;     // Outputs 3-state
    integer i;
    integer errors;

    //Instanciar module sob teste
    ic_74HC574 dut(
        .oe_n(oe_n),
        .cp(cp),
        .d(d),
        .q(q)
    );

    initial cp = 0;
    always #30 cp = ~cp;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);

        oe_n = 1'b0;
        d = 8'b0000_0000;
        errors = 0;

        // Load and read register: carregar todos os valores possiveis de d
        for (i = 0; i < 256; i = i + 1) begin
            @(negedge cp) d = i;
            @(posedge cp) begin
                #10;
                if (q !== d) begin
                    $display("q com oe_n L falhou: oe_n=%b d=%b q=%b, expected %b", oe_n, d, q, d);
                    errors = errors + 1;
                end
            end
        end
        // Carregar um valor conhecido
        @(negedge cp) d = 8'b1010_0101;
        @(posedge cp);
        // Mudar d sem borda do cp nao pode mudar q
        @(negedge cp) begin
            d = 8'b0101_1010;
            #10;
            if (q !== 8'b1010_0101) begin
                $display("q mudou sem posedge de cp: oe_n=%b d=%b q=%b, expected %b", oe_n, d, q, 8'b1010_0101);
                errors = errors + 1;
            end
            // Voltar d pro valor conhecido pq o proximo posedge vai carregar d
            d = 8'b1010_0101;
        end
        // Desabilitar saida, q deve ir pra z sem precisar de borda do cp
        @(negedge cp) begin
            oe_n = 1'b1;
            #10;
            if (q !== 8'bz) begin
                $display("q com oe_n H falhou: oe_n=%b d=%b q=%b, expected %b", oe_n, d, q, 8'bz);
                errors = errors + 1;
            end
        end
        // Load register and disable output: flip flop carrega mas saida continua z
        @(negedge cp) d = 8'b0011_1100;
        @(posedge cp) begin
            #10;
            if (q !== 8'bz) begin
                $display("q com oe_n H e cp pulsando falhou: oe_n=%b d=%b q=%b, expected %b", oe_n, d, q, 8'bz);
                errors = errors + 1;
            end
        end
        // Reabilitar saida deve mostrar o valor carregado enquanto estava desabilitada
        @(negedge cp) begin
            d = 8'b1111_1111;
            oe_n = 1'b0;
            #10;
            if (q !== 8'b0011_1100) begin
                $display("q apos reabilitar oe_n falhou: oe_n=%b d=%b q=%b, expected %b", oe_n, d, q, 8'b0011_1100);
                errors = errors + 1;
            end
        end
        @(posedge cp) begin
            #10;
            if (q !== 8'b1111_1111) begin
                $display("q com oe_n L apos reabilitar falhou: oe_n=%b d=%b q=%b, expected %b", oe_n, d, q, 8'b1111_1111);
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
