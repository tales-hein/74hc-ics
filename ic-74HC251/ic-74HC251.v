module ic_74HC251 (
    input a, b, c,  // Input select
    input oe,       // Output enable active low
    input [7:0] d,  // Data inputs
    output y, w     // Outputs w é inversao do data input selecionado
);
    wire selected_input = d[{c, b, a}];
    assign y = ~oe ? selected_input : 1'bz;
    assign w = ~oe ? ~selected_input : 1'bz;
endmodule