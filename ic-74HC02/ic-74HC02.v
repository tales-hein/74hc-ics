module ic_74HC02 (
    input a1, b1,
    input a2, b2,
    input a3, b3,
    input a4, b4,
    output y1, y2, y3, y4
);
    assign y1 = ~(a1|b1);
    assign y2 = ~(a2|b2);
    assign y3 = ~(a3|b3);
    assign y4 = ~(a4|b4);
endmodule