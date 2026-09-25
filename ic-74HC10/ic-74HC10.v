module ic_74HC10 (
    input a1, b1, c1,
    input a2, b2, c2,
    input a3, b3, c3,
    output y1, y2, y3
);
    assign y1 = ~(a1&b1&c1);
    assign y2 = ~(a2&b2&c2);
    assign y3 = ~(a3&b3&c3);
endmodule