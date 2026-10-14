module ic_74HC20 (
    input a1, b1, c1, d1,
    input a2, b2, c2, d2,
    output y1, y2
);
    assign y1 = ~(a1&b1&c1&d1);
    assign y2 = ~(a2&b2&c2&d2);
endmodule