module ic_74HC194 (
    input mr_n,     // Master reset assincrono (active low)
    input cp,       // Clock
    input s0, s1,   // Mode select
    input dsr,      // Serial data shift right
    input dsl,      // Serial data shift left
    input [3:0] d,  // Parallel data inputs
    output reg [3:0] q  // Outputs
);
    always @(posedge cp or negedge mr_n) begin
        if (~mr_n) begin
            q <= 4'b0000;
        end else begin
            if (s0 & s1) begin
                q <= d;
            end else if (s0) begin
                q <= q << 1;
                q[0] <= dsr;
            end else if (s1) begin
                q <= q >> 1;
                q[3] <= dsl;
            end
        end
    end
endmodule