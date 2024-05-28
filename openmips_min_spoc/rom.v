module  rom(
    input wire ce,
    input wire [5:0] addr,
    output reg [31:0] inst
);
    reg [31:0] rom[63:0];
    
    always @(*) begin
        if (ce == 1'b1) begin
            inst <= rom[addr];
        end
        else begin
            inst <= 32'b0;
        end
    end
    
endmodule