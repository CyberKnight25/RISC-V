module riscv_core (
    input  wire        clk,
    input  wire        rst,
    
    // Anti-Optimization Observable Outputs
    output wire [31:0] observe_pc,
    output wire [31:0] observe_alu_result,
    output wire [31:0] observe_mem_data
);

    // =========================================================================
    // 1. WIRE DECLARATIONS
    // =========================================================================

    // IF Stage -> IF/ID Reg
    wire [31:0] if_pc, if_instr, if_pc_plus_4;
    
    // IF/ID Reg -> ID Stage & Control
    wire [31:0] if_id_pc, if_id_instr, if_id_pc_plus_4;
    
    // ID Stage -> ID/EX Reg
    wire [31:0] id_rs1_val, id_rs2_val, id_imm;
    wire [4:0]  id_rs1, id_rs2, id_rd;
    wire [2:0]  id_funct3;
    wire        id_funct7_5;
    wire [6:0]  id_opcode;
    wire        id_reg_write, id_mem_read, id_mem_write, id_alu_src, id_mem_to_reg, id_branch, id_jump;
    wire [1:0]  id_alu_op;

    // NEW EARLY BRANCH WIRES
    wire        id_branch_taken;
    wire [31:0] id_branch_target;

    // ID/EX Reg -> EX Stage & Control
    // NOTICE: id_ex_branch is GONE
    wire [31:0] id_ex_pc, id_ex_rs1_val, id_ex_rs2_val, id_ex_imm;
    wire [4:0]  id_ex_rs1, id_ex_rs2, id_ex_rd;
    wire [2:0]  id_ex_funct3;
    wire        id_ex_funct7_5;
    wire [6:0]  id_ex_opcode;
    wire        id_ex_reg_write, id_ex_mem_read, id_ex_mem_write, id_ex_alu_src, id_ex_mem_to_reg, id_ex_jump;
    wire [1:0]  id_ex_alu_op;

    // EX Stage -> EX/MEM Reg
    // NOTICE: branch_target and branch_taken are GONE
    wire [31:0] ex_alu_result, ex_rs2_fwd_out;

    // EX/MEM Reg -> MEM Stage & Control
    wire [31:0] ex_mem_alu_result, ex_mem_rs2_val;
    wire [4:0]  ex_mem_rd;
    wire [2:0]  ex_mem_funct3;
    wire        ex_mem_reg_write, ex_mem_mem_read, ex_mem_mem_write, ex_mem_mem_to_reg;

    // MEM Stage -> MEM/WB Reg
    wire [31:0] mem_data_out;

    // MEM/WB Reg -> WB Stage & Control
    wire [31:0] mem_wb_alu_result, mem_wb_mem_data;
    wire [4:0]  mem_wb_rd;
    wire        mem_wb_reg_write, mem_wb_mem_to_reg;

    // WB Stage -> ID Stage (Register File)
    wire [31:0] wb_data;

    // Control Unit Signals
    wire        stall_pc, stall_if_id, flush_id_ex;
    wire [1:0]  fwd_a, fwd_b;

    // Activity Monitor Enable Signals
    wire        en_if_id, en_id_ex, en_ex_mem, en_mem_wb;


    // =========================================================================
    // 2. CONTROL & HAZARD UNIT
    // =========================================================================
    (* keep_hierarchy = "yes" *)
    control u_control (
        .if_id_opcode     (if_id_instr[6:0]),   // ADD THIS LINE
        
    
        .if_id_rs1        (if_id_instr[19:15]),
        .if_id_rs2        (if_id_instr[24:20]),
        .id_ex_mem_read   (id_ex_mem_read),
        .id_ex_rd         (id_ex_rd),
        .id_ex_rs1        (id_ex_rs1),
        .id_ex_rs2        (id_ex_rs2),
        .ex_mem_reg_write (ex_mem_reg_write),
        .ex_mem_rd        (ex_mem_rd),
        .mem_wb_reg_write (mem_wb_reg_write),
        .mem_wb_rd        (mem_wb_rd),
        .stall_pc         (stall_pc),
        .stall_if_id      (stall_if_id),
        .flush_id_ex      (flush_id_ex),
        .fwd_a            (fwd_a),
        .fwd_b            (fwd_b)
    );

    // =========================================================================
    // 3. ACTIVITY MONITORS
    // =========================================================================
    (* keep_hierarchy = "yes" *)
    act_mon_id u_act_mon_id (
        .stall_if_id (stall_if_id),
        .instr       (if_instr),
        .en          (en_if_id)
    );
    
    (* keep_hierarchy = "yes" *)
    act_mon_ex u_act_mon_ex (
        .reg_write (id_reg_write),
        .mem_read  (id_mem_read),
        .mem_write (id_mem_write),
        .branch    (id_branch),
        .jump      (id_jump),
        .en        (en_id_ex)
    );

    assign en_ex_mem = (id_ex_reg_write | id_ex_mem_write | id_ex_mem_read);
    
    (* keep_hierarchy = "yes" *)
    act_mon_wb u_act_mon_wb (
        .reg_write (ex_mem_reg_write),
        .en        (en_mem_wb)
    );

    // =========================================================================
    // 4. PIPELINE STAGES & REGISTERS
    // =========================================================================

    // --- IF STAGE ---
    (* keep_hierarchy = "yes" *)
    if_stage u_if_stage (
        .clk           (clk),
        .rst           (rst),
        .stall         (stall_pc),
        .branch_taken  (id_branch_taken),     // NEW ROUTING
        .branch_target (id_branch_target),    // NEW ROUTING
        .pc_out        (if_pc),
        .instr_out     (if_instr),
        .pc_plus_4_out (if_pc_plus_4)
    );

    // FLUSH UPGRADE: We only flush the IF/ID register when a branch is taken.
    // The instruction in the EX stage is perfectly safe!
    wire flush_if_id = id_branch_taken; 

    // --- IF/ID REGISTER ---
    (* keep_hierarchy = "yes" *)
    if_id_reg u_if_id_reg (
        .clk           (clk),
        .en            (en_if_id),
        .rst           (rst),
        .flush         (flush_if_id),
        .pc_in         (if_pc),
        .instr_in      (if_instr),
        .pc_plus_4_in  (if_pc_plus_4),
        .pc_out        (if_id_pc),
        .instr_out     (if_id_instr),
        .pc_plus_4_out (if_id_pc_plus_4)
    );

    // --- ID STAGE ---
    (* keep_hierarchy = "yes" *)
    id_stage u_id_stage (
        .clk          (clk),
        .instr        (if_id_instr),
        .pc           (if_id_pc),             // NEEDED FOR BRANCH TARGET
        .wb_reg_write (mem_wb_reg_write),
        .wb_rd        (mem_wb_rd),
        .wb_wd        (wb_data),
        .rs1_val      (id_rs1_val),
        .rs2_val      (id_rs2_val),
        .imm          (id_imm),
        .rs1          (id_rs1),
        .rs2          (id_rs2),
        .rd           (id_rd),
        .funct3       (id_funct3),
        .funct7_5     (id_funct7_5),
        .opcode       (id_opcode),
        .reg_write    (id_reg_write),
        .mem_read     (id_mem_read),
        .mem_write    (id_mem_write),
        .alu_src      (id_alu_src),
        .mem_to_reg   (id_mem_to_reg),
        .branch       (id_branch),
        .jump         (id_jump),
        .alu_op       (id_alu_op),
        .branch_taken (id_branch_taken),      // EARLY BRANCH
        .branch_target(id_branch_target)      // EARLY BRANCH
    );

    // FLUSH UPGRADE: The ID/EX register is NO LONGER flushed by branches. 
    // It is only flushed by Load-Use stalls (`flush_id_ex`).
    wire combined_flush_id_ex = flush_id_ex; 
    
    // --- ID/EX REGISTER ---
    (* keep_hierarchy = "yes" *)
    id_ex_reg u_id_ex_reg (
        .clk            (clk),
        .en             (en_id_ex),
        .rst            (rst),
        .flush          (combined_flush_id_ex),
        .pc_in          (if_id_pc),
        .rs1_val_in     (id_rs1_val),
        .rs2_val_in     (id_rs2_val),
        .imm_in         (id_imm),
        .rs1_in         (id_rs1),
        .rs2_in         (id_rs2),
        .rd_in          (id_rd),
        .funct3_in      (id_funct3),
        .funct7_5_in    (id_funct7_5),
        .opcode_in      (id_opcode),
        .reg_write_in   (id_reg_write),
        .mem_read_in    (id_mem_read),
        .mem_write_in   (id_mem_write),
        .alu_src_in     (id_alu_src),
        .mem_to_reg_in  (id_mem_to_reg),
        .jump_in        (id_jump),
        .alu_op_in      (id_alu_op),
        
        .pc_out         (id_ex_pc),
        .rs1_val_out    (id_ex_rs1_val),
        .rs2_val_out    (id_ex_rs2_val),
        .imm_out        (id_ex_imm),
        .rs1_out        (id_ex_rs1),
        .rs2_out        (id_ex_rs2),
        .rd_out         (id_ex_rd),
        .funct3_out     (id_ex_funct3),
        .funct7_5_out   (id_ex_funct7_5),
        .opcode_out     (id_ex_opcode),
        .reg_write_out  (id_ex_reg_write),
        .mem_read_out   (id_ex_mem_read),
        .mem_write_out  (id_ex_mem_write),
        .alu_src_out    (id_ex_alu_src),
        .mem_to_reg_out (id_ex_mem_to_reg),
        .jump_out       (id_ex_jump),
        .alu_op_out     (id_ex_alu_op)
    );

    // --- EX STAGE ---
    (* keep_hierarchy = "yes" *)
    ex_stage u_ex_stage (
        .pc             (id_ex_pc),
        .rs1_val        (id_ex_rs1_val),
        .rs2_val        (id_ex_rs2_val),
        .imm            (id_ex_imm),
        .funct3         (id_ex_funct3),
        .funct7_5       (id_ex_funct7_5),
        .opcode         (id_ex_opcode),
        .alu_op         (id_ex_alu_op),
        .alu_src        (id_ex_alu_src),
        .ex_mem_alu_res (ex_mem_alu_result), 
        .mem_wb_wd      (wb_data),           
        .fwd_a          (fwd_a),
        .fwd_b          (fwd_b),
        .alu_result     (ex_alu_result),
        .rs2_fwd_out    (ex_rs2_fwd_out)
    );

    // --- EX/MEM REGISTER ---
    (* keep_hierarchy = "yes" *)
    ex_mem_reg u_ex_mem_reg (
        .clk            (clk),
        .en             (en_ex_mem),
        .rst            (rst),
        .alu_result_in  (ex_alu_result),
        .rs2_val_in     (ex_rs2_fwd_out), 
        .rd_in          (id_ex_rd),
        .funct3_in      (id_ex_funct3),
        .reg_write_in   (id_ex_reg_write),
        .mem_read_in    (id_ex_mem_read),
        .mem_write_in   (id_ex_mem_write),
        .mem_to_reg_in  (id_ex_mem_to_reg),
        
        .alu_result_out (ex_mem_alu_result),
        .rs2_val_out    (ex_mem_rs2_val),
        .rd_out         (ex_mem_rd),
        .funct3_out     (ex_mem_funct3),
        .reg_write_out  (ex_mem_reg_write),
        .mem_read_out   (ex_mem_mem_read),
        .mem_write_out  (ex_mem_mem_write),
        .mem_to_reg_out (ex_mem_mem_to_reg)
    );

    // --- MEM STAGE ---
    (* keep_hierarchy = "yes" *)
    mem_stage u_mem_stage (
        .clk          (clk),
        .alu_result   (ex_mem_alu_result),
        .rs2_val      (ex_mem_rs2_val),
        .mem_read     (ex_mem_mem_read),
        .mem_write    (ex_mem_mem_write),
        .funct3       (ex_mem_funct3),
        .mem_data_out (mem_data_out)
    );

    // --- MEM/WB REGISTER ---
    (* keep_hierarchy = "yes" *)
    mem_wb_reg u_mem_wb_reg (
        .clk            (clk),
        .en             (en_mem_wb),
        .rst            (rst),
        .alu_result_in  (ex_mem_alu_result),
        .mem_data_in    (mem_data_out),
        .rd_in          (ex_mem_rd),
        .reg_write_in   (ex_mem_reg_write),
        .mem_to_reg_in  (ex_mem_mem_to_reg),
        
        .alu_result_out (mem_wb_alu_result),
        .mem_data_out   (mem_wb_mem_data),
        .rd_out         (mem_wb_rd),
        .reg_write_out  (mem_wb_reg_write),
        .mem_to_reg_out (mem_wb_mem_to_reg)
    );

    // --- WB STAGE ---
    (* keep_hierarchy = "yes" *)
    wb_stage u_wb_stage (
        .alu_result (mem_wb_alu_result),
        .mem_data   (mem_wb_mem_data),
        .pc_plus_4  (32'b0), 
        .mem_to_reg (mem_wb_mem_to_reg),
        .jump       (1'b0),  
        .wb_data    (wb_data)
    );

    // =========================================================================
    // 5. ANTI-OPTIMIZATION OUTPUTS
    // =========================================================================
    assign observe_pc         = if_pc;
    assign observe_alu_result = ex_alu_result;
    assign observe_mem_data   = mem_data_out;

endmodule