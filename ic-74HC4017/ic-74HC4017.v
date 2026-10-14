module ic_74HC4017 (
    input mr,       // Master reset assincrono (active high)
    input cp0,      // Clock LOW-to-HIGH (conta com cp1 L)
    input cp1,      // Clock HIGH-to-LOW (conta com cp0 H)
    output [9:0] q, // Saidas decodificadas Q0 a Q9 (so uma H por vez)
    output q5_9_n   // Carry: L nos estados 5 a 9
);
    reg [4:0] ff;
    wire clk = ~cp1 & cp0;
    always @(posedge clk or posedge mr) begin
        if (mr) begin
            ff <= 5'b00000;
        end else begin
            ff[0] <= ~ff[4];
            ff[1] <= ff[0];
            ff[2] <= (ff[0] | ff[2]) & ff[1];
            ff[3] <= ff[2];
            ff[4] <= ff[3];
        end
    end

    assign q[0] = ~(ff[0] | ff[4]);
    assign q[1] = ~(ff[1] | ~ff[0]);
    assign q[2] = ~(~ff[1] | ff[2]);
    assign q[3] = ~(ff[3] | ~ff[2]);
    assign q[4] = ~(ff[4] | ~ff[3]);
    assign q[5] = ~(~ff[0] | ~ff[4]);
    assign q[6] = ~(ff[0] | ~ff[1]);
    assign q[7] = ~(ff[1] | ~ff[2]);
    assign q[8] = ~(~ff[3] | ff[2]);
    assign q[9] = ~(ff[3] | ~ff[4]);

    assign q5_9_n = ~(|q[9:5]);
endmodule