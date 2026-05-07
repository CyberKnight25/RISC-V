module branch_unit (
    input  wire        branch,
    input  wire [2:0]  funct3,
    input  wire [31:0] rs1_val,
    input  wire [31:0] rs2_val,
    input  wire [31:0] pc,
    input  wire [31:0] imm,
    output reg         branch_taken,
    output wire [31:0] branch_target
);

    assign branch_target = pc + imm;

    always @(*) begin
        if (!branch) begin
            branch_taken = 1'b0;
        end else begin
            case (funct3)
                3'b000: branch_taken = (rs1_val == rs2_val);
                3'b001: branch_taken = (rs1_val != rs2_val);
                3'b100: branch_taken = ($signed(rs1_val) < $signed(rs2_val));
                3'b101: branch_taken = ($signed(rs1_val) >= $signed(rs2_val));
                3'b110: branch_taken = (rs1_val < rs2_val);
                3'b111: branch_taken = (rs1_val >= rs2_val);
                default: branch_taken = 1'b0;
            endcase
        end
    end

endmodule