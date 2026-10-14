module ic_74HC273 (
    input cp,           // Clock
    input mr,           // Reset
    input [7:0] d,      // Data input
    output reg [7:0] q // Outputs
);
    always @(posedge cp or negedge mr) begin
        if (~mr) begin
            q <= 8'b0000_0000;
        end else begin
            q <= d;
        end
    end
endmodule