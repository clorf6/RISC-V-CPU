
`ifndef ICACHE_V
`define ICACHE_V

module Icache (
    input wire clk,
    input wire rst,
    input wire rdy,

    input  wire [31:0] inst_addr,
    output wire [31:0] inst_out,
    output wire hit,

    input wire inst_rdy,
    input wire [31:0] inst_in,
);

localparam `CACHE_SIZE = 256;
localparam `INDEX_SIZE = 8;
localparam `TAG_SIZE = 30 - `INDEX_SIZE;

reg                   valid [`CACHE_SIZE - 1:0];
reg [           31:0] data  [`CACHE_SIZE - 1:0];
reg [`TAG_SIZE - 1:0] tag   [`CACHE_SIZE - 1:0];

wire [`INDEX_SIZE - 1:0] index  = inst_addr[`INDEX_SIZE + 1 : 2];
wire [  `TAG_SIZE - 1:0] tag_in = inst_addr[31 : `INDEX_SIZE + 2];

assign hit = valid[index] && (tag[index] == tag_in);
assign inst_out = data[index];

integer i;

always @(posedge clk) begin
    if (rst) begin
        for (i = 0; i < `CACHE_SIZE; i = i + 1) begin
            valid[i] <= 0;
            data[i]  <= 0;
            tag[i]   <= 0;
        end
    end else if (rdy && inst_rdy) begin
        valid[index] <= 1;
        data[index]  <= inst_in;
        tag[index]   <= tag_in;
    end

`endif