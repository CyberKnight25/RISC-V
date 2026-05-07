module act_mon_wb (
    input  wire reg_write,
    output wire en
);
    // Only clock the WB register if we actually intend to write to the RegFile
    assign en = reg_write;
endmodule