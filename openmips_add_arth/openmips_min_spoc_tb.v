`timescale 1ns/1ps
`include "defines.v"
module openmips_min_spoc_tb();

    reg clk;
    reg rst;


    initial begin
        clk = 1'b0;
        forever begin
            #10 clk = ~clk;
        end
    end

    initial begin
        rst = `RstEnable;
        #95 rst = `RstDisable;
        #1000 $stop;
    end
    openmips_min_spoc openmips_min_spoc_0 (
        .clk(clk),
        .rst(rst)
    );
    
    // always @(posedge clk) begin
    //     $display("inst_o = %h", inst_o);
    // end

endmodule