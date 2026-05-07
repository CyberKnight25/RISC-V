`timescale 1ns / 1ps

module tb_riscv_core();

    // 1. Declare Testbench Signals
    reg clk;
    reg rst;

    // 2. Instantiate the CPU Core
    riscv_core u_core (
        .clk (clk),
        .rst (rst)
    );

    // 3. Clock Generation 
    // 10ns period = 100MHz clock frequency
    always #5 clk = ~clk;

    // 4. Test Sequence
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;

        // Hold reset high for 2 clock cycles to initialize all registers
        #100;
        
        // Release reset and boot the CPU!
        rst = 0;

        // Let the CPU run for 500ns (50 clock cycles)
        // This is plenty of time for our firmware.hex to execute and hit the infinite loop
        #1000;

        // Stop the simulation
        $display("Simulation Complete.");
        $finish;
    end

endmodule