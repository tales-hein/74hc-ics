module ic_74HC688 (
    input e_n,     // Enable (active low)
    input [7:0] p, // Palavra P
    input [7:0] q, // Palavra Q
    output eq_n    // Saida P=Q (active low)
);
    assign eq_n = ~(e_n ? 1'b0 : p == q);
endmodule