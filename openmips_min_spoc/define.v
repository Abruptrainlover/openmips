`define RstEnable       1'b1 
`define RstDisable      1'b0
`define ZeroWord        32'h0
`define WriteEnable     1'b1
`define WriteDisable    1'b0
`define ReadEnable      1'b1
`define ReadDisable     1'b0
`define AluOpBus        7:0
`define AluSelBus        2:0
`define InstValid       1'b0
`define InstInvalid     1'b1
`define True            1'b1
`define False           1'b0
`define ChipEnable      1'b1
`define ChipDisable     1'b0

`define EXE_ORI         6'b001101
`define EXE_NOP         6'b000000

`define EXE_OR_OP       8'b00100101
`define EXE_NOP_OP      8'b00000000

`define EXE_RES_LOGIC   3'b001
`define EXE_RES_NOP     3'b000

`define InstAddrBus     31:0
`define InstDataBus     31:0

`define InstMemNum      131071
`define InstMemNumLog2  17


`define RegAddrBus      4:0
`define RegBus          31:0
`define RegWidth        32
`define DoubleRegWidth  64
`define DoubleRegBus    63:0
`define RegNum          32
`define RegNumLog2      5
`define NOPRegAddr      5'b00000

