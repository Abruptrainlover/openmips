
`include "defines.v"

module openmips(

	input	wire									clk,
	input wire										rst,
	
 
	input wire[`InstBus]            rom_data_i,
	output wire[`InstAddrBus]           rom_addr_o,
	output wire                    rom_ce_o,
	
	input wire[`DataBus]            ram_data_i,
	output wire[`DataBus]           ram_data_o,
	output wire[`DataAddrBus]       ram_addr_o,
	output wire                    ram_we_o,
	output wire                    ram_ce_o,
	output wire[3:0]               ram_sel_o
);
	wire branch_flag;
	wire[`RegBus] branch_addr;

	//if_id output id input
	wire[`InstAddrBus] pc;
	wire[`InstAddrBus] id_pc_i;
	wire[`InstBus] id_inst_i;
	wire is_in_delayslot;

	//id output id/ex input
	wire[`AluOpBus] id_aluop_o;
	wire[`AluSelBus] id_alusel_o;
	wire[`RegBus] id_reg1_o;
	wire[`RegBus] id_reg2_o;
	wire id_wreg_o;
	wire[`RegAddrBus] id_wd_o;

	wire next_inst_in_delayslot;
	wire[`RegBus] id_link_addr;
	wire id_is_in_delayslot;
	wire [`RegBus] inst;

	//id/ex output  ex input 
	wire[`AluOpBus] ex_aluop_i;
	wire[`AluSelBus] ex_alusel_i;
	wire[`RegBus] ex_reg1_i;
	wire[`RegBus] ex_reg2_i;
	wire ex_wreg_i;
	wire[`RegAddrBus] ex_wd_i;
	wire[`RegBus]		hi_i;
	wire[`RegBus]		lo_i;
	wire[`RegBus]		wb_hi_i;
	wire[`RegBus]		wb_lo_i;
	wire				wb_whilo_i;

	wire[`DoubleRegBus] ex_hilo_i;
	wire[1:0] ex_cnt_i;
	
	wire ex_is_in_delayslot;
	wire[`RegBus] ex_link_addr;
	wire[`RegBus] ex_inst;
	//ex output  ex/mem input
	wire ex_wreg_o;
	wire[`RegAddrBus] ex_wd_o;
	wire[`RegBus] ex_wdata_o;
	wire[`RegBus] hi_o;
	wire[`RegBus] lo_o;
	wire  whilo_o;	

	wire[`DoubleRegBus] ex_hilo_o;
	wire[1:0] ex_cnt_o;
	wire[`AluOpBus] ex_aluop_o;
	wire[`RegBus] ex_reg2_o;
	wire[`RegBus] mem_addr_o;
	//ex/mem output mem input
	wire mem_wreg_i;
	wire[`RegAddrBus] mem_wd_i;
	wire[`RegBus] mem_wdata_i;
	wire[`RegBus] mem_hi;
	wire[`RegBus] mem_lo;
	wire  mem_whilo;
	wire[`RegBus] mem_reg2;
	wire[`AluOpBus] mem_aluop;
	wire[`RegBus] mem_addr;

	//mem output mem/wb input
	wire mem_wreg_o;
	wire[`RegAddrBus] mem_wd_o;
	wire[`RegBus] mem_wdata_o;
	wire[`RegBus] mem_hi_o;
	wire[`RegBus] mem_lo_o;
	wire		mem_whilo_o;

	//wb input 
	wire wb_wreg_i;
	wire[`RegAddrBus] wb_wd_i;
	wire[`RegBus] wb_wdata_i;
	wire[`RegBus] wb_hi;
	wire[`RegBus] wb_lo;
	wire			wb_whilo;
	//ctrl
	wire stall_from_ex;
	wire stall_from_id;
	wire[5:0]	stall;
	//div
	wire signed_div;
	wire[`RegBus] div_opdata1;
	wire[`RegBus] div_opdata2;
	wire div_start;
	wire[`DoubleRegBus] div_result;
	wire div_ready;

  wire reg1_read;
  wire reg2_read;
  wire[`RegBus] reg1_data;
  wire[`RegBus] reg2_data;
  wire[`RegAddrBus] reg1_addr;
  wire[`RegAddrBus] reg2_addr;
  wire[`RegBus] hi;
  wire[`RegBus] lo;
   
	pc_reg pc_reg0(
		.clk(clk),
		.rst(rst),
		.stall(stall),
		.pc(pc),
		.ce(rom_ce_o),
		.branch_flag_i(branch_flag),
		.branch_addr_i(branch_addr)
	);
	
  assign rom_addr_o = pc;

   
	if_id if_id0(
		.clk(clk),
		.rst(rst),
		.stall(stall),
		.if_pc(pc),
		.if_inst(rom_data_i),
		.id_pc(id_pc_i),
		.id_inst(id_inst_i)      	
	);
	
	 
	id id0(
		.rst(rst),
		.pc_i(id_pc_i),
		.inst_i(id_inst_i),

		.reg1_data_i(reg1_data),
		.reg2_data_i(reg2_data),
		.ex_wreg_i(ex_wreg_o),
		.ex_wdata_i(ex_wdata_o),
		.ex_wd_i(ex_wd_o),

		.mem_wreg_i(mem_wreg_o),
		.mem_wdata_i(mem_wdata_o),
		.mem_wd_i(mem_wd_o),
		.is_in_delayslot_i(is_in_delayslot),

		.reg1_read_o(reg1_read),
		.reg2_read_o(reg2_read), 	  

		.reg1_addr_o(reg1_addr),
		.reg2_addr_o(reg2_addr), 
	  
		 
		.aluop_o(id_aluop_o),
		.alusel_o(id_alusel_o),
		.reg1_o(id_reg1_o),
		.reg2_o(id_reg2_o),
		.wd_o(id_wd_o),
		.wreg_o(id_wreg_o),
		.stallreq(stall_from_id),
		.link_addr_o(id_link_addr),
		.is_in_delayslot_o(id_is_in_delayslot),
		.next_inst_in_delayslot_o(next_inst_in_delayslot),
		.branch_flag_o(branch_flag),
		.branch_addr_o(branch_addr),
		.inst_o(inst)
	);

   
	regfile regfile1(
		.clk (clk),
		.rst (rst),
		.we	(wb_wreg_i),
		.waddr (wb_wd_i),
		.wdata (wb_wdata_i),
		.re1 (reg1_read),
		.raddr1 (reg1_addr),
		.rdata1 (reg1_data),
		.re2 (reg2_read),
		.raddr2 (reg2_addr),
		.rdata2 (reg2_data)
	);

	 
	id_ex id_ex0(
		.clk(clk),
		.rst(rst),
		
		 
		.id_aluop(id_aluop_o),
		.id_alusel(id_alusel_o),
		.id_reg1(id_reg1_o),
		.id_reg2(id_reg2_o),
		.id_wd(id_wd_o),
		.id_wreg(id_wreg_o),
		.stall(stall),
		.id_link_addr(id_link_addr),
		.id_is_in_delayslot(id_is_in_delayslot),
		.next_inst_delayslot_i(next_inst_in_delayslot),
		.id_inst(inst),

		.ex_aluop(ex_aluop_i),
		.ex_alusel(ex_alusel_i),
		.ex_reg1(ex_reg1_i),
		.ex_reg2(ex_reg2_i),
		.ex_wd(ex_wd_i),
		.ex_wreg(ex_wreg_i),
		.is_in_delayslot_o(is_in_delayslot),
		.ex_link_addr(ex_link_addr),
		.ex_is_in_delayslot(ex_is_in_delayslot),
		.ex_inst(ex_inst)
	);		
	
	 
	ex ex0(
		.rst(rst),
	
		 
		.aluop_i(ex_aluop_i),
		.alusel_i(ex_alusel_i),
		.reg1_i(ex_reg1_i),
		.reg2_i(ex_reg2_i),
		.wd_i(ex_wd_i),
		.wreg_i(ex_wreg_i),
	  	.hi_i(hi_i),
		.lo_i(lo_i),
		.wb_hi_i(wb_hi),
		.wb_lo_i(wb_lo),
		.wb_whilo_i(wb_whilo),
	   	.mem_hi_i(mem_hi_o),
		.mem_lo_i(mem_lo_o),
		.mem_whilo_i(mem_whilo_o),
		.hilo_temp_i(ex_hilo_i),
		.cnt_i(ex_cnt_i),

		.div_result_i(div_result),
		.div_ready_i(div_ready),
		
		.is_in_delayslot_i(ex_is_in_delayslot),
		.link_addr_i(ex_link_addr),
		.inst_i(ex_inst),

		.wd_o(ex_wd_o),
		.wreg_o(ex_wreg_o),
		.wdata_o(ex_wdata_o),
		.hi_o(hi_o),
		.lo_o(lo_o),
		.whilo_o(whilo_o),
		.hilo_temp_o(ex_hilo_o),
		.cnt_o(ex_cnt_o),
		.stallreq(stall_from_ex),
		
		.div_opdata1_o(div_opdata1),
		.div_opdata2_o(div_opdata2),
		.div_start_o(div_start),
		.signed_div_o(signed_div),

		.mem_addr_o(mem_addr_o),
		.reg2_o(ex_reg2_o),
		.aluop_o(ex_aluop_o)

	);

   
  ex_mem ex_mem0(
		.clk(clk),
		.rst(rst),
	  
		 
		.ex_wd(ex_wd_o),
		.ex_wreg(ex_wreg_o),
		.ex_wdata(ex_wdata_o),
		.ex_whilo(whilo_o),
		.ex_lo(lo_o),
		.ex_hi(hi_o),
		.stall(stall),
		.hilo_i(ex_hilo_o),
		.cnt_i(ex_cnt_o),
		.ex_aluop(ex_aluop_o),
		.ex_reg2(ex_reg2_o),
		.ex_mem_addr(mem_addr_o),

		.mem_wd(mem_wd_i),
		.mem_wreg(mem_wreg_i),
		.mem_wdata(mem_wdata_i),
		.mem_hi(mem_hi),
		.mem_lo(mem_lo),
		.mem_whilo(mem_whilo),
		.hilo_o(ex_hilo_i),
		.cnt_o(ex_cnt_i),
		.mem_mem_addr(mem_addr),
		.mem_reg2(mem_reg2),
		.mem_aluop(mem_aluop)

	);
	
   
	mem mem0(
		.rst(rst),
	
		 
		.wd_i(mem_wd_i),
		.wreg_i(mem_wreg_i),
		.wdata_i(mem_wdata_i),
	  	.whilo_i(mem_whilo),
		.hi_i(mem_hi),
		.lo_i(mem_lo),


		.aluop_i(mem_aluop),
		.reg2_i(mem_reg2),
		.mem_addr_i(mem_addr),
		.mem_data_i(ram_data_i),

		.wd_o(mem_wd_o),
		.wreg_o(mem_wreg_o),
		.wdata_o(mem_wdata_o),
		.whilo_o(mem_whilo_o),
		.hi_o(mem_hi_o),
		.lo_o(mem_lo_o),

		.mem_addr_o(ram_addr_o),
		.mem_data_o(ram_data_o),
		.mem_we_o(ram_we_o),
		.mem_sel_o(ram_sel_o),
		.mem_ce_o(ram_ce_o)
	);

   
	mem_wb mem_wb0(
		.clk(clk),
		.rst(rst),

		 
		.mem_wd(mem_wd_o),
		.mem_wreg(mem_wreg_o),
		.mem_wdata(mem_wdata_o),
		.mem_whilo(mem_whilo_o),
		.mem_hi(mem_hi_o),
		.mem_lo(mem_lo_o),
		.stall(stall),

		.wb_wd(wb_wd_i),
		.wb_wreg(wb_wreg_i),
		.wb_wdata(wb_wdata_i),
		.wb_whilo(wb_whilo),
		.wb_hi(wb_hi),
		.wb_lo(wb_lo)							       	
	);

	hilo_reg hili_reg0(
		.rst(rst),
		.clk(clk),

		.we(wb_whilo),
		.hi_i(wb_hi),
		.lo_i(wb_lo),

		.hi_o(hi),
		.lo_o(lo)
	);
	ctrl ctrl0(
		.rst(rst),
		.stall_from_ex(stall_from_ex),
		.stall_from_id(stall_from_id),
		.stall(stall)
	);
	div div0(
		.rst(rst),
		.clk(clk),

		.signed_div_i(signed_div),
		.opdata1_i(div_opdata1),
		.opdata2_i(div_opdata2),
		.start_i(div_start),
		.annul_i(1'b0),

		.result_o(div_result),
		.ready(div_ready)
	);
endmodule