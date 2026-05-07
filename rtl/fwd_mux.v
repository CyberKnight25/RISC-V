module fwd_mux (
    input  wire [31:0] reg_val,     // Stale value from ID/EX register
    input  wire [31:0] ex_mem_val,  // Forwarded from EX/MEM stage (1 cycle ago)
    input  wire [31:0] mem_wb_val,  // Forwarded from MEM/WB stage (2 cycles ago)
    input  wire [1:0]  fwd_sel,     // Control signal from Forwarding Unit
    output reg  [31:0] out_val
);

    // fwd_sel encoding:
    // 2'b00: No forwarding (use ID/EX value)
    // 2'b01: Forward from EX/MEM (highest priority)
    // 2'b10: Forward from MEM/WB
    
    always @(*) begin
        case (fwd_sel)
            2'b00: out_val = reg_val;
            2'b01: out_val = ex_mem_val;
            2'b10: out_val = mem_wb_val;
            default: out_val = reg_val;
        endcase
    end
endmodule