module if_stage (
    input  wire        clk,
    input  wire        rst,
    input  wire        stall,
    
    // Branch control from EX stage
    input  wire        branch_taken,
    input  wire [31:0] branch_target,
    
    // Outputs to IF/ID Pipeline Register
    output wire [31:0] pc_out,
    output wire [31:0] instr_out,
    output wire [31:0] pc_plus_4_out 
);

    wire [31:0] pc_next;
    wire [31:0] pc_plus_4;

    // Default sequential fetch
    assign pc_plus_4 = pc_out + 32'd4;
    assign pc_plus_4_out = pc_plus_4; // Pass this down the pipeline (needed for JAL/JALR)

    // PC Multiplexer: Evaluate if a branch or jump was taken
    assign pc_next = branch_taken ? branch_target : pc_plus_4;

    // Instantiate Program Counter Register
    pc_reg u_pc_reg (
        .clk     (clk),
        .rst     (rst),
        .stall   (stall),
        .pc_next (pc_next),
        .pc      (pc_out)
    );

    // Instantiate Instruction ROM
    imem u_imem (
        .pc    (pc_out),
        .instr (instr_out)
    );

endmodule