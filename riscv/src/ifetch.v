`ifndef IFETCH_V
`define IFETCH_V

module IFetch (
    input wire clk,
    input wire rst,
    input wire rdy,

    // ICache
    input  wire hit,
    input  wire [31:0] inst_in,
    output reg  [31:0] pc,

    // IQueue
    input  wire iqueue_full,
    output reg  inst_rdy,
    output reg  [31:0] inst_out,
    output reg  [31:0] pc_out,

    // WB
    input wire br_rdy,
    input wire [31:0] nex_pc
);

    reg stall = 0;

    always @(posedge clk) begin
        if (rst) begin
            pc <= 0;
            inst_rdy <= 0;
        end else if (!rdy) begin
        end else begin
            if (iqueue_full) begin
                inst_rdy <= 0; 
            end else begin
                if (hit && (!stall)) begin
                    pc_out <= pc;
                    inst_rdy <= 1;
                    inst_out <= inst_in;
                    if (inst_in == 32'h0ff00513) begin // DONE
                        pc <= 0;
                        inst_rdy <= 0;
                        stall <= 1;
                    end else if (inst_in[6:0] == 7'b1101111) begin // JAL
                        pc <= pc + {{12{inst_in[31]}}, inst_in[19:12], inst_in[20], inst_in[30:21], 1'b0};
                    end else if (inst_in[6:0] == 7'b1100011 || inst_in[6:0] == 7'b1100111) begin // JALR or BEQ
                        if (br_rdy) begin
                            pc <= nex_pc;
                            stall <= 0;
                        end else begin
                            pc <= pc + 4;
                            stall <= 1;
                        end
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