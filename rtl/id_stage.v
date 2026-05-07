module id_stage (
    input  wire        clk,
    input  wire [31:0] instr,
    input  wire [31:0] pc,            // NEW: Need PC here to calculate branch target
    
    // Writeback interface
    input  wire        wb_reg_write,
    input  wire [4:0]  wb_rd,
    input  wire [31:0] wb_wd,
    
    // Outputs
    output wire [31:0] rs1_val,
    output wire [31:0] rs2_val,
    output wire [31:0] imm,
    output wire [4:0]  rs1,
    output wire [4:0]  rs2,
    output wire [4:0]  rd,
    output wire [2:0]  funct3,
    output wire        funct7_5,
    output wire [6:0]  opcode,
    
    // Control outputs
    output wire        reg_write,
    output wire        mem_read,
    output wire        mem_write,
    output wire        alu_src,
    output wire        mem_to_reg,
    output wire        branch,
    output wire        jump,
    output wire [1:0]  alu_op,

    // NEW: Branch Evaluator Outputs
    output wire        branch_taken,
    output wire [31:0] branch_target
);

    assign rs1      = instr[19:15];
    assign rs2      = instr[24:20];
    assign rd       = instr[11:7];
    assign funct3   = instr[14:12];
    assign funct7_5 = instr[30];
    assign opcode   = instr[6:0];

    regfile u_regfile (
        .clk   (clk),
        .rs1   (rs1),
        .rs2   (rs2),
        .rd    (wb_rd),
        .wd    (wb_wd),
        .we    (wb_reg_write),
        .rd1   (rs1_val),
        .rd2   (rs2_val)
    );

    imm_gen u_imm_gen (
        .instr (instr),
        .imm   (imm)
    );

    decode u_decode (
        .opcode     (opcode),
        .reg_write  (reg_write),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .alu_src    (alu_src),
        .mem_to_reg (mem_to_reg),
        .branch     (branch),
        .jump       (jump),
        .alu_op     (alu_op)
    );

    // =========================================================================
    // NEW: EARLY BRANCH RESOLUTION
    // =========================================================================
    branch_unit u_branch_unit (
        .branch        (branch),     // Direct from decode
        .funct3        (funct3),
        .rs1_val       (rs1_val),    // Direct from regfile
        .rs2_val       (rs2_val),    // Direct from regfile
        .pc            (pc),
        .imm           (imm),
        .branch_taken  (branch_taken),
        .branch_target (branch_target)
    );

endmodule