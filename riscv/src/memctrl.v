`ifndef MEMCTRL_V
`define MEMCTRL_V

module Memctrl (
    input wire clk,
    input wire rst,
    input wire rdy,

    // RAM
    input wire [7:0]  data_in,
    output reg [7:0]  data_out,
    output reg [31:0] data_addr,
    output reg        data_wr,
     
    // ICache
    input wire inst_miss,
    input wire [31:0] pc,
    output reg inst_rdy,
    output reg [31:0] inst_out
);

    localparam `IDLE = 2'b00;
    localparam `IF = 2'b01;
    localparam `LD = 2'b10;
    localparam `ST = 2'b11;

    reg [2:0] index;
    reg [1:0] state;

    always @(posedge clk) begin
        data_wr <= 0;
        if (rst) begin
            index <= 0;
            inst_rdy <= 0;
            state <= `IDLE;
        end else if (!rdy) begin
            inst_rdy <= 0;
        end else begin
            case (state)
                `IDLE: begin
                    inst_rdy <= 0;
                    if (inst_miss) begin
                        state <= `IF;
                        index <= 0;
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
                        state <= `IDLE;
                    end else begin
                        index <= index + 1;
                        data_addr <= data_addr + 1;
                    end
                end else state <= `IDLE;
                `LD: begin

                end
                `ST: begin

                end
            endcase
        end
    end
    
endmodule

`endif
