`include "const.v"

`ifndef DECODE_V
`define DECODE_V

module Decode (
    input wire [31:0] inst,
    output reg  is_vec,
    output reg  is_imm,
    output reg  is_pc,
    output reg  [2:0]  type,
    output reg  [5:0]  name,
    output wire [4:0]  rd,
    output wire [4:0]  rs1,
    output wire [4:0]  rs2,
    output reg  [31:0] imm
);
    wire [6:0]   opcode = inst[6:0];
    wire [3:0]   funct3 = inst[14:12];
    wire [31:25] funct7 = inst[31:25];

    assign rd  = inst[11:7];
    assign rs1 = inst[19:15];
    assign rs2 = inst[24:20];
    
    always @(*) begin
        case (opcode)
            7'b0110011: begin
                name = funct7 == 7'b0000000 ? `ADD : `SUB;
                type = `REG;
            end
            7'b0000011: begin
                name = `LW;
                type = `REG;
                imm  = {{21{inst[31]}}, inst[30:20]};
                is_imm = 1;
            end
            7'b0100011: begin
                name = `SW;
                type = `MEM;
                imm  = {{21{inst[31]}}, inst[30:25], inst[11:7]};
                is_imm = 1;
            end
            7'b1100011: begin
                name = `BEQ;
                type = `BR;
                imm  = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0}; 
                is_imm = 1;
            end
            7'b0110111: begin
                name = `LUI;
                type = `REG;
                imm  = {inst[31:12], 12'b0};
                is_imm = 1;
            end
            7'b0010111: begin
                name = `AUIPC;
                type = `REG;
                imm  = {inst[31:12], 12'b0};
                is_imm = 1;
                is_pc = 1;
            end
            7'b1101111: begin
                name = `JAL;
                type = `REG;
                imm  = 4;
                is_imm = 1;
                is_pc = 1;
            end
            7'b1100111: begin
                name = `JALR;
                type = `REG;
                imm  = {{21{inst[31]}}, inst[30:20]};
                is_imm = 1;
            end

        endcase
    end

endmodule

`endif