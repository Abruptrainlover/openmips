`include "defines.v"
module cp0_reg (
    input wire clk,
    input wire rst,
    
    input wire we_i,
    input wire [4:0] waddr_i,
    input wire [4:0] raddr_i,
    input wire [`RegBus] data_i,

    input wire [5:0] int_i,

    output reg [`RegBus] data_o,
    output reg [`RegBus] count_o,
    output reg [`RegBus] compare_o,
    output reg [`RegBus] status_o,
    output reg [`RegBus] cause_o,
    output reg [`RegBus] epc_o,
    output reg [`RegBus] config_o,
    output reg [`RegBus] prid_o,
    output reg  timer_int_o
);
    always @(posedge clk) begin
        if(rst == `RstEnable) begin
            data_o <= `ZeroWord;
            count_o <= `ZeroWord;
            compare_o <= `ZeroWord;
            status_o <= `ZeroWord;
            cause_o <= `ZeroWord;
            epc_o <= `ZeroWord;
            config_o <= 32'b00000000000000001000000000000000;
            prid_o <= 32'b00000000010011000000000100000010;
            timer_int_o <= `In;
        end
        else begin
            if(we_i == 1) begin
                case(waddr_i)
                    5'b00000: data_o <= data_i;
                    5'b00001: count_o <= data_i;
                    5'b00010: compare_o <= data_i;
                    5'b00011: status_o <= data_i;
                    5'b00100: cause_o <= data_i;
                    5'b00101: epc_o <= data_i;
                    5'b00110: config_o <= data_i;
                    5'b00111: prid_o <= data_i;
                    default: data_o <= data_o;
                endcase
            end
            else begin
                case(raddr_i)
                    5'b00000: data_o <= data_o;
                    5'b00001: data_o <= count_o;
                    5'b00010: data_o <= compare_o;
                    5'b00011: data_o <= status_o;
                    5'b00100: data_o <= cause_o;
                    5'b00101: data_o <= epc_o;
                    5'b00110: data_o <= config_o;
                    5'b00111: data_o <= prid_o;
                    default: data_o <= data_o;
                endcase
            end
        end
    end
endmodule