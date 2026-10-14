module ic_74HC165 (
    input pl_n,     // Parallel load assincrono (active low)
    input cp,       // Clock
    input ce_n,     // Clock enable (active low)
    input ds,       // Serial data input
    input [7:0] d,  // Parallel data inputs
    output q7,  // Serial output do ultimo estagio
    output q7_n // Q7 invertido
);
    reg [7:0] q = 7'b0000000;
    wire clk = ce_n | cp;
    always @(posedge clk or negedge pl_n) begin
        if (~pl_n) begin
            q <= d;
        end else begin
            q <= q << 1;
            q[0] <= ds;
        end
    end
    assign q7 = q[7];
    assign q7_n = ~q[7];
endmodule
