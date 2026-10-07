module ic_74HC85 (
    input [3:0] a,               // Palavra A (a[3] MSB)
    input [3:0] b,               // Palavra B (b[3] MSB)
    input i_gt, i_eq, i_lt,      // Entradas de cascata IA>B, IA=B, IA<B
    output reg q_gt, q_lt, q_eq  // Saidas QA>B, QA=B, QA<B
);
    always @(*) begin
        if (a == b) begin
            casez ({i_gt, i_lt, i_eq})
                3'b100: {q_gt, q_lt, q_eq} = 3'b100;
                3'b010: {q_gt, q_lt, q_eq} = 3'b010;
                3'b001: {q_gt, q_lt, q_eq} = 3'b001;
                3'bzz1: {q_gt, q_lt, q_eq} = 3'b001;
                3'b110: {q_gt, q_lt, q_eq} = 3'b000;
                3'b000: {q_gt, q_lt, q_eq} = 3'b110;
                default: {q_gt, q_lt, q_eq} = 3'b000;
            endcase
        end else begin
            q_eq = 1'b0;
            q_gt = a>b;
            q_lt = a<b;
        end
    end
endmodule