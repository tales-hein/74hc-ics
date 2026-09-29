module ic_74HC153 (
    input a, b,                   // Line select
    input g1, g2,                 // Input enable active low
    input c1_0, c1_1, c1_2, c1_3, // Data in
    input c2_0, c2_1, c2_2, c2_3, // Data in
    output reg y1, y2             // Output
);
    wire [1:0] line_select = {b, a};

    always @(*) begin
        case (line_select)
            2'b00: begin
                y1 = ~g1 ? c1_0 : 1'b0;
                y2 = ~g2 ? c2_0 : 1'b0;
            end
            2'b01: begin
                y1 = ~g1 ? c1_1 : 1'b0;
                y2 = ~g2 ? c2_1 : 1'b0;
            end
            2'b10: begin
                y1 = ~g1 ? c1_2 : 1'b0;
                y2 = ~g2 ? c2_2 : 1'b0;
            end
            2'b11: begin
                y1 = ~g1 ? c1_3 : 1'b0;
                y2 = ~g2 ? c2_3 : 1'b0;
            end 
            default: begin
                y2 = 1'b0;
                y1 = 1'b0;
            end 
        endcase
    end
endmodule