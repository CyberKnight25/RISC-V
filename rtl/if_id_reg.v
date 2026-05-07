module if_id_reg (
    input  wire        clk,
    input  wire        en,       // From act_mon_id
    input  wire        rst,
    input  wire        flush,
    
    input  wire [31:0] pc_in,
    input  wire [31:0] instr_in,
    input  wire [31:0] pc_plus_4_in,
    
    output reg  [31:0] pc_out,
    output reg  [31:0] instr_out,
    output reg  [31:0] pc_plus_4_out
);

    wire gclk;
    icg_cell u_icg (.clk(clk), .en(en), .gclk(gclk));

    always @(posedge gclk) begin
        if (rst || flush) begin
            pc_out        <= 32'b0;
            instr_out     <= 32'h00000013; // ADDI x0, x0, 0 (NOP)
            pc_plus_4_out <= 32'b0;
        end else begin
            pc_out        <= pc_in;
            instr_out     <= instr_in;
            pc_plus_4_out <= pc_plus_4_in;
        end
    end
endmodule