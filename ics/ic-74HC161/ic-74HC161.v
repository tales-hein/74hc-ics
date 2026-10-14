module ic_74HC161 (
    input mr_n,     // Master reset assincrono (active low)
    input cp,       // Clock
    input cep,      // Count enable
    input cet,      // Count enable carry (tambem habilita o tc)
    input pe_n,     // Parallel enable (active low), carga sincrona
    input [3:0] d,  // Data inputs
    output reg [3:0] q, // Outputs
    output tc       // Terminal count
);
    always @(posedge cp or negedge mr_n) begin
        if (~mr_n) begin
            q <= 4'b0000;
        end else begin
            if (~pe_n) begin
                q <= d;
            end else if (cep & cet) begin
                q <= q + 1;
            end
        end
    end
    assign tc = mr_n & cet & (q == 4'b1111);
endmodule