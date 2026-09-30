module ic_74HC125 (
    input [3:0] oe, a,
    output [3:0] y
);
    assign y[0] = ~oe[0] ? a[0] : 1'bz;
    assign y[1] = ~oe[1] ? a[1] : 1'bz;
    assign y[2] = ~oe[2] ? a[2] : 1'bz;
    assign y[3] = ~oe[3] ? a[3] : 1'bz;
endmodule