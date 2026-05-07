module ex_mem_reg (
    input  wire        clk,
    input  wire        en,       // From act_mon_ex
    input  wire        rst,
    
    // Data Inputs
    input  wire [31:0] alu_result_in,
    input  wire [31:0] rs2_val_in,
    input  wire [4:0]  rd_in,
    input  wire [2:0]  funct3_in,
    
    // Control Inputs
    input  wire        reg_write_in,
    input  wire        mem_read_in,
    input  wire        mem_write_in,
    input  wire        mem_to_reg_in,
    
    // Data Outputs
    output reg  [31:0] alu_result_out,
    output reg  [31:0] rs2_val_out,
    output reg  [4:0]  rd_out,
    output reg  [2:0]  funct3_out,
    
    // Control Outputs
    output reg         reg_write_out,
    output reg         mem_read_out,
    output reg         mem_write_out,
    output reg         mem_to_reg_out
);

    wire gclk;
    icg_cell u_icg (.clk(clk), .en(en), .gclk(gclk));

    always @(posedge gclk) begin
        if (rst) begin
            reg_write_out  <= 1'b0;
            mem_read_out   <= 1'b0;
            mem_write_out  <= 1'b0;
            mem_to_reg_out <= 1'b0;
        end else begin
            alu_result_out <= alu_result_in;
            rs2_val_out    <= rs2_val_in;
            rd_out         <= rd_in;
            funct3_out     <= funct3_in;
            
            reg_write_out  <= reg_write_in;
            mem_read_out   <= mem_read_in;
            mem_write_out  <= mem_write_in;
            mem_to_reg_out <= mem_to_reg_in;
        end
    end
endmodule