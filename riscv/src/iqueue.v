`include "decode.v"
`include "const.v"

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
    output reg iqueue_full,

    // Reg
    input  wire op1_rdy,
    input  wire op2_rdy,
    output reg [4:0] rs1, 
    output reg [4:0] rs2,

    // Reg and Forward, ALU
    output reg issue_rdy,

    // Reg and Forward
    output reg [1:0] type, // Only type is REG need to write rd
    output reg [4:0] rd,
    
    // Forward
    input wire ins_rdy,
    input wire bubble,
    
    // Forward and ALU
    output reg is_vec,
    output reg [5:0] name,
    output reg [31:0] pc_out,
    output reg [31:0] imm,

    // ALU
    output reg is_imm, // use imm as operand (not rs2)
    output reg is_pc // use pc as operand (not rs1)
); 
    
    reg [ 3:0] head;
    reg [ 3:0] tail; 
    reg [31:0] pc_que [`QUE_SIZE - 1 : 0];
    reg [31:0] ins_que [`QUE_SIZE - 1 : 0];
    wire empty = (head == tail);
    wire full  = (head == tail + 1) || (head == tail + 2);

    wire _is_vec;
    wire _is_imm;
    wire _is_pc;
    wire [1:0] _type;
    wire [5:0] _name;
    wire [4:0] _rd;
    wire [4:0] _rs1;
    wire [4:0] _rs2;
    wire [31:0] _imm;

    Decode decode (
        .inst (ins_que[head]),
        .is_vec (_is_vec),
        .is_imm (_is_imm),
        .is_pc (_is_pc),
        .type (_type),
        .name (_name),
        .rd (_rd),
        .rs1 (_rs1),
        .rs2 (_rs2),
        .imm (_imm)
    );

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
                if (full) begin
                    iqueue_full <= 1;
                end
            end
            if (ins_rdy && !empty && !bubble) begin
                is_vec <= _is_vec;
                is_imm <= _is_imm;
                is_pc <= _is_pc;
                type <= _type;
                name <= _name;
                rd <= _rd;
                rs1 <= _rs1;
                rs2 <= _rs2;
                imm <= _imm;
                if ((_is_pc || op1_rdy) && (_is_imm || op2_rdy)) begin
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
    