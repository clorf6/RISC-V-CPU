`ifndef IFETCH_V
`define IFETCH_V

module IFetch (
    input wire clk,
    input wire rst,
    input wire rdy,

    // ICache
    input  wire hit,
    input  wire [31:0] inst_in,
    output reg [31:0]  pc,

    // IQueue
    input  wire iqueue_full,
    input  wire [31:0] pc_in, // for branch
    output reg  inst_rdy,
    output reg  [31:0] inst_out,
    output reg  [31:0] pc_out
);

    always @(posedge clk) begin
        if (rst) begin
            pc <= 0;
            inst_rdy <= 0;
        end else if (!rdy) begin
        end else begin
            if (iqueue_full) begin
                inst_rdy <= 0; 
            end else begin
                if (hit) begin
                    pc_out <= pc;
                    inst_rdy <= 1;
                    inst_out <= inst_in;
                    if (pc_in) begin 
                        pc <= pc_in;
                    end else if (inst_in[6:0] == 7'b1101111) begin // JAL
                        pc <= pc + {{12{inst_in[31]}}, inst_in[19:12], inst_in[20], inst_in[30:21], 1'b0};
                    end else if (inst_in[6:0] == 7'b1100011 || inst_in[6:0] == 7'b1100111) begin // JALR or BEQ
                    end else begin
                        pc <= pc + 4;
                    end
                end else begin
                    inst_rdy <= 0;
                end
            end
        end
    end

endmodule

`endif