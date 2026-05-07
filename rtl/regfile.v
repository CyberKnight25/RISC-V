module regfile (
    input  wire        clk,
    input  wire        we,       // Write Enable from WB stage
    input  wire [4:0]  rs1,      // Read address 1 (from Instruction)
    input  wire [4:0]  rs2,      // Read address 2 (from Instruction)
    input  wire [4:0]  rd,       // Write address (from WB stage)
    input  wire [31:0] wd,       // Write data (from WB stage)
    output wire [31:0] rd1,      // Read data 1
    output wire [31:0] rd2       // Read data 2
);

    // 32 registers, each 32 bits wide
    reg [31:0] registers [31:0];

    // Asynchronous read: bypass memory read if address is 0
    // x0 is strictly hardwired to 0 per RISC-V spec
    assign rd1 = (rs1 == 5'b0) ? 32'b0 : registers[rs1];
    assign rd2 = (rs2 == 5'b0) ? 32'b0 : registers[rs2];

    // Synchronous write on positive clock edge
    always @(posedge clk) begin
        // Only write if Write Enable is high AND destination is not x0
        if (we && rd != 5'b0) begin
            registers[rd] <= wd;
        end
    end

    // Optional: Initial block for simulation to clear 'X' states 
    // Synthesis tools will generally ignore this or use it to init BRAM
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'b0;
        end
    end

endmodule