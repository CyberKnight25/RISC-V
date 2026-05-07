module hazard_detect (
    // Signals from the instruction currently in Decode (ID)
    input  wire [4:0] if_id_rs1,
    input  wire [4:0] if_id_rs2,
    
    // Signals from the instruction currently in Execute (EX)
    input  wire       id_ex_mem_read,
    input  wire [4:0] id_ex_rd,
    
    // Hazard Control Outputs
    output reg        stall_pc,
    output reg        stall_if_id,
    output reg        flush_id_ex
);

    always @(*) begin
        // Default: Let the pipeline flow naturally
        stall_pc    = 1'b0;
        stall_if_id = 1'b0;
        flush_id_ex = 1'b0;

        // Load-Use Hazard Condition:
        // 1. Instruction in EX is a Load (mem_read == 1)
        // 2. Destination register of Load is not x0
        // 3. The Load's destination matches either source register in ID
        if (id_ex_mem_read && (id_ex_rd != 5'b0) && 
           ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2))) begin
            
            stall_pc    = 1'b1; // Freeze Program Counter
            stall_if_id = 1'b1; // Freeze IF/ID Register
            flush_id_ex = 1'b1; // Turn the ID/EX instruction into a NOP (Bubble)
            
        end
    end

endmodule