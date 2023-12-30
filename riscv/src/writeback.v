`include "const.v"

`ifndef WRITEBACK_V
`define WRITEBACK_V

module WriteBack (
    input wire clk,
    input wire rst,
    input wire rdy,

    // Forward
    input wire rd_rdy,
    input wire is_vec,
    input wire [1:0]  type,
    input wire [5:0]  name,
    input wire [4:0]  rd,
    input wire [31:0] pc,
    input wire [31:0] imm,
    output reg wb_rdy,

    // SALU
    input wire [31:0] val,

    // IFetch
    output reg br_rdy,
    output reg [31:0] pc_out,

    // SReg
    input wire [31:0] st_data,
    output reg reg_rd,
    output reg [31:0] reg_out,

    // Memctrl
    input wire mem_rdy,
    input wire [31:0] ld_data,
    output reg [1:0]  mem_wr,
    output reg [31:0] mem_addr,
    output reg [31:0] mem_data
);

    localparam `IDLE = 2'b00;
    localparam `LD   = 2'b10;
    localparam `ST   = 2'b11;

    reg [1:0] statu;

    always @(posedge clk) begin
        if (rst) begin
            br_rdy <= 0;
            reg_rdy <= 0;
            wb_rdy <= 0;
        end else if (!rdy) begin

        end else begin
            mem_wr <= statu;
            case (statu) :
                `IDLE: begin
                    if (rd_rdy) begin
                        case (type) :
                            `DONE: begin
                                $finish;
                            end
                            `REG: begin
                                reg_rd <= rd;
                                if (name == `JALR) begin
                                    br_rdy <= 1;
                                    pc_out <= val;
                                    reg_out <= pc + 4;
                                end else begin
                                    br_rdy <= 0;
                                    reg_out <= val;
                                end
                            end
                            `MEM: begin
                                br_rdy <= 0;
                                reg_rd <= 0;
                                if (name == `LW) begin
                                    statu <= `LD;
                                    mem_addr <= val;
                                end else begin
                                    statu <= `ST;
                                    mem_addr <= val;
                                    mem_data <= st_data;
                                end
                            end
                            `BR: begin
                                br_rdy <= 1;
                                pc_out <= (val ? pc + imm : pc + 4);
                                reg_rd <= 0;
                            end
                        endcase
                    end else begin
                        br_rdy <= 0;
                        reg_rdy <= 0;
                    end
                end
                `LD: begin
                    if (mem_rdy) begin
                        reg_rd <= rd;
                        reg_out <= ld_data;
                        statu <= `IDLE;
                    end
                end
                `ST: begin
                    if (mem_rdy) begin
                        statu <= `IDLE;
                    end
                end
            endcase
        end
    end

endmodule

`endif