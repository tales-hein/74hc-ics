module ic_74HC74 (
    input [1:0] rd,    // Reset (junto com sd controlamos operação normal, preset (isso "grava" o flip flop achei confuso n sei pq) e clear)
    input [1:0] d,     // Data input
    input cp,          // Clock
    input [1:0] sd,    // Preset
    output reg [1:0] q,    // Outputs
    output reg [1:0] q_inv // Outputs invertido
);
    always @(posedge cp or negedge sd[0] or negedge rd[0]) begin
        if (~sd[0] || ~rd[0]) begin
            q[0] <= ~sd[0];
            q_inv[0] <= ~rd[0];
        end else begin
            q[0] <= d[0];
            q_inv[0] <= ~d[0];
        end
    end

    always @(posedge cp or negedge sd[1] or negedge rd[1]) begin
        if (~sd[1] || ~rd[1]) begin
            q[1] <= ~sd[1];
            q_inv[1] <= ~rd[1];
        end else begin
            q[1] <= d[1];
            q_inv[1] <= ~d[1];
        end
    end
endmodule