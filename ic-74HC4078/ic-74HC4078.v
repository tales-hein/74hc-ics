module ic_74HC4078 (
    input a, b, c, d,
    input e, f, g, h,
    output y, x
);
    assign y = a|b|c|d|e|f|g|h;
    assign x = ~(a|b|c|d|e|f|g|h);
endmodule