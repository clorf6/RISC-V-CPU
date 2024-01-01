`include "const.v"

`ifndef FORWARD_V
`define FORWARD_V

module Forward (
    input wire clk,
    input wire rst,
    input wire rdy,

    // IQueue
    input wire issue_rdy,
    input wire is_vec,
    input wire [1:0]  type,
    input wire [5:0]  name,
    input wire [4:0]  rd,
    input wire [31:0] pc,
    input wire [31:0] imm,
    output reg ins_rdy,
    output wire bubble,

    // WB
    input wire wb_rdy,
    output reg rd_rdy,
    output reg is_vec_out,
    output reg [1:0]  type_out,
    output reg [5:0]  name_out,
    output reg [4:0]  rd_out,
    output reg [31:0] pc_out,
    output reg [31:0] imm_out

);

    assign bubble = (issue_rdy && (type == `MEM));

    always @(posedge clk) begin
        if (rst) begin
            ins_rdy <= 0;
        end else if (!rdy) begin
        end else begin
            rd_rdy <= issue_rdy;
            is_vec_out <= is_vec; 
            type_out <= type;
            name_out <= name;
            rd_out <= rd;
            pc_out <= pc;
            imm_out <= imm;
            if (!ins_rdy) begin
                ins_rdy <= wb_rdy;
            end else begin
                ins_rdy <= !bubble;
            end
        end
    end

endmodule

`endif 