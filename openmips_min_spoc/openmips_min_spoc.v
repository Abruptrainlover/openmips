`include "define.v"

module openmips_min_spoc (
    input wire clk,
    input wire rst
);
    wire[`InstAddrBus] inst_addr;
    wire[`InstDataBus] inst;
    wire    rom_ce;

    openmips openmips_0 (
        .clk(clk),
        .rst(rst),
        .rom_data_i(inst),
        .rom_addr_o(inst_addr),
        .rom_ce_o(rom_ce)
    );

    inst_rom inst_rom_0 (
        .ce(rom_ce),
        .addr(inst_addr),
        .inst(inst)
    );
    
endmodule