module pc_reg (
    input  wire        clk,
    input  wire        rst,
    input  wire        stall,
    input  wire [31:0] pc_next,
    output reg  [31:0] pc
);

    always @(posedge clk) begin
        if (rst) begin
            // RV32I typically boots at 0x00000000, adjust if your linker script differs
            pc <= 32'b0; 
        end else if (!stall) begin
            pc <= pc_next;
        end
    end

endmodule