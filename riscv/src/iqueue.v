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
    input wire op1_rdy,
    input wire op2_rdy,

    // ALU
    input wire alu_full,
    output reg alu_rdy,
    output reg is_vec,
    output reg [4:0]  rd,
    output reg [31:0] op1, 
    output reg [31:0] op2,
    output reg [5:0]  name,
);



endmodule

`endif
    