`ifndef IFETCH_V
`define IFETCH_V

module IFetch (
    input wire clk,
    input wire rst,
    input wire rdy,

    // ICache
    input  wire hit,
    input  wire [31:0] inst_in,
    output wire [31:0] pc,

    // IQueue
    input  wire iqueue_full,
    input  wire [31:0] pc_in, // for branch
    output reg  inst_rdy,
    output reg  [31:0] inst_out,
    output reg  [31:0] pc_out,
)

    reg  [31:0] now_pc;
    assign pc = now_pc;

    always @(posedge clk) begin
        if (rst) begin
            now_pc <= 0;
            inst_rdy <= 0;
        end else if (!rdy) begin
        end else begin
            if (iqueue_full) begin
                inst_rdy <= 0; 
            end else begin
                if (hit) begin
                    pc_out <= now_pc;
                    inst_rdy <= 1;
                    inst_out <= inst_in;
                    if (pc_in) begin 
                        now_pc <= pc_in;
                    end else if (inst_in[6:0] == 7'b1101111) begin
                        now_pc <= now_pc + {{12{inst_in[31]}}, inst_in[19:12], inst_in[20], inst_in[30:21], 1'b0};
                    end else if (inst_in[6:0] == 7'b1100011 || inst_in[6:0] == 7'b1100111) begin
                    end else begin
                        now_pc <= now_pc + 4;
                    end
                end else begin
                    inst_rdy <= 0;
                end
            end
        end
    end

endmodule

`endif