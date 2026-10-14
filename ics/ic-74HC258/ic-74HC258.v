module ic_74HC258 (
    input ab,          // a/b select (active low seleciona a)
    input g,           // output enable
    input [3:0] a,     // Data input
    input [3:0] b,     // Data input 
    output [3:0] y // Outputs invertidos
);
    assign y = ~g ? ~(ab ? b : a) : 4'bzzzz;
endmodule