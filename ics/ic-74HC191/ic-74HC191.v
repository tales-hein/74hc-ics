module ic_74HC191 (
    input pl_n,        // Parallel load assincrono (active low)
    input u_d,         // Up/down: L conta pra cima, H conta pra baixo
    input ce_n,        // Count enable (active low)
    input cp,          // Clock
    input [3:0] d,     // Data inputs
    output tc,         // Terminal count
    output rc_n,       // Ripple clock (active low)
    output [3:0] q     // Outputs
);
    wire [3:0] count_up;
    wire [3:0] count_down;

    reg ff0 = 1'b0;
    wire ff0_sd = ~(d[0] & ~pl_n); 
    wire ff0_rd = ~(ff0_sd & ~pl_n);
    assign count_up[0] = ~ce_n & ~u_d;
    assign count_down[0] = ~ce_n & u_d;
    always @(posedge cp or negedge ff0_rd or negedge ff0_sd) begin
        if (~ff0_sd) begin
            ff0 <= 1'b1;
        end else if(~ff0_rd) begin
            ff0 <= 1'b0;
        end else if(count_up[0] | count_down[0]) begin
            ff0 <= ~ff0;
        end
    end
    
    reg ff1 = 1'b0;
    wire ff1_sd = ~(d[1] & ~pl_n); 
    wire ff1_rd = ~(ff1_sd & ~pl_n);
    assign count_up[1] = count_up[0] & ff0;
    assign count_down[1] = count_down[0] & ~ff0;
    always @(posedge cp or negedge ff1_rd or negedge ff1_sd) begin
        if (~ff1_sd) begin
            ff1 <= 1'b1;
        end else if(~ff1_rd) begin
            ff1 <= 1'b0;
        end else if(count_up[1] | count_down[1]) begin
            ff1 <= ~ff1;
        end
    end

    reg ff2 = 1'b0;
    wire ff2_sd = ~(d[2] & ~pl_n); 
    wire ff2_rd = ~(ff2_sd & ~pl_n);
    assign count_up[2] = count_up[1] & ff1;
    assign count_down[2] = count_down[1] & ~ff1;
    always @(posedge cp or negedge ff2_rd or negedge ff2_sd) begin
        if (~ff2_sd) begin
            ff2 <= 1'b1;
        end else if(~ff2_rd) begin
            ff2 <= 1'b0;
        end else if(count_up[2] | count_down[2]) begin
            ff2 <= ~ff2;
        end
    end

    reg ff3 = 1'b0;
    wire ff3_sd = ~(d[3] & ~pl_n); 
    wire ff3_rd = ~(ff3_sd & ~pl_n);
    assign count_up[3] = count_up[2] & ff2;
    assign count_down[3] = count_down[2] & ~ff2;
    always @(posedge cp or negedge ff3_rd or negedge ff3_sd) begin
        if (~ff3_sd) begin
            ff3 <= 1'b1;
        end else if(~ff3_rd) begin
            ff3 <= 1'b0;
        end else if(count_up[3] | count_down[3]) begin
            ff3 <= ~ff3;
        end
    end

    assign q = {ff3, ff2, ff1, ff0};
    assign tc = (ff0 & ff1 & ff2 & ff3 & ~u_d) | (~ff0 & ~ff1 & ~ff2 & ~ff3 & u_d);
    assign rc_n = ~(tc & ~ce_n & ~cp);
endmodule