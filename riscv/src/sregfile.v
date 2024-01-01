`include "const.v"

`ifndef REGFILE_V
`define REGFILE_V

module SRegfile (
    input wire clk,
    input wire rst,
    input wire rdy,

    // IQueue
    input wire issue_rdy,
    input wire [1:0] type,
    input wire [4:0] rd,
    input wire [4:0] rs1,
    input wire [4:0] rs2,
    output wire op1_rdy,
    output wire op2_rdy,

    // SALU
    output wire [31:0] op1,
    output wire [31:0] op2,

    // WB
    input wire commit_rd,
    input wire [31:0] commit_data
);

    reg        busy [31:0];
    reg [31:0] regs [31:0];

    assign now_set = issue_rdy && type == `REG;
    assign op1_rdy = busy[rs1] && rs1 != commit_rd;
    assign op2_rdy = busy[rs2] && rs2 != commit_rd;
    assign op1 = regs[rs1];
    assign op2 = regs[rs2];

    integer i;
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                regs[i] <= 0;
                busy[i] <= 0;
            end
        end else if (!rdy) begin
        end else begin
            if (now_set) begin
                busy[rd] <= 1;
            end 
            if (commit_rd) begin
                regs[commit_rd] <= commit_data;
                if (!(now_set && rd == commit_rd)) begin
                    busy[commit_rd] <= 0;
                end
            end
        end
    end
    
    always @(posedge clk) begin
    end

endmodule

`endif