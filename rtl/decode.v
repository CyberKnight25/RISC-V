module decode (
    input  wire [6:0] opcode,
    output reg        reg_write,
    output reg        mem_read,
    output reg        mem_write,
    output reg        alu_src,    // 0: rs2, 1: imm
    output reg        mem_to_reg, // 0: alu result, 1: mem data
    output reg        branch,
    output reg        jump,
    output reg  [1:0] alu_op      // 00: ADD (load/store), 01: SUB (branch), 10: R/I-type
);

    // RV32I opcode map
    localparam OP_R_TYPE  = 7'b0110011;
    localparam OP_I_TYPE  = 7'b0010011;
    localparam OP_LOAD    = 7'b0000011;
    localparam OP_STORE   = 7'b0100011;
    localparam OP_BRANCH  = 7'b1100011;
    localparam OP_JAL     = 7'b1101111;
    localparam OP_JALR    = 7'b1100111;
    localparam OP_LUI     = 7'b0110111;
    localparam OP_AUIPC   = 7'b0010111;

    always @(*) begin
        // Default assignments to prevent latches
        reg_write  = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        alu_src    = 1'b0;
        mem_to_reg = 1'b0;
        branch     = 1'b0;
        jump       = 1'b0;
        alu_op     = 2'b00;

        case (opcode)
            OP_R_TYPE: begin
                reg_write = 1'b1;
                alu_op    = 2'b10;
            end
            OP_I_TYPE: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                alu_op    = 2'b10;
            end
            OP_LOAD: begin
                reg_write  = 1'b1;
                mem_read   = 1'b1;
                alu_src    = 1'b1;
                mem_to_reg = 1'b1;
            end
            OP_STORE: begin
                mem_write = 1'b1;
                alu_src   = 1'b1;
            end
            OP_BRANCH: begin
                branch = 1'b1;
                alu_op = 2'b01;
            end
            OP_JAL: begin
                reg_write = 1'b1;
                jump      = 1'b1;
            end
            OP_JALR: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                jump      = 1'b1;
            end
            OP_LUI, OP_AUIPC: begin
                reg_write = 1'b1;
                alu_src   = 1'b1; 
            end
            default: ; // All defaults already set 0
        endcase
    end
endmodule