`include "defines.v"

module ex_mem(

	input	wire									clk,
	input wire										rst,
	
	
	input wire[`RegAddrBus]         ex_wd,
	input wire                      ex_wreg,
	input wire[`RegBus]			    ex_wdata, 	
	input wire[`RegBus]				ex_hi,
	input wire[`RegBus]				ex_lo,
	input wire						ex_whilo,
	input wire[5:0]					stall,
	input wire[`DoubleRegBus]		hilo_i,
	input wire[1:0]					cnt_i,
	input wire[`RegBus]				ex_mem_addr,
	input wire[`RegBus]				ex_reg2,
	input wire[`AluOpBus]			ex_aluop,

	output reg[`RegAddrBus]      	mem_wd,
	output reg                   	mem_wreg,
	output reg[`RegBus]			 	mem_wdata,
	output reg[`RegBus]				mem_hi,
	output reg[`RegBus]				mem_lo,
	output reg						mem_whilo,
	output reg[`DoubleRegBus]		hilo_o,
	output reg[1:0]					cnt_o,

	output reg[`RegBus]				mem_mem_addr,
	output reg[`RegBus]				mem_reg2,
	output reg[`AluOpBus]			mem_aluop
);


	always @ (posedge clk) begin
		if(rst == `RstEnable) begin
			mem_wd <= `NOPRegAddr;
			mem_wreg <= `WriteDisable;
		  mem_wdata <= `ZeroWord;	
		  mem_hi <= `ZeroWord;
		  mem_lo <= `ZeroWord;
		  mem_whilo <= `WriteDisable;
		  mem_aluop <= `EXE_NOP_OP;
		  mem_mem_addr <= `ZeroWord;
		  mem_reg2 <= `ZeroWord;
		end else if(stall[3] == `STOP && stall[4] == `NO_STOP)begin
			mem_wd <= `NOPRegAddr;
			mem_wreg <= `WriteDisable;
			mem_wdata <= `ZeroWord;	
			mem_hi <= `ZeroWord;
			mem_lo <= `ZeroWord;
			mem_whilo <= `WriteDisable;
			hilo_o <= hilo_i;
			cnt_o <= cnt_i;
			mem_mem_addr <= `ZeroWord;
			mem_reg2 <= `ZeroWord;
			mem_aluop <= `EXE_NOP_OP;
		end else if(stall[3] == `NO_STOP)begin
			mem_wd <= ex_wd;
			mem_wreg <= ex_wreg;
			mem_wdata <= ex_wdata;	
			mem_hi <= ex_hi;
			mem_lo <= ex_lo;
			mem_whilo <= ex_whilo;		
			hilo_o <= {`ZeroWord,`ZeroWord};
			cnt_o <= 2'b00;
			mem_mem_addr <= ex_mem_addr;
			mem_reg2 <= ex_reg2;
			mem_aluop <= ex_aluop;
		end   else begin
			hilo_o <= hilo_i;
			cnt_o <= cnt_i;
		end
	end      
			

endmodule