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
    output wire ind1, 
    output wire ind2,

    // MUX
    input wire issue_rdy,
    output reg ins_rdy,
    output reg is_vec,
    output reg is_imm, // use imm as operand (not rs2)
    output reg is_pc, // use pc as operand (not rs1)
    output reg [2:0]  type,
    output reg [5:0]  name,
    output reg [4:0]  rd,
    output reg [4:0]  rs1, 
    output reg [4:0]  rs2,
    output reg [31:0] imm,
    output reg [31:0] pc_out
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

    assign ind1 = rs1;
    assign ind2 = rs2;

    always @(posedge clk) begin
        if (rst) begin
            head <= 0;
            tail <= 0;
            ins_rdy <= 0;
        end else if (!rdy) begin 

        end else begin
            if (inst_rdy) begin
                tail <= tail + 1;
                pc_que[tail] <= pc_in;
                ins_que[tail] <= inst; 
            end
            if (issue_rdy && !empty && op1_rdy && op2_rdy) begin
                pc_out <= pc_que[head];
                head <= head + 1;
                ins_rdy <= 1;
            end else begin
                ins_rdy <= 0;
            end
        end
    end

endmodule

`endif
    