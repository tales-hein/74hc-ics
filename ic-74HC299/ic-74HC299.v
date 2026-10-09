module ic_74HC299 (
    input mr_n,         // Master reset assincrono (active low)
    input cp,           // Clock
    input s0, s1,       // Mode select
    input oe1_n, oe2_n, // Output enable 3-state (active low)
    input dsr,          // Serial data shift right
    input dsl,          // Serial data shift left
    inout [7:0] io,     // Barramento I/O0 a I/O7: entrada na carga paralela, saida 3-state no resto
    output q0, q7       // Saidas seriais (nao sao 3-state)
);
    reg [7:0] ff_int;
    always @(posedge cp or negedge mr_n) begin
        if (~mr_n) begin
            ff_int <= 8'b0000_0000;
        end else begin
            if (s0 & s1) begin
                ff_int <= io;
            end else if (s0) begin
                ff_int <= ff_int << 1;
                ff_int[0] <= dsr;
            end else if (s1) begin
                ff_int <= ff_int >> 1;
                ff_int[7] <= dsl;
            end
        end
    end
    assign q0 = ff_int[0];
    assign q7 = ff_int[7];
    assign io = ((~oe1_n & ~oe2_n) & ~(s0 & s1)) ? ff_int : 8'bz;
endmodule