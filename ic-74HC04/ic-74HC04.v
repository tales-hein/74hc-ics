module ic_74HC04 (
    input a1, a2, a3, a4, a5, a6,
    output y1, y2, y3, y4, y5, y6
);
    assign y1 = ~a1;
    assign y2 = ~a2;
    assign y3 = ~a3;
    assign y4 = ~a4;
    assign y5 = ~a5;
    assign y6 = ~a6;
endmodule