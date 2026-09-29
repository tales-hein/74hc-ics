module ic_74HC151 (
    input a, b, c,  // Input select
    input g,        // Input enable active low
    input [7:0] d,  // Data inputs
    output reg y, w // Outputs w é inversao do data input selecionado
);
    wire selected_input = d[{c, b, a}];
    assign y = ~g & selected_input;
    assign w = ~y;
endmodule