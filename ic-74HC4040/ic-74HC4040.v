module ic_74HC4040 (
    input cp,       // Clock (HIGH-to-LOW)
    input mr,       // Master reset assincrono (active high)
    output reg [11:0] q // Outputs Q0 a Q11
);
    always @(negedge cp or posedge mr) begin
        if (mr) begin
            q <= 12'b0000_0000_0000;
        end else begin
            q <= q + 1;
        end
    end
endmodule