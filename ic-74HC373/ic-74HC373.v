module ic_74HC373 (
    input oe_n,         // Output enable (active low)
    input le,           // Latch enable
    input [7:0] d,
    output [7:0] q
);
    reg [7:0] latch;
    always @(*) begin
        if (le) begin
            latch <= d;
        end
    end
    assign q = oe_n ? 8'bz : latch;
endmodule