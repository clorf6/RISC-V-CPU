`include "const.v"

`ifndef MEMCTRL_V
`define MEMCTRL_V

module Memctrl (
    input wire clk,
    input wire rst,
    input wire rdy,

    input wire [7:0] data_in,
     
    output reg [31:0] inst_out, 
    output reg        inst_rdy
);

    reg [2:0] index;
    reg [1:0] state;

    always @(posedge clk) begin
        if (rst) begin
            inst_out <= 0;
            inst_rdy <= 0;
        end else if (!rdy) begin

        end else begin
            case (state)
                `IDLE: begin
                    
                end
                `IF: begin
                    inst_out[8 * (index + 1) - 1 : 8 * index] <= data_in;
                    if (index == 3) begin
                        inst_rdy <= 1;
                        index <= 0;
                        state <= `IDLE;
                    end else begin
                        index <= index + 1;
                    end
                end
                `LD: begin

                end
                `ST: begin

                end
            endcase
        end
    end
endmodule

`endif
