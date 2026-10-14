module ic_74HC574 (
    input oe_n,
    input cp,
    input [7:0] d,
    output [7:0] q
);
    reg [7:0] f;
    always @(posedge cp) begin
        f <= d;
    end
    assign q = oe_n ? 8'bz : f;
endmodule