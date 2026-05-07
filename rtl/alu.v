module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  alu_ctrl,
    output reg  [31:0] result,
    output wire        zero
);

    // alu_ctrl encoding
    // 4'b0000  ADD
    // 4'b0001  SUB
    // 4'b0010  AND
    // 4'b0011  OR
    // 4'b0100  XOR
    // 4'b0101  SLL
    // 4'b0110  SRL
    // 4'b0111  SRA
    // 4'b1000  SLT  (signed)
    // 4'b1001  SLTU (unsigned)

    assign zero = (result == 32'b0);

    always @(*) begin
        case (alu_ctrl)
            4'b0000: result = a + b;
            4'b0001: result = a - b;
            4'b0010: result = a & b;
            4'b0011: result = a | b;
            4'b0100: result = a ^ b;
            4'b0101: result = a << b[4:0];
            4'b0110: result = a >> b[4:0];
            4'b0111: result = $signed(a) >>> b[4:0];
            4'b1000: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            4'b1001: result = (a < b)                  ? 32'd1 : 32'd0;
            default: result = 32'b0;
        endcase
    end

endmodule