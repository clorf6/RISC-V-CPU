`include "const.v"

`ifndef MUX_V
`define MUX_V

module MUX (
    input wire clk,
    input wire rst,
    input wire rdy,

    // IQueue
    input wire ins_rdy,
    input wire [2:0]  type,
    input wire [4:0]  rd,
    input wire [31:0] pc,
    input wire [31:0] imm,
    output reg issue_rdy,

    // WB
    input wire wb_rdy,
    output reg rd_rdy,
    output reg [2:0]  type_out,
    output reg [4:0]  rd_out,
    output reg [31:0] pc_out,
    output reg [31:0] imm_out

);


    always @(posedge clk) begin
        if (rst) begin
            issue_rdy <= 0;
        end else if (!rdy) begin
        end else begin
            rd_rdy <= ins_rdy;
            type_out <= type;
            rd_out <= rd;
            pc_out <= pc;
            imm_out <= imm;
            if (!issue_rdy) begin
                issue_rdy <= wb_rdy;
            end else begin
                issue_rdy <= !(ins_rdy && type == `MEM);
            end
        end
    end

endmodule

`endif 