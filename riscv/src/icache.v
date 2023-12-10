`ifndef ICACHE_V
`define ICACHE_V

module Icache (
    input wire clk,
    input wire rst,
    input wire rdy,

    // IFetch
    input  wire [31:0] pc,
    output wire hit,
    output wire [31:0] inst_out,

    // Memctrl
    input  wire inst_rdy, 
    input  wire [31:0] inst_in, // from memctrl to icache
    output reg  mem_rdy // from icache to memctrl
);

    localparam `CACHE_SIZE = 256;
    localparam `INDEX_SIZE = 8;
    localparam `TAG_SIZE = 30 - `INDEX_SIZE;

    localparam `IDLE = 1'b0;
    localparam `MEM = 1'b1;

    reg                   statu;
    reg                   valid [`CACHE_SIZE - 1:0];
    reg [           31:0] data  [`CACHE_SIZE - 1:0];
    reg [`TAG_SIZE - 1:0] tag   [`CACHE_SIZE - 1:0];

    wire [`INDEX_SIZE - 1:0] index  = pc[`INDEX_SIZE + 1 : 2];
    wire [  `TAG_SIZE - 1:0] tag_in = pc[31 : `INDEX_SIZE + 2];

    assign hit = valid[index] && (tag[index] == tag_in);
    assign inst_out = hit ? data[index] : inst_in;
    integer i;

    always @(posedge clk) begin
        if (rst) begin
            statu <= `IDLE;
            for (i = 0; i < `CACHE_SIZE; i = i + 1) begin
                valid[i] <= 0;
                data[i]  <= 0;
                tag[i]   <= 0;
            end
        end else if (!rdy) begin
        end else begin
            case (statu) 
                `IDLE : begin
                    if (!hit) begin
                        statu <= `MEM;
                        mem_rdy <= 1;
                    end
                end
                `MEM : begin
                    if (inst_rdy) begin
                        statu <= `IDLE;
                        mem_rdy <= 0;
                        valid[index] <= 1;
                        tag[index] <= tag_in;
                        data[index] <= inst_in;
                    end 
                end
            endcase
        end 
    end
    
endmodule

`endif