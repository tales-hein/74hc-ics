module ic_74HC541 (
    input [1:0] oe,
    input [7:0] a,
    output [7:0] y
);
    assign y = (oe == 2'b00) ? a : 8'bz;
endmodule