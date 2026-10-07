module ic_74HC283 (
    input [3:0] a,  // word A: a[0] = A1 (LSB) ... a[3] = A4
    input [3:0] b,  // word B: b[0] = B1 (LSB) ... b[3] = B4
    input cin,      // carry in
    output [3:0] s, // soma: s[0] = S1 (LSB) ... s[3] = S4
    output cout     // carry out
);
    assign {cout, s} = a + b + cin;
endmodule