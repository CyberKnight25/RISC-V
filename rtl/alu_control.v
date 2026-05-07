module alu_control (
    input  wire [1:0] alu_op,
    input  wire [2:0] funct3,
    input  wire       funct7_5, // instr[30] - used to distinguish ADD/SUB and SRL/SRA
    input  wire [6:0] opcode,   // Needed to distinguish R-type from I-type for ADD/SUB
    output reg  [3:0] alu_ctrl
);

    always @(*) begin
        case (alu_op)
            2'b00: alu_ctrl = 4'b0000; // Load/Store -> Always ADD
            2'b01: alu_ctrl = 4'b0001; // Branch -> Always SUB
            2'b10: begin // R-type or I-type
                case (funct3)
                    3'b000: begin
                        // ADD or SUB. If R-type and funct7[5] is 1, then SUB.
                        if (opcode == 7'b0110011 && funct7_5) alu_ctrl = 4'b0001;
                        else alu_ctrl = 4'b0000;
                    end
                    3'b001: alu_ctrl = 4'b0101; // SLL
                    3'b010: alu_ctrl = 4'b1000; // SLT
                    3'b011: alu_ctrl = 4'b1001; // SLTU
                    3'b100: alu_ctrl = 4'b0100; // XOR
                    3'b101: begin
                        // SRL or SRA. Works for both R-type and I-type (SRAI)
                        if (funct7_5) alu_ctrl = 4'b0111; // SRA
                        else alu_ctrl = 4'b0110;          // SRL
                    end
                    3'b110: alu_ctrl = 4'b0011; // OR
                    3'b111: alu_ctrl = 4'b0010; // AND
                endcase
            end
            default: alu_ctrl = 4'b0000;
        endcase
    end
endmodule