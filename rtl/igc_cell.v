module icg_cell (
    input  wire clk, 
    input  wire en,
    output wire gclk
);

    // Xilinx native Global Clock Buffer with Enable
    BUFGCE u_bufgce (
        .O  (gclk), // Gated clock output routed on dedicated clock tree
        .CE (en),   // Clock enable from your Activity Monitors
        .I  (clk)   // Main pipeline clock
    );

endmodule