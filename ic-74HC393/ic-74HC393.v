module ic_74HC393 (
    input cp1, cp2,         // Clocks (HIGH-to-LOW)
    input mr1, mr2,         // Master reset assincrono (active high)
    output reg [3:0] q1, q2 // Outputs de cada contador
);
    always @(negedge cp1 or posedge mr1) begin
        if (mr1) begin
            q1 <= 4'b0000;
        end else begin
            q1 <= q1 + 1;
        end
    end
    always @(negedge cp2 or posedge mr2) begin
        if (mr2) begin
            q2 <= 4'b0000;
        end else begin
            q2 <= q2 + 1;
        end
    end
endmodule