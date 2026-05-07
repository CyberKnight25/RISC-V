module fwd_unit (
    // Source registers of the instruction currently in Execute (EX)
    input  wire [4:0] id_ex_rs1,
    input  wire [4:0] id_ex_rs2,
    
    // Destination register and write enable of instruction in Memory (MEM)
    input  wire       ex_mem_reg_write,
    input  wire [4:0] ex_mem_rd,
    
    // Destination register and write enable of instruction in Writeback (WB)
    input  wire       mem_wb_reg_write,
    input  wire [4:0] mem_wb_rd,
    
    // Forwarding Multiplexer Select Lines
    output reg  [1:0] fwd_a,
    output reg  [1:0] fwd_b
);

    always @(*) begin
        // Default: No forwarding, use the value from ID/EX register
        fwd_a = 2'b00;
        fwd_b = 2'b00;

        // ==============================================================
        // Forward A (rs1) logic
        // ==============================================================
        // 1. EX/MEM Hazard (Priority 1)
        if (ex_mem_reg_write && (ex_mem_rd != 5'b0) && (ex_mem_rd == id_ex_rs1)) begin
            fwd_a = 2'b01; 
        end 
        // 2. MEM/WB Hazard (Priority 2)
        else if (mem_wb_reg_write && (mem_wb_rd != 5'b0) && (mem_wb_rd == id_ex_rs1)) begin
            fwd_a = 2'b10;
        end

        // ==============================================================
        // Forward B (rs2) logic
        // ==============================================================
        // 1. EX/MEM Hazard (Priority 1)
        if (ex_mem_reg_write && (ex_mem_rd != 5'b0) && (ex_mem_rd == id_ex_rs2)) begin
            fwd_b = 2'b01;
        end 
        // 2. MEM/WB Hazard (Priority 2)
        else if (mem_wb_reg_write && (mem_wb_rd != 5'b0) && (mem_wb_rd == id_ex_rs2)) begin
            fwd_b = 2'b10;
        end
    end

endmodule