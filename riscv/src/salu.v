`ifndef SALU_V
`define SALU_V   

module SALU (
    input wire clk,
    input wire rst,
    input wire rdy,

    // IQueue
    input wire issue_rdy;
    input wire is_vec;
    input wire is_imm, // use imm as operand (not rs2)
    input wire is_pc, // use pc as operand (not rs1)
    input wire [31:0] pc,
    input wire [31:0] imm,
    input wire [5:0]  name,

    // Reg
    input wire [31:0] op1, 
    input wire [31:0] op2,

    // WB
    output reg [31:0] val
);

    wire a = is_pc ? pc : op1;
    wire b = is_imm ? imm : op2;

    always @(posedge clk) begin
        if (rst) begin
            val <= 0;
        end else if (!rdy) begin
        end else if (issue_rdy && !is_vec) begin
            case (name) 
                `ADD: 
                `LW:  
                `SW:  
                `AUIPC: 
                `JALR:
                `JAL: val <= a + b;
                `SUB: val <= a - b;
                `BEQ: val <= a == b;
                `LUI: val <= b;
            endcase
        end
    end

endmodule

`endif