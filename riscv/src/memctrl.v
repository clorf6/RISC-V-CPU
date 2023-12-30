`ifndef MEMCTRL_V
`define MEMCTRL_V

module Memctrl (
    input wire clk,
    input wire rst,
    input wire rdy,

    // RAM
    input wire [7:0]  data_in,
    input wire        io_buffer_full,
    output reg [7:0]  data_out,
    output reg [31:0] data_addr,
    output reg        data_wr,
     
    // ICache
    input wire inst_miss,
    input wire [31:0] pc,
    output reg inst_rdy,
    output reg [31:0] inst_out,

    // WB
    input wire [1:0]  mem_wr,
    input wire [31:0] mem_addr,
    input wire [31:0] mem_data,
    output reg mem_rdy,
    output reg [31:0] mem_out
);

    localparam `IDLE = 2'b00;
    localparam `IF = 2'b01;
    localparam `LD = 2'b10;
    localparam `ST = 2'b11;

    reg [2:0] index;
    reg [1:0] statu;

    always @(posedge clk) begin
        if (rst) begin
            data_wr <= 0;
            index <= 0;
            inst_rdy <= 0;
            mem_rdy <= 0;
            statu <= `IDLE;
        end else if (!rdy) begin
            data_wr <= 0;
        end else begin
            case (statu)
                `IDLE: begin
                    data_wr <= 0;
                    inst_rdy <= 0;
                    mem_rdy <= 0;
                    index <= 0;
                    if (mem_wr) begin
                        statu <= mem_wr;
                        data_addr <= mem_addr;
                    end else if (inst_miss) begin
                        statu <= `IF;
                        data_addr <= pc;
                    end
                end
                `IF: if (inst_miss) begin
                    case (index)
                        2'b00: inst_out[7:0]   <= data_in;
                        2'b01: inst_out[15:8]  <= data_in; 
                        2'b10: inst_out[23:16] <= data_in;
                        2'b11: inst_out[31:24] <= data_in;
                    endcase
                    if (index == 2'b11) begin
                        inst_rdy <= 1;
                        index <= 0;
                        statu <= `IDLE;
                    end else begin
                        index <= index + 1;
                        data_addr <= data_addr + 1;
                    end
                end else statu <= `IDLE;
                `LD: begin
                    case (index)
                        2'b00: mem_out[7:0]   <= data_in;
                        2'b01: mem_out[15:8]  <= data_in; 
                        2'b10: mem_out[23:16] <= data_in;
                        2'b11: mem_out[31:24] <= data_in;
                    endcase
                    if (index == 2'b11) begin
                        mem_rdy <= 1;
                        index <= 0;
                        statu <= `IDLE;
                    end else begin
                        index <= index + 1;
                        data_addr <= data_addr + 1;
                    end
                end
                `ST: begin
                    if (!io_buffer_full) begin
                        data_wr <= 1;
                        case (index)
                        2'b00: data_out[7:0]   <= mem_data;
                        2'b01: data_out[15:8]  <= mem_data; 
                        2'b10: data_out[23:16] <= mem_data;
                        2'b11: data_out[31:24] <= mem_data;
                        endcase
                        if (index == 2'b11) begin
                            mem_rdy <= 1;
                            index <= 0;
                            statu <= `IDLE;
                        end else begin
                            index <= index + 1;
                            if (index > 0) data_addr <= data_addr + 1;
                        end
                    end
                end
            endcase
        end
    end
    
endmodule

`endif
