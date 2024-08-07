
`include "defines.v"

module ex(

	input wire						rst,
	
	
	input wire[`AluOpBus]         aluop_i,
	input wire[`AluSelBus]        alusel_i,
	input wire[`RegBus]           reg1_i,
	input wire[`RegBus]           reg2_i,
	input wire[`RegAddrBus]       wd_i,
	input wire                    wreg_i,

	input wire[`RegBus]           hi_i,
	input wire[`RegBus]           lo_i,

	input wire[`RegBus]           wb_hi_i,
	input wire[`RegBus]           wb_lo_i,
	input wire 					  wb_whilo_i,

	input wire[`RegBus]			  mem_hi_i,
	input wire[`RegBus]			  mem_lo_i,
	input wire					  mem_whilo_i,
	//mul
	input wire[1:0]					  cnt_i,
	input wire[`DoubleRegBus]		hilo_temp_i,
	//div
	input wire[`DoubleRegBus]       div_result_i,
	input wire			             div_ready_i,

	input wire[`RegBus]           link_addr_i,
	input wire						is_in_delayslot_i,

	input wire[`RegBus]				inst_i,

	input wire 						mem_cp0_reg_we,
	input wire [`RegBus]			mem_cp0_reg_data,
	input wire [4:0]				mem_cp0_reg_write_addr,

	input wire 						wb_cp0_reg_we,
	input wire [`RegBus]			wb_cp0_reg_data,
	input wire [4:0]				wb_cp0_reg_write_addr,
	input wire[`RegBus]				cp0_reg_data_i,
	output reg[4:0]					cp0_reg_read_addr_o,
	output reg						cp0_reg_we_o,
	output reg[`RegBus]				cp0_reg_data_o,
	output reg[4:0]					cp0_reg_write_addr_o,

	output reg[`RegBus]           hi_o,
	output reg[`RegBus]           lo_o,
	output reg			          whilo_o,	

	output reg[`RegAddrBus]       wd_o,
	output reg                    wreg_o,
	output reg[`RegBus]				wdata_o,
	
	output reg[`DoubleRegBus]           hilo_temp_o,
	output reg[1:0]           		cnt_o,
	output reg		          		stallreq,
	output reg[`RegBus]				div_opdata1_o,
	output reg[`RegBus]				div_opdata2_o,
	output reg						div_start_o,
	output reg						signed_div_o,

	output wire[`RegBus]            mem_addr_o,
	output wire[`RegBus]            reg2_o,
	output wire[`AluOpBus]          aluop_o

);

	reg[`RegBus] logicout;
	reg[`RegBus] shiftres;
	reg[`RegBus] movres;
	reg[`RegBus] HI;
	reg[`RegBus] LO;

	wire ov_sum;
	wire reg1_eq_reg2;
	wire reg1_lt_reg2;
	reg[`RegBus] arithmeticalout;
	wire[`RegBus] reg2_i_mux;
	wire[`RegBus] reg1_i_not;
	wire[`RegBus] result_sum;
	wire[`RegBus] opdata1_mult;
	wire[`RegBus] opdata2_mult;
	
	wire[`DoubleRegBus] hilo_temp;
	reg[`DoubleRegBus] hilo_temp1;
	reg stallreq_for_madd_msub;
	reg[`DoubleRegBus] mulres;

	assign aluop_o = aluop_i;
	assign mem_addr_o = reg1_i + {{16{inst_i[15]}},inst_i[15:0]};
	assign reg2_o = reg2_i;
	assign reg2_i_mux = ((aluop_i == `EXE_SUB_OP)|| (aluop_i == `EXE_SUBU_OP) || (aluop_i == `EXE_SLT_OP)) ? (~reg2_i)+1 : reg2_i;
	assign reg1_i_not = ~reg1_i;
	assign result_sum = reg1_i + reg2_i_mux;
	// assign opdata1_mult = reg1_i;
	// assign opdata2_mult = reg2_i;
	// assign hilo_temp = {hi_i,lo_i};
	assign reg1_lt_reg2 = (aluop_i == `EXE_SLT_OP ) ? 
			((reg1_i[31] && !reg2_i[31]) || 
				((!reg1_i[31] && !reg2_i[31]) && (result_sum[31])) || 
				((reg1_i[31] && reg2_i[31]) && (result_sum[31]))) : (reg1_i < reg2_i);
	assign ov_sum = ((!reg1_i[31] && !reg2_i_mux[31]) && result_sum[31])||(( reg1_i[31] && reg2_i_mux[31] ) && ( !result_sum[31] ));

	//arthmetical
	always @ (*) begin
		if(rst == `ReadEnable)
			arithmeticalout <= `ZeroWord;
		else  begin
			case(aluop_i)
				`EXE_SLT_OP, `EXE_SLTU_OP: begin
					arithmeticalout <= reg1_lt_reg2;
				end
				`EXE_ADD_OP, `EXE_ADDU_OP, `EXE_ADDI_OP,  `EXE_ADDIU_OP: begin
					arithmeticalout <= result_sum;
				end
				`EXE_SUB_OP, `EXE_SUBU_OP: begin
					arithmeticalout <= result_sum;
				end
				`EXE_CLZ_OP:		begin
					arithmeticalout <= reg1_i[31] ? 0 : reg1_i[30] ? 1 : reg1_i[29] ? 2 :
													 reg1_i[28] ? 3 : reg1_i[27] ? 4 : reg1_i[26] ? 5 :
													 reg1_i[25] ? 6 : reg1_i[24] ? 7 : reg1_i[23] ? 8 : 
													 reg1_i[22] ? 9 : reg1_i[21] ? 10 : reg1_i[20] ? 11 :
													 reg1_i[19] ? 12 : reg1_i[18] ? 13 : reg1_i[17] ? 14 : 
													 reg1_i[16] ? 15 : reg1_i[15] ? 16 : reg1_i[14] ? 17 : 
													 reg1_i[13] ? 18 : reg1_i[12] ? 19 : reg1_i[11] ? 20 :
													 reg1_i[10] ? 21 : reg1_i[9] ? 22 : reg1_i[8] ? 23 : 
													 reg1_i[7] ? 24 : reg1_i[6] ? 25 : reg1_i[5] ? 26 : 
													 reg1_i[4] ? 27 : reg1_i[3] ? 28 : reg1_i[2] ? 29 : 
													 reg1_i[1] ? 30 : reg1_i[0] ? 31 : 32 ;
				end
				`EXE_CLO_OP:		begin
					arithmeticalout <= (reg1_i_not[31] ? 0 : reg1_i_not[30] ? 1 : reg1_i_not[29] ? 2 :
													 reg1_i_not[28] ? 3 : reg1_i_not[27] ? 4 : reg1_i_not[26] ? 5 :
													 reg1_i_not[25] ? 6 : reg1_i_not[24] ? 7 : reg1_i_not[23] ? 8 : 
													 reg1_i_not[22] ? 9 : reg1_i_not[21] ? 10 : reg1_i_not[20] ? 11 :
													 reg1_i_not[19] ? 12 : reg1_i_not[18] ? 13 : reg1_i_not[17] ? 14 : 
													 reg1_i_not[16] ? 15 : reg1_i_not[15] ? 16 : reg1_i_not[14] ? 17 : 
													 reg1_i_not[13] ? 18 : reg1_i_not[12] ? 19 : reg1_i_not[11] ? 20 :
													 reg1_i_not[10] ? 21 : reg1_i_not[9] ? 22 : reg1_i_not[8] ? 23 : 
													 reg1_i_not[7] ? 24 : reg1_i_not[6] ? 25 : reg1_i_not[5] ? 26 : 
													 reg1_i_not[4] ? 27 : reg1_i_not[3] ? 28 : reg1_i_not[2] ? 29 : 
													 reg1_i_not[1] ? 30 : reg1_i_not[0] ? 31 : 32) ;
				end
				default: begin
					arithmeticalout <= `ZeroWord;
				end
			endcase
		end
	end

	// multiplication
	assign opdata1_mult = (((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MUL_OP) ||
							(aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MSUB_OP)) && (reg1_i[31] == 1'b1)) ? 
								(~reg1_i+1) : reg1_i;
	assign opdata2_mult = (((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MUL_OP) ||
							(aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MSUB_OP)) && (reg2_i[31] == 1'b1)) ? 
								(~reg2_i+1 ): reg2_i;	
	assign hilo_temp = opdata1_mult * opdata2_mult;

	always @ (*) begin
		if(rst == `RstEnable) begin
			mulres <= {`ZeroWord,`ZeroWord};
		end else if((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MUL_OP) || 
					(aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MSUB_OP)) begin
			if (reg1_i[31] ^ reg2_i[31] == 1'b1) begin
				mulres <= ~hilo_temp +1;
			end else begin
				mulres <= hilo_temp ;
			end
		end else begin
			mulres <= hilo_temp;
		end
	end
	//div
	reg stallreq_for_div;
	always @(*) begin
		if(rst ==`RstEnable) begin
			stallreq_for_div <= `NO_STOP;
			div_opdata1_o <= `ZeroWord;
			div_opdata2_o <= `ZeroWord;
			div_start_o <= `DivStop;
			signed_div_o <= 1'b0;
		end else begin
			stallreq_for_div <= `NO_STOP;
			div_opdata1_o <= `ZeroWord;
			div_opdata2_o <= `ZeroWord;
			div_start_o <= `DivStop;
			signed_div_o <= 1'b0;
			case(aluop_i)
				`EXE_DIV_OP: begin
					if(div_ready_i == `DivResultNotReady) begin
						div_opdata1_o <= reg1_i;
						div_opdata2_o <= reg2_i;
						div_start_o <= `DivStart;
						signed_div_o <= 1'b1;
						stallreq_for_div <= `STOP;
					end else if(div_ready_i == `DivResultReady) begin
						div_opdata1_o <= reg1_i;
						div_opdata2_o <= reg2_i;
						div_start_o <= `DivStop;
						signed_div_o <= 1'b1;
						stallreq_for_div <= `NO_STOP;
					end else begin
						div_opdata1_o <= `ZeroWord;
						div_opdata2_o <= `ZeroWord;
						div_start_o <= `DivStop;
						signed_div_o <= 1'b0;
						stallreq_for_div <= `NO_STOP;
					end
				end
				`EXE_DIVU_OP: begin
					if(div_ready_i == `DivResultNotReady) begin
						div_opdata1_o <= reg1_i;
						div_opdata2_o <= reg2_i;
						div_start_o <= `DivStart;
						signed_div_o <= 1'b0;
						stallreq_for_div <= `STOP;
					end else if(div_ready_i == `DivResultReady) begin
						div_opdata1_o <= reg1_i;
						div_opdata2_o <= reg2_i;
						div_start_o <= `DivStop;
						signed_div_o <= 1'b0;
						stallreq_for_div <= `NO_STOP;
					end else begin
						div_opdata1_o <= `ZeroWord;
						div_opdata2_o <= `ZeroWord;
						div_start_o <= `DivStop;
						signed_div_o <= 1'b0;
						stallreq_for_div <= `NO_STOP;
					end
				end
				default: begin
				end
				endcase
		end
	end
	//i type
	always @ (*) begin
		if(rst == `RstEnable) begin
			logicout <= `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_OR_OP:			begin
					logicout <= reg1_i | reg2_i;
				end
				`EXE_AND_OP:		begin
					logicout <= reg1_i & reg2_i;
				end
				`EXE_NOR_OP:		begin
					logicout <= ~(reg1_i | reg2_i);
				end
				`EXE_XOR_OP:		begin
					logicout <= reg1_i ^ reg2_i;
				end
				default:				begin
					logicout <= `ZeroWord;
				end
			endcase
		end   
	end      
// shift 
always @(*) begin
 	if(rst == `RstEnable) begin
 		shiftres <= `ZeroWord;
 	end else begin
 		case (aluop_i)
 			`EXE_SLL_OP:		begin
 				shiftres <= reg2_i << reg1_i[4:0];
 			end
 			`EXE_SRL_OP:		begin
 				shiftres <= reg2_i >> reg1_i[4:0];
 			end
			`EXE_SRA_OP:		begin
				shiftres <= ({32{reg2_i[31]}} << (6'd32-{1'b0,reg1_i[4:0]})) | reg2_i >> reg1_i[4:0];	
			end
 			default:			begin
 				shiftres <= `ZeroWord;
 			end
 		endcase
 	end
 end

 		// mov
		always @(*) begin
			if(rst == `RstEnable) begin
				movres <= `ZeroWord;
			end else begin
				movres <= `ZeroWord;
				case (aluop_i)
					`EXE_MOVN_OP:		begin
						movres <= reg1_i;
					end
					`EXE_MOVZ_OP:		begin
						movres <= reg1_i;
					end
					`EXE_MFLO_OP:		begin
						movres <= LO;
					end
					`EXE_MFHI_OP:		begin
						movres <= HI;
					end
					`EXE_MFC0_OP:		begin
						movres <= cp0_reg_data_i;
						cp0_reg_read_addr_o <= inst_i[15:11];
						if(mem_cp0_reg_we == `WriteEnable && mem_cp0_reg_write_addr == inst_i[15:11]) begin
							movres <= mem_cp0_reg_data;
						end else if(wb_cp0_reg_we == `WriteEnable && wb_cp0_reg_write_addr == inst_i[15:11]) begin
							movres <= wb_cp0_reg_data;
						end 
					end
					default:			begin
						movres <= `ZeroWord;
					end
				endcase
			end 
		end

		// HI_LO
		always @(*) begin
			if(rst == `RstEnable) begin
				HI <= `ZeroWord;
				LO <= `ZeroWord;
			end else if(mem_whilo_i == `WriteEnable)begin
				HI <= mem_hi_i;
				LO <= mem_lo_i;
			end else if(wb_whilo_i == `WriteEnable) begin
					HI <= wb_hi_i;
					LO <= wb_lo_i;
			end else begin
					HI <=hi_o;
					LO <=lo_o;
				end
			end
		
	

	always @ (*) begin
		if(rst == `RstEnable) begin
			hilo_temp_o <= {`ZeroWord,`ZeroWord};
			cnt_o <= 2'b00;
			stallreq_for_madd_msub <= `NO_STOP;
		end else begin
			
			case (aluop_i) 
				`EXE_MADD_OP, `EXE_MADDU_OP:		begin
					if(cnt_i == 2'b00) begin
						hilo_temp_o <= mulres;
						cnt_o <= 2'b01;
						stallreq_for_madd_msub <= `STOP;
						hilo_temp1 <= {`ZeroWord,`ZeroWord};
					end else if(cnt_i == 2'b01) begin
						hilo_temp_o <= {`ZeroWord,`ZeroWord};						
						cnt_o <= 2'b10;
						hilo_temp1 <= hilo_temp_i + {HI,LO};
						stallreq_for_madd_msub <= `NO_STOP;
					end
				end
				`EXE_MSUB_OP, `EXE_MSUBU_OP:		begin
					if(cnt_i == 2'b00) begin
						hilo_temp_o <=  ~mulres + 1 ;
						cnt_o <= 2'b01;
						stallreq_for_madd_msub <= `STOP;
					end else if(cnt_i == 2'b01)begin
						hilo_temp_o <= {`ZeroWord,`ZeroWord};						
						cnt_o <= 2'b10;
						hilo_temp1 <= hilo_temp_i + {HI,LO};
						stallreq_for_madd_msub <= `NO_STOP;
					end				
				end
				default:	begin
					hilo_temp_o <= {`ZeroWord,`ZeroWord};
					cnt_o <= 2'b00;
					stallreq_for_madd_msub <= `NO_STOP;				
				end
			endcase
		end
	end	

	always @ (*) begin
   		stallreq = stallreq_for_madd_msub || stallreq_for_div ;
 	end
// write data wdata_o
always @ (*) begin
	 wd_o <= wd_i;	 	
	 if (((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP) || (aluop_i == `EXE_SUB_OP)) && (ov_sum == 1'b1) )begin
			 	wreg_o <= `WriteDisable;
	 end else begin 	
	 wreg_o <= wreg_i;
	 end

	 case ( alusel_i ) 
	 	`EXE_RES_LOGIC:		begin
	 		wdata_o <= logicout;
	 	end
		`EXE_RES_SHIFT:		begin
			wdata_o <= shiftres;
		end
		`EXE_RES_MOV:		begin
			wdata_o <= movres;	
		end
		`EXE_ARITH:			begin	
			wdata_o <= arithmeticalout;
		end
		`EXE_RES_MUL:		begin
			wdata_o <= mulres[31:0];
		end
		`EXE_RES_JUMP_BRANCH:	begin
			wdata_o <= link_addr_i;
		end
	 	default:					begin
	 		wdata_o <= `ZeroWord;
	 	end
	 endcase
 end	

 
		always @ (*) begin
			if( rst == `RstEnable ) begin
				hi_o <= `ZeroWord;
				lo_o <= `ZeroWord;
				whilo_o <= `WriteDisable;
			end else if ((aluop_i == `EXE_MSUB_OP) || (aluop_i == `EXE_MSUBU_OP)) begin
				whilo_o <= `WriteEnable;
				hi_o <=hilo_temp1[63:32];
				lo_o <=hilo_temp1[31:0];
			end else if ((aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MADDU_OP)) begin
				whilo_o <= `WriteEnable;
				hi_o <=hilo_temp1[63:32];
				lo_o <=hilo_temp1[31:0];
			end else if((aluop_i ==`EXE_DIV_OP)|| (aluop_i == `EXE_DIVU_OP)) begin
				whilo_o <= `WriteEnable;
				hi_o <= div_result_i[63:32];
				lo_o <= div_result_i[31:0];
			end else if ((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MULTU_OP)) begin
				whilo_o <= `WriteEnable;
				hi_o <=mulres[63:32];
				lo_o <=mulres[31:0];
			end else if(aluop_i == `EXE_MTHI_OP) begin
				hi_o <= reg1_i;
				lo_o <= LO;
				whilo_o <= `WriteEnable;
			end else if(aluop_i == `EXE_MTLO_OP) begin
				lo_o <= reg1_i;
				hi_o <= HI;
				whilo_o <= `WriteEnable;
			end else begin
				hi_o <= `ZeroWord;
				lo_o <= `ZeroWord;
				whilo_o <= `WriteDisable;
			end
		end 
	always @ (*) begin
		if(rst == `RstEnable) begin
			cp0_reg_write_addr_o <= 5'b00000;
			cp0_reg_we_o <= `WriteDisable;
			cp0_reg_data_o <= `ZeroWord;
		end else if(aluop_i == `EXE_MTC0_OP) begin
			cp0_reg_write_addr_o <= inst_i[15:11];
			cp0_reg_we_o <= `WriteEnable;
			cp0_reg_data_o <= reg1_i;
	  end else begin
			cp0_reg_write_addr_o <= 5'b00000;
			cp0_reg_we_o <= `WriteDisable;
			cp0_reg_data_o <= `ZeroWord;
		end				
	end	
endmodule