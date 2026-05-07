module ex_stage (
    input  wire [31:0] pc,
    input  wire [31:0] rs1_val,
    input  wire [31:0] rs2_val,
    input  wire [31:0] imm,
    input  wire [2:0]  funct3,
    input  wire        funct7_5,
    input  wire [6:0]  opcode,
    input  wire [1:0]  alu_op,
    input  wire        alu_src,     
    
    // Forwarding
    input  wire [31:0] ex_mem_alu_res,
    input  wire [31:0] mem_wb_wd,
    input  wire [1:0]  fwd_a,       
    input  wire [1:0]  fwd_b,       

    // Outputs
    output wire [31:0] alu_result,
    output wire [31:0] rs2_fwd_out  
);

    // ALU input multiplexers (Forwarding & ALU Src)
    wire [31:0] fwd_a_out = (fwd_a == 2'b10) ? ex_mem_alu_res :
                            (fwd_a == 2'b01) ? mem_wb_wd : rs1_val;

    assign rs2_fwd_out    = (fwd_b == 2'b10) ? ex_mem_alu_res :
                            (fwd_b == 2'b01) ? mem_wb_wd : rs2_val;

    wire [31:0] alu_in2   = alu_src ? imm : rs2_fwd_out;
    wire [3:0]  alu_ctrl;

    alu_control u_alu_control (
        .alu_op   (alu_op),
        .funct3   (funct3),
        .funct7_5 (funct7_5),
        .opcode   (opcode),
        .alu_ctrl (alu_ctrl)
    );

    alu u_alu (
        .a        (fwd_a_out),
        .b        (alu_in2),
        .alu_ctrl (alu_ctrl),
        .result   (alu_result),
        .zero     () // Zero flag unused now, branch logic handles it
    );

endmodule