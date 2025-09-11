
`include "mips_defines.vh"
`timescale 1ns / 1ns

module instruction_memory (
    input [31:0] addr,
    output reg [31:0] instruction
);

    reg [31:0] mem [`INST_MEM_SIZE-1:0];
    integer i;

    // Combinational read - immediate output when address changes
    always @(*) begin
        instruction = mem[addr[11:2]];
        end

    // Instruction loading process
    initial begin
    $display("=== Loading Comprehensive Test Program ===");
    
    for (i = 0; i < `INST_MEM_SIZE; i = i + 1) begin
            mem[i] = 32'h00000000;
        end
            //**************************************************************************
            //ALU TYPE TESTER with hazard

            //mem[0] = 32'h11090003; // BEQ $t0, $t1, +3 // branch on equal
            mem[0]  = 32'h02114020;  // ADD   $t0, $s0, $s1        
            mem[1]  = 32'h01134821;  // ADDU  $t1, $t0, $s3          
            mem[2]  = 32'h02945022;  // SUB   $t2, $s4, $s5       
            mem[3]  = 32'h01575823;  // SUBU  $t3, $t2, $s7  
            
            mem[4] = 32'h00018882;  // SRL   $s1, $at, 2          
            mem[5] = 32'h00139083;  // SRA   $s2, $s3, 2          
            mem[6] = 32'h02D5A004;  // SLLV  $s4, $s5, $s6     
            
  
    $display("Test program loaded");

end


endmodule
