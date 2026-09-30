module ic_74HC245 (
    input dir,
    input oe,
    inout [7:0] a, b
);
    assign b = (~oe & dir) ? a : 8'bzzzz_zzzz;
    assign a = (~oe & ~dir) ? b : 8'bzzzz_zzzz;
endmodule