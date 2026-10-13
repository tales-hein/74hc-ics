module ic_74HC193 (
    input mr,       // Master reset assincrono (active high)
    input pl_n,     // Parallel load assincrono (active low)
    input cpu,      // Clock count up
    input cpd,      // Clock count down
    input [3:0] d,  // Data inputs
    output [3:0] q, // Outputs
    output tcu_n,   // Terminal count up / carry (active low)
    output tcd_n    // Terminal count down / borrow (active low)
);
    wire [3:0] count_up;
    wire [3:0] count_down;

    reg ff0 = 1'b0;
    wire ff0_sd = ~(d[0] & ~pl_n & ~mr); 
    wire ff0_rd = (~(ff0_sd & ~pl_n)) | mr;
    assign count_up[0] = ~cpu;
    assign count_down[0] = ~cpd;
    wire ff0_toggle = ~(count_up[0] | count_down[0]);
    always @(posedge ff0_toggle or negedge ff0_rd or negedge ff0_sd or posedge mr) begin
        if (mr) begin
            ff0 <= 1'b0;
        end else if (~ff0_sd) begin
            ff0 <= 1'b1;
        end else if(~ff0_rd) begin
            ff0 <= 1'b0;
        end else begin
            ff0 <= ~ff0;
        end
    end

    reg ff1 = 1'b0;
    wire ff1_sd = ~(d[1] & ~pl_n & ~mr); 
    wire ff1_rd = (~(ff1_sd & ~pl_n)) | mr;
    assign count_up[1] = count_up[0] & ff0;
    assign count_down[1] = count_down[0] & ~ff0;
    wire ff1_toggle = ~(count_up[1] | count_down[1]);
    always @(posedge ff1_toggle or negedge ff1_rd or negedge ff1_sd or posedge mr) begin
        if (mr) begin
            ff1 <= 1'b0;
        end else if (~ff1_sd) begin
            ff1 <= 1'b1;
        end else if(~ff1_rd) begin
            ff1 <= 1'b0;
        end else begin
            ff1 <= ~ff1;
        end
    end

    reg ff2 = 1'b0;
    wire ff2_sd = ~(d[2] & ~pl_n & ~mr); 
    wire ff2_rd = (~(ff2_sd & ~pl_n)) | mr;
    assign count_up[2] = count_up[1] & ff1;
    assign count_down[2] = count_down[1] & ~ff1;
    wire ff2_toggle = ~(count_up[2] | count_down[2]);
    always @(posedge ff2_toggle or negedge ff2_rd or negedge ff2_sd or posedge mr) begin
        if (mr) begin
            ff2 <= 1'b0;
        end else if (~ff2_sd) begin
            ff2 <= 1'b1;
        end else if(~ff2_rd) begin
            ff2 <= 1'b0;
        end else begin
            ff2 <= ~ff2;
        end
    end

    reg ff3 = 1'b0;
    wire ff3_sd = ~(d[3] & ~pl_n & ~mr); 
    wire ff3_rd = (~(ff3_sd & ~pl_n)) | mr;
    assign count_up[3] = count_up[2] & ff2;
    assign count_down[3] = count_down[2] & ~ff2;
    wire ff3_toggle = ~(count_up[3] | count_down[3]);
    always @(posedge ff3_toggle or negedge ff3_rd or negedge ff3_sd or posedge mr) begin
        if (mr) begin
            ff3 <= 1'b0;
        end else if (~ff3_sd) begin
            ff3 <= 1'b1;
        end else if(~ff3_rd) begin
            ff3 <= 1'b0;
        end else begin
            ff3 <= ~ff3;
        end
    end

    assign q = {ff3, ff2, ff1, ff0};
    assign tcu_n = ~(ff3 & ff2 & ff1 & ff0 & ~cpu);
    assign tcd_n = ~(~ff3 & ~ff2 & ~ff1 & ~ff0 & ~cpd);
endmodule