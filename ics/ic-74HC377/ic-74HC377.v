module ic_74HC377 (
    input e_n,         // Data in enable
    input cp,
    input [7:0] d,
    output reg [7:0] q
);
    always @(posedge cp or posedge e_n) begin
        if (~e_n) begin
            q = d;
        end
    end
endmodule