module control (
    input  wire [6:0] if_id_opcode,   // NEW: Need to know if instruction is a branch
    input  wire [4:0] if_id_rs1,
    input  wire [4:0] if_id_rs2,
    
    input  wire       id_ex_mem_read,
    input  wire       id_ex_reg_write,
    input  wire [4:0] id_ex_rs1,
    input  wire [4:0] id_ex_rs2,
    input  wire [4:0] id_ex_rd,
    
    input  wire       ex_mem_reg_write,
    input  wire       ex_mem_mem_read,
    input  wire [4:0] ex_mem_rd,
    
    input  wire       mem_wb_reg_write,
    input  wire [4:0] mem_wb_rd,
    
    output wire       stall_pc,
    output wire       stall_if_id,
    output wire       flush_id_ex,
    output wire [1:0] fwd_a,
    output wire [1:0] fwd_b
);

    // =========================================================================
    // 1. STANDARD LOAD-USE STALL
    // =========================================================================
    wire load_use_stall = id_ex_mem_read && (id_ex_rd != 5'b0) &&
                          ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2));

    // =========================================================================
    // 2. EARLY BRANCH STALL LOGIC (The HEPTA-CORE Upgrade)
    // =========================================================================
    wire is_branch = (if_id_opcode == 7'b1100011); // OP_BRANCH

    wire branch_stall = is_branch && (
        // Case A: Branch depends on an ALU instruction currently in EX.
        // Stall 1 cycle to let it reach MEM.
        (id_ex_reg_write && (id_ex_rd != 5'b0) && 
        ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2))) 
        ||
        // Case B: Branch depends on a LOAD instruction currently in MEM.
        // Stall 1 cycle to let it reach WB.
        (ex_mem_mem_read && (ex_mem_rd != 5'b0) && 
        ((ex_mem_rd == if_id_rs1) || (ex_mem_rd == if_id_rs2)))
    );

    // Combine stalls
    wire total_stall = load_use_stall | branch_stall;

    assign stall_pc    = total_stall;
    assign stall_if_id = total_stall;
    assign flush_id_ex = total_stall;

    // =========================================================================
    // 3. ALU FORWARDING LOGIC (Unchanged, for EX Stage)
    // =========================================================================
    // Forward A
    assign fwd_a = (ex_mem_reg_write && (ex_mem_rd != 5'b0) && (ex_mem_rd == id_ex_rs1)) ? 2'b10 :
                   (mem_wb_reg_write && (mem_wb_rd != 5'b0) && (mem_wb_rd == id_ex_rs1)) ? 2'b01 : 2'b00;

    // Forward B
    assign fwd_b = (ex_mem_reg_write && (ex_mem_rd != 5'b0) && (ex_mem_rd == id_ex_rs2)) ? 2'b10 :
                   (mem_wb_reg_write && (mem_wb_rd != 5'b0) && (mem_wb_rd == id_ex_rs2)) ? 2'b01 : 2'b00;

endmodule