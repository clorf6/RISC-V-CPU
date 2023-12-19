`include "decode.v"

`ifndef IQUEUE_V
`define IQUEUE_V   
    
module IQueue (
    input wire clk,
    input wire rst,
    input wire rdy,

    // IFetch
    input wire inst_rdy,
    input wire [31:0] inst,
    input wire [31:0] pc_in,

    // Reg
    input  wire op1_rdy,
    input  wire op2_rdy,
    output wire [4:0] rd_ind,  // set rd's dependency
    output wire [4:0] rs1_ind, // judge whether rs have dependency
    output wire [4:0] rs2_ind,

    // Reg and Forward, ALU
    output reg issue_rdy,

    // Reg and Forward
    output reg [1:0] type, // Only type is REG need to write rd
    
    // Forward
    input wire ins_rdy,
    input wire bubble,
    output reg [4:0] rd,

    // Forward and ALU
    output reg is_vec,
    output reg [31:0] pc_out,
    output reg [31:0] imm,

    // ALU
    output reg is_imm, // use imm as operand (not rs2)
    output reg is_pc, // use pc as operand (not rs1)
    output reg [5:0] name,
    output reg [4:0] rs1, 
    output reg [4:0] rs2
);

    localparam `QUE_SIZE = 16;
    reg [ 3:0] head, tail; 
    reg [31:0] pc_que [`QUE_SIZE - 1 : 0];
    reg [31:0] ins_que [`QUE_SIZE - 1 : 0];
    wire empty = (head == tail);
    wire full  = (head == tail + 1) || (head == tail + 2);

    Decode decode (
        .inst (ins_que[head]),
        .is_vec (is_vec),
        .is_imm (is_imm),
        .is_pc (is_pc),
        .type (type),
        .name (name),
        .rd (rd),
        .rs1 (rs1),
        .rs2 (rs2),
        .imm (imm)
    );

    assign rd_ind = rd;
    assign rs1_ind = rs1;
    assign rs2_ind = rs2;

    always @(posedge clk) begin
        if (rst) begin
            head <= 0;
            tail <= 0;
            issue_rdy <= 0;
        end else if (!rdy) begin 

        end else begin
            if (inst_rdy) begin
                tail <= tail + 1;
                pc_que[tail] <= pc_in;
                ins_que[tail] <= inst; 
            end
            if (ins_rdy && !empty && !bubble) begin
                if ((is_pc || op1_rdy) && (is_imm || op2_rdy)) begin
                    pc_out <= pc_que[head];
                    head <= head + 1;
                    issue_rdy <= 1;
                end
            end else begin
                issue_rdy <= 0;
            end
        end
    end

endmodule

`endif
    