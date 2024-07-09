`include "defines.v"

module openmips_min_spoc (
    input wire clk,
    input wire rst
);
    wire[`InstAddrBus] inst_addr;
    wire[`InstBus] inst;
    wire    rom_ce;
    wire[`DataBus] ram_data_i;
    wire[`DataBus] ram_data_o;
    wire[`DataAddrBus] ram_addr_o;
    wire    ram_we_o;
    wire    ram_ce_o;
    wire[3:0] ram_sel_o;
    openmips openmips_0 (
        .clk(clk),
        .rst(rst),
        .rom_data_i(inst),
        .rom_addr_o(inst_addr),
        .rom_ce_o(rom_ce),
        .ram_data_i(ram_data_i),
        .ram_data_o(ram_data_o),
        .ram_addr_o(ram_addr_o),
        .ram_we_o(ram_we_o),
        .ram_ce_o(ram_ce_o),
        .ram_sel_o(ram_sel_o)
    );

    inst_rom inst_rom_0 (
        .ce(rom_ce),
        .addr(inst_addr),
        .inst(inst)
    );
    data_ram data_ram_0 (
        .clk(clk),
        .ce(ram_ce_o),
        .we(ram_we_o),
        .addr(ram_addr_o),
        .sel(ram_sel_o),
        .data_in(ram_data_o),
        .data_out(ram_data_i)
    );
endmodule