module ic_74HC157 (
    input e,                    // Input enable active low
    input s,                    // Input select
    input [1:0] i1,             // Data input
    input [1:0] i2,             // Data input
    input [1:0] i3,             // Data input
    input [1:0] i4,             // Data input
    output reg y1, y2, y3, y4   // Output
);
    assign y1 = ~e & (s ? i1[1] : i1[0]);
    assign y2 = ~e & (s ? i2[1] : i2[0]);
    assign y3 = ~e & (s ? i3[1] : i3[0]);
    assign y4 = ~e & (s ? i4[1] : i4[0]);
endmodule