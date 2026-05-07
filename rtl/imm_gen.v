module imm_gen (
    input  wire [31:0] instr,
    output reg  [31:0] imm
);

    wire [6:0] opcode = instr[6:0];

    // RV32I opcode map
    localparam OP_IMM   = 7'b0010011; // ADDI, ANDI, ORI ...
    localparam OP_LOAD  = 7'b0000011; // LW, LH, LB ...
    localparam OP_JALR  = 7'b1100111; // JALR
    localparam OP_STORE = 7'b0100011; // SW, SH, SB
    localparam OP_BRANCH= 7'b1100011; // BEQ, BNE ...
    localparam OP_LUI   = 7'b0110111; // LUI
    localparam OP_AUIPC = 7'b0010111; // AUIPC
    localparam OP_JAL   = 7'b1101111; // JAL

    always @(*) begin
        case (opcode)

            // I-type: bits [31:20], sign-extended
            OP_IMM, OP_LOAD, OP_JALR:
                imm = {{20{instr[31]}}, instr[31:20]};

            // S-type: imm[11:5] = instr[31:25], imm[4:0] = instr[11:7]
            OP_STORE:
                imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};

            // B-type: imm[12|10:5] = instr[31:25], imm[4:1|11] = instr[11:7]
            // Note: imm[0] is always 0 (halfword aligned)
            OP_BRANCH:
                imm = {{19{instr[31]}}, instr[31], instr[7],
                        instr[30:25], instr[11:8], 1'b0};

            // U-type: upper 20 bits, lower 12 zeroed
            OP_LUI, OP_AUIPC:
                imm = {instr[31:12], 12'b0};

            // J-type: imm[20|10:1|11|19:12], imm[0] = 0
            OP_JAL:
                imm = {{11{instr[31]}}, instr[31], instr[19:12],
                        instr[20], instr[30:21], 1'b0};

            default: imm = 32'b0;

        endcase
    end

endmodule