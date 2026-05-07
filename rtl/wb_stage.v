module wb_stage (
    // Inputs from MEM/WB pipeline register
    input  wire [31:0] alu_result,
    input  wire [31:0] mem_data,
    input  wire [31:0] pc_plus_4,   // For JAL/JALR return addresses
    input  wire        mem_to_reg,
    input  wire        jump,        // Signal from decode indicating a jump
    
    // Output directly to the Register File (in ID stage) and Forwarding Unit
    output reg  [31:0] wb_data
);

    always @(*) begin
        if (jump) begin
            wb_data = pc_plus_4; // Return address for JAL/JALR
        end else if (mem_to_reg) begin
            wb_data = mem_data;  // Data from DMEM
        end else begin
            wb_data = alu_result; // Data from ALU
        end
    end

endmodule