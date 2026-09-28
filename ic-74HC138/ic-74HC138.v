module ic_74HC138 (
    input a0, a1, a2,                         // Address select a0 LSB
    input g0, g1, g2,                         // Strobe       g0,g1 active low
    output reg y0, y1, y2, y3, y4, y5, y6, y7 // Outputs      active low
);
    // Strobe
    wire address_enable = (~g0 & ~g1 & g2);

    // Decoder
    wire [2:0] address_code = {a2, a1, a0};
    always @(*) begin
        {y0, y1, y2, y3, y4, y5, y6, y7} = 8'b1111_1111;
        if (address_enable) begin
            case (address_code)
                3'b000: y0 = 1'b0;
                3'b001: y1 = 1'b0;
                3'b010: y2 = 1'b0;
                3'b011: y3 = 1'b0;
                3'b100: y4 = 1'b0;
                3'b101: y5 = 1'b0;
                3'b110: y6 = 1'b0;
                3'b111: y7 = 1'b0;
            endcase
        end
    end

endmodule