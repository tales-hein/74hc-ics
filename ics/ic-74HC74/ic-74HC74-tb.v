`timescale 1ns/1ps
module tb;
    reg [1:0] rd;     // Reset (junto com sd controlamos operação normal, preset (isso "grava" o flip flop achei confuso n sei pq) e clear)
    reg [1:0] d;      // Data input
    reg cp;           // Clock
    reg [1:0] sd;     // Preset
    wire [1:0] q;     // Outputs
    wire [1:0] q_inv; // Outputs invertido
    integer errors;

    //Instanciar module sob teste
    ic_74HC74 dut(
        .rd(rd),
        .d(d),
        .cp(cp),
        .sd(sd),
        .q(q),
        .q_inv(q_inv)
    );

    initial cp = 0;
    always #30 cp = ~cp;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);

        rd = 2'b00;
        sd = 2'b00;
        d = 2'b00;
        errors = 0;

        // Setar rd e sd para flip flop agir com o set na borda alta
        repeat (3) @(posedge cp);
        // Validar outputs quando sd e rd são low na tabela diz ter q ser high
        if (q !== 2'b11) begin
            $display("q com sd e rd L falhou: q=%b, expected %b", q, 2'b11);
            errors = errors + 1;
        end
        if (q_inv !== 2'b11) begin
            $display("q_inv com sd e rd L falhou: q_inv=%b, expected %b", q_inv, 2'b11);
            errors = errors + 1;
        end
        // Passar pra high sd e rd para teste data in e cp
        #10;
        @(negedge cp) rd = 2'b11;
        @(negedge cp) sd = 2'b11;

        // Pulso em d para setar q high e low
        @(negedge cp) d = 2'b11;
        @(posedge cp) begin
            #5;
            if (q !== 2'b11) begin
                $display("q com d H falhou: d=%b q=%b, expected %b", d, q, 2'b11);
                errors = errors + 1;
            end
            if (q_inv !== 2'b00) begin
                $display("q_inv com d H falhou: d=%b q_inv=%b, expected %b", d, q_inv, 2'b00);
                errors = errors + 1;
            end
        end
        // Passa d pra low assim q deve ser low também
        @(negedge cp) d = 2'b00;
        @(posedge cp) begin
            #10;
            if (q !== 2'b00) begin
                $display("q com d L falhou: d=%b q=%b, expected %b", d, q, 2'b00);
                errors = errors + 1;
            end
            if (q_inv !== 2'b11) begin
                $display("q_inv com d L falhou: d=%b q_inv=%b, expected %b", d, q_inv, 2'b11);
                errors = errors + 1;
            end
        end
        // Pulso em SD para setar o flip flop H
        @(negedge cp) sd = 2'b00;
        #10;
        if (q !== 2'b11) begin
            $display("q com d L e sd L falhou: sd=%b d=%b q=%b, expected %b", sd, d, q, 2'b11);
            errors = errors + 1;
        end
        if (q_inv !== 2'b00) begin
            $display("q_inv com d L e sd L falhou: sd=%b d=%b q_inv=%b, expected %b", sd, d, q_inv, 2'b00);
            errors = errors + 1;
        end
        // esperar uns dois pulsos do clock
        repeat (2) @(posedge cp) begin
            #10;
            if (q !== 2'b11) begin
                $display("q com d L e sd L e cp pulsando falhou: sd=%b d=%b q=%b, expected %b", sd, d, q, 2'b11);
                errors = errors + 1;
            end
            if (q_inv !== 2'b00) begin
                $display("q_inv com d L e sd L e cp pulsando falhou: sd=%b d=%b q_inv=%b, expected %b", sd, d, q_inv, 2'b00);
                errors = errors + 1;
            end
        end
        // seta sd pra H a linha D deve prevalecer apenas no proximo posedge do cp
        @(negedge cp) begin
            sd = 2'b11;
            #5;
            if (q !== 2'b11) begin
                $display("q com d L e sd H antes do cp falhou: sd=%b d=%b q=%b, expected %b", sd, d, q, 2'b11);
                errors = errors + 1;
            end
            if (q_inv !== 2'b00) begin
                $display("q_inv com d L e sd H antes do cp falhou: sd=%b d=%b q_inv=%b, expected %b", sd, d, q_inv, 2'b00);
                errors = errors + 1;
            end
        end
        // Veio cp borda alta para setar q com base no d
        @(posedge cp);
        #10;
        if (q !== 2'b00) begin
            $display("q com d L e sd H falhou: sd=%b d=%b q=%b, expected %b", sd, d, q, 2'b00);
            errors = errors + 1;
        end
        if (q_inv !== 2'b11) begin
            $display("q_inv com d L e sd H falhou: sd=%b d=%b q_inv=%b, expected %b", sd, d, q_inv, 2'b11);
            errors = errors + 1;
        end
        // Setar d H e esperar um pouco e pulso em RD para resetar o flip flop L
        @(negedge cp) d = 2'b11;
        repeat (3) @(posedge cp);
        @(negedge cp) rd = 2'b00;
        #10;
        if (q !== 2'b00) begin
            $display("q com d H e rd L falhou: rd=%b d=%b q=%b, expected %b", rd, d, q, 2'b00);
            errors = errors + 1;
        end
        if (q_inv !== 2'b11) begin
            $display("q_inv com d H e rd L falhou: rd=%b d=%b q_inv=%b, expected %b", rd, d, q_inv, 2'b11);
            errors = errors + 1;
        end
        // Deixar rolar uns 2 pulsos
        repeat (2) @(posedge cp) begin
            #10;
            if (q !== 2'b00) begin
                $display("q com d H e rd L e cp pulsando falhou: rd=%b d=%b q=%b, expected %b", rd, d, q, 2'b00);
                errors = errors + 1;
            end
            if (q_inv !== 2'b11) begin
                $display("q_inv com d H e rd L e cp pulsando falhou: rd=%b d=%b q_inv=%b, expected %b", rd, d, q_inv, 2'b11);
                errors = errors + 1;
            end
        end
        // seta rd pra H a linha D deve prevalecer apenas no proximo posedge do cp
        @(negedge cp) begin
            rd = 2'b11;
            #10;
            if (q !== 2'b00) begin
                $display("q com d H e rd H antes do cp falhou: rd=%b d=%b q=%b, expected %b", rd, d, q, 2'b00);
                errors = errors + 1;
            end
            if (q_inv !== 2'b11) begin
                $display("q_inv com d H e rd H antes do cp falhou: rd=%b d=%b q_inv=%b, expected %b", rd, d, q_inv, 2'b11);
                errors = errors + 1;
            end
        end
        // Seta o flip flop com borda alta de cp
        @(posedge cp);
        #10;
        if (q !== 2'b11) begin
            $display("q com d H e rd H falhou: rd=%b d=%b q=%b, expected %b", rd, d, q, 2'b11);
            errors = errors + 1;
        end
        if (q_inv !== 2'b00) begin
            $display("q_inv com d H e rd H falhou: rd=%b d=%b q_inv=%b, expected %b", rd, d, q_inv, 2'b00);
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