module mem_stage (
    input  wire        clk,
    
    // Inputs from EX/MEM pipeline register
    input  wire [31:0] alu_result,  // Memory Address
    input  wire [31:0] rs2_val,     // Data to write (must be forwarded value)
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [2:0]  funct3,      // Encodes LB, LH, LW, LBU, LHU, SB, SH, SW
    
    // Output to MEM/WB pipeline register
    output reg  [31:0] mem_data_out
);

    wire [3:0]  dmem_we;
    wire [31:0] dmem_wd;
    wire [31:0] dmem_rd;
    wire [1:0]  byte_offset = alu_result[1:0];

    // Instantiate Data Memory
    dmem u_dmem (
        .clk  (clk),
        .we   (dmem_we),
        .addr (alu_result),
        .wd   (dmem_wd),
        .rd   (dmem_rd)
    );

    // ==========================================
    // 1. Write Logic (Data Alignment & Byte Enables)
    // ==========================================
    reg [3:0]  we_logic;
    reg [31:0] wd_logic;
    
    assign dmem_we = we_logic;
    assign dmem_wd = wd_logic;

    always @(*) begin
        we_logic = 4'b0000;
        wd_logic = 32'b0;
        
        if (mem_write) begin
            case (funct3[1:0]) 
                2'b00: begin // SB
                    wd_logic = {4{rs2_val[7:0]}};     
                    we_logic = (4'b0001 << byte_offset); 
                end
                2'b01: begin // SH
                    wd_logic = {2{rs2_val[15:0]}};    
                    we_logic = (byte_offset[1]) ? 4'b1100 : 4'b0011; 
                end
                2'b10: begin // SW
                    wd_logic = rs2_val;
                    we_logic = 4'b1111; 
                end
                default: we_logic = 4'b0000;
            endcase
        end
    end

    // ==========================================
    // 2. Read Logic (Data Extraction & Extension)
    // ==========================================
    reg [31:0] shifted_data;
    
    always @(*) begin
        case (byte_offset)
            2'b00: shifted_data = dmem_rd;
            2'b01: shifted_data = {8'b0, dmem_rd[31:8]};
            2'b10: shifted_data = {16'b0, dmem_rd[31:16]};
            2'b11: shifted_data = {24'b0, dmem_rd[31:24]};
        endcase

        if (mem_read) begin
            case (funct3)
                3'b000: mem_data_out = {{24{shifted_data[7]}}, shifted_data[7:0]};   // LB 
                3'b001: mem_data_out = {{16{shifted_data[15]}}, shifted_data[15:0]}; // LH 
                3'b010: mem_data_out = shifted_data;                                 // LW 
                3'b100: mem_data_out = {24'b0, shifted_data[7:0]};                   // LBU 
                3'b101: mem_data_out = {16'b0, shifted_data[15:0]};                  // LHU 
                default: mem_data_out = 32'b0;
            endcase
        end else begin
            mem_data_out = 32'b0; 
        end
    end

endmodule