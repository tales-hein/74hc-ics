module ic_74HC139 (
    input a1, b1, a2, b2,                                     // Address select a LSB
    input g1, g2,                                             // Strobe       active low
    output reg y1_0, y1_1, y1_2, y1_3, y2_0, y2_1, y2_2, y2_3 // Outputs      active low
);
    wire [1:0] address_code1 = {b1, a1};
    wire [1:0] address_code2 = {b2, a2};
    wire [1:0] address_enable = {~g1, ~g2};

    always @(*) begin
        {y1_0, y1_1, y1_2, y1_3, y2_0, y2_1, y2_2, y2_3} = 8'b1111_1111;
        case (address_enable)
            2'b10: begin
                case (address_code1)
                    2'b00: y1_0 = 1'b0;
                    2'b01: y1_1 = 1'b0;
                    2'b10: y1_2 = 1'b0;
                    2'b11: y1_3 = 1'b0;
                endcase
            end
            2'b01: begin
                case (address_code2)
                    2'b00: y2_0 = 1'b0;
                    2'b01: y2_1 = 1'b0;
                    2'b10: y2_2 = 1'b0;
                    2'b11: y2_3 = 1'b0;
                endcase
            end
            2'b11: begin
                case (address_code1)
                    2'b00: y1_0 = 1'b0;
                    2'b01: y1_1 = 1'b0;
                    2'b10: y1_2 = 1'b0;
                    2'b11: y1_3 = 1'b0;
                endcase
                case (address_code2)
                    2'b00: y2_0 = 1'b0;
                    2'b01: y2_1 = 1'b0;
                    2'b10: y2_2 = 1'b0;
                    2'b11: y2_3 = 1'b0;
                endcase
            end
        endcase
    end

endmodule