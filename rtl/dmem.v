module dmem (
    input  wire        clk,
    input  wire [3:0]  we,      // 4-bit Byte Enable
    input  wire [31:0] addr,    // Full 32-bit address from ALU
    input  wire [31:0] wd,      // Write Data
    output wire [31:0] rd       // Read Data
);

    // 1024 words = 4KB Data Memory. 
    reg [31:0] ram [0:1023];

    // Combinational read (Infers LUTRAM). 
    // Uses addr[11:2] to convert byte-address to word-index.
    assign rd = ram[addr[11:2]];

    // Synchronous write with independent byte lanes
    always @(posedge clk) begin
        if (we[0]) ram[addr[11:2]][7:0]   <= wd[7:0];
        if (we[1]) ram[addr[11:2]][15:8]  <= wd[15:8];
        if (we[2]) ram[addr[11:2]][23:16] <= wd[23:16];
        if (we[3]) ram[addr[11:2]][31:24] <= wd[31:24];
    end

endmodule