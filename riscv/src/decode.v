`include "const.v"

`ifndef DECODE_V
`define DECODE_V

module Decode (
    input wire [31:0] inst,
    output reg  is_vec,
    output reg  [5:0]  name,
    output wire [4:0]  rd,
    output wire [4:0]  rs1,
    output wire [4:0]  rs2,
    output reg  [31:0] imm,
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
            end
            7'b0000011: begin
                name = `LW;
                imm  = {{21{inst[31]}}, inst[30:20]};
            end
            7'b0100011: begin
                name = `SW;
                imm  = {{21{inst[31]}}, inst[30:25], inst[11:7]};
            end
            7'b1100011: begin
                name = `BEQ;
                imm  = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0}; 
            end
            7'b0110111: begin
                name = `LUI;
                imm  = {inst[31:12], 12'b0};
            end
            7'b0010111: begin
                name = `AUIPC;
                imm  = {inst[31:12], 12'b0};
            end
            7'b1101111: begin
                name = `JAL;
                imm  = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
            end
            7'b1100111: begin
                name = `JALR;
                imm  = {{21{inst[31]}}, inst[30:20]};
            end

        endcase
    end

endmodule

`endif