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
    end

endmodule

`endif