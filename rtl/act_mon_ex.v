module act_mon_ex (
    input  wire reg_write,
    input  wire mem_read,
    input  wire mem_write,
    input  wire branch,
    input  wire jump,
    output wire en
);
    // If no control signals are active, it's a bubble. Gate the clock.
    assign en = (reg_write | mem_read | mem_write | branch | jump);
endmodule