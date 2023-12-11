`include "const.v"

`ifndef DECODE_V
`define DECODE_V

module Decode (
    input wire [31:0] inst,
    output reg [5:0]  name,
    output reg [4:0]  rd,
    output reg [4:0]  rs1,
    output reg [4:0]  rs2,
    output reg [31:0] imm
);
    wire [6:0]   opcode = inst[6:0];
    wire [3:0]   funct3 = inst[14:12];
    wire [31:25] funct7 = inst[31:25];
    
    always @(*) begin
        case (opcode)
            7'b0110011: begin
                name = funct7 == 7'b0000000 ? `ADD : `SUB;
                rd   = inst[11:7];
                rs1  = inst[19:15];
                rs2  = inst[24:20];
            end
            7'b0000011: begin
                name = `LW;
                rd   = inst[11:7];
                rs1  = inst[19:15];
                imm  = {{21{inst[31]}}, inst[30:20]};
            end
            7'b0100011: begin
                name = `SW;
                rs1  = inst[19:15];
                rs2  = inst[24:20];
                imm  = {{21{inst[31]}}, inst[30:25], inst[11:7]};
            end
            7'b1100011: begin
                name = `BEQ;
                rs1  = inst[19:15];
                rs2  = inst[24:20];
                imm  = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0}; 
            end
            7'b0110111: begin
                name = `LUI;
                rd   = inst[11:7];
                imm  = {inst[31:12], 12'b0};
            end
            7'b0010111: begin
                name = `AUIPC;
                rd   = inst[11:7];
                imm  = {inst[31:12], 12'b0};
            end
            7'b1101111: begin
                name = `JAL;
                rd   = inst[11:7];
                imm  = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
            end
            7'b1100111: begin
                name = `JALR;
                rd  = inst[11:7];
                rs1 = inst[19:15];
                imm = {{21{inst[31]}}, inst[30:20]};
            end

        endcase
    end

endmodule

`endif