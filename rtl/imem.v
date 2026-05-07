module imem (
    input  wire [31:0] pc,
    output wire [31:0] instr
);

    // 1024 words = 4KB instruction memory. Expand this if your firmware is larger.
    reg [31:0] rom [0:1023];

    // Load firmware for simulation
    initial begin
        $readmemh("firmware.hex", rom);
    end

    // Combinational, word-aligned read
    assign instr = rom[pc[11:2]];

endmodule