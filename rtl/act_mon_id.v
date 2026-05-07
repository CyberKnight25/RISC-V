module act_mon_id (
    input  wire stall_if_id,
    input  wire [31:0] instr,
    output wire en
);
    // Standard RV32I NOP is ADDI x0, x0, 0 (32'h00000013)
    // Gate the clock if we are stalling, or if fetching a NOP.
    assign en = (!stall_if_id) && (instr != 32'h00000013) && (instr != 32'h00000000);
endmodule