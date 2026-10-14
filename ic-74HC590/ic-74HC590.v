module ic_74HC590 (
    input oe_n,         // Output enable (active low)
    input cpr,          // Clock do reg de saida
    input mrc_n,        // Master reset do contador, assincrono (active low)
    input ce_n,         // Count enable (active low)
    input cpc,          // Clock do contador
    output [7:0] q, // Saidas 3-state do registrador
    output rco_n        // Ripple carry (active low): L com o contador interno em 255
);
    reg [7:0] c;
    always @(posedge cpc or negedge mrc_n) begin
        if (~mrc_n) begin
            c <= 8'b0000_0000;
        end else if (~ce_n) begin
            c <= c + 1;
        end
    end

    reg [7:0] out;
    always @(posedge cpr) begin
        out <= c;
    end

    assign q = ~oe_n ? out : 8'bz;
    assign rco_n = ~(c == 8'b1111_1111);
endmodule