
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
            //ALU TYPE TESTER
            //mem[0] = 32'h11090003; // BEQ $t0, $t1, +3 // branch on equal
            mem[0]  = 32'h02114020;  // ADD   $t0, $s0, $s1        
            mem[1]  = 32'h01134821;  // ADDU  $t1, $t0, $s3          
            mem[2]  = 32'h02945022;  // SUB   $t2, $s4, $s5       
            mem[3]  = 32'h01575823;  // SUBU  $t3, $t2, $s7  
            /*
            CORRECT ALU SET WITHOUT HAZARD
            mem[0]  = 32'h02114020;  // ADD   $t0, $s0, $s1        
            mem[1]  = 32'h02534821;  // ADDU  $t1, $s2, $s3          
            mem[2]  = 32'h02945022;  // SUB   $t2, $s4, $s5       
            mem[3]  = 32'h02D75823;  // SUBU  $t3, $s6, $s7        
            mem[4]  = 32'h00856024;  // AND   $t4, $a0, $a1        
            mem[5]  = 32'h00C76825;  // OR    $t5, $a2, $a3        
            mem[6]  = 32'h00437026;  // XOR   $t6, $v0, $v1        
            mem[7]  = 32'h035B7827;  // NOR   $t7, $k0, $k1        
            mem[8]  = 32'h031EC02A;  // SLT   $t8, $t8, $fp        
            mem[9]  = 32'h03BFC82B;  // SLTU  $t9, $sp, $ra        
            mem[10] = 32'h00008040;  // SLL   $s0, $zero, 1        
            mem[11] = 32'h00018882;  // SRL   $s1, $at, 2          
            mem[12] = 32'h00139083;  // SRA   $s2, $s3, 2          
            mem[13] = 32'h02D5A004;  // SLLV  $s4, $s5, $s6        
            mem[14] = 32'h0128B806;  // SRLV  $s7, $t0, $t1        
            mem[15] = 32'h016A2007;  // SRAV  $a0, $t2, $t3       
            mem[16] = 32'h21850064;  // ADDI  $a1, $t4, 100        
            mem[17] = 32'h25A600C8;  // ADDIU $a2, $t5, 200        
            mem[18] = 32'h29C70032;  // SLTI  $a3, $t6, 50         
            mem[19] = 32'h2DE2004B;  // SLTIU $v0, $t7, 75         
            mem[20] = 32'h330300FF;  // ANDI  $v1, $t8, 255        
            mem[21] = 32'h373A00F0;  // ORI   $k0, $t9, 240        
            mem[22] = 32'h3A1B00AA;  // XORI  $k1, $s0, 170        
            mem[23] = 32'h3C1C1000;  // LUI   $gp, 4096    
            */
            
            //******************************************************************* 
            /*
            //correct LOAD TESTER WITHOUT HAZARD
            mem[24] = 32'h81860004; // LB $a2, 4($t4) // load signed byte
            //mem[25] = 32'h00000000; // NOP
            mem[25] = 32'h85870006; // LH $a3, 6($t4) // load signed halfword
            //mem[27] = 32'h00000000; // NOP
            mem[26] = 32'h8D840010; // LW $a4, 16($t4) // load word
            //mem[29] = 32'h00000000; // NOP
            mem[27] = 32'h9149000A; // LBU $t1, 10($t2) // load unsigned byte
            //mem[31] = 32'h00000000; // NOP
            mem[28] = 32'h9550000C; // LHU $s0, 12($t2) // load unsigned halfword
            //mem[33] = 32'h00000000; // NOP
            */
            //*******************************************************************
            /*
            //STORE TESTER
            mem[29] = 32'hA1850018; // SB $a1, 24($t4) // store byte
            //mem[35] = 32'h00000000; // NOP

            mem[30] = 32'hA586001A; // SH $a2, 26($t4) // store halfword
            //mem[37] = 32'h00000000; // NOP

            mem[31] = 32'hAD87001C; // SW $a3, 28($t4) // store word
            //mem[39] = 32'h00000000; // NOP
            */
            //******************************************************************* 
            /*
            //JUMP AND BRANCH TESTER
            mem[40] = 32'h11090003; // BEQ $t0, $t1, +3 // branch on equal
            //mem[41] = 32'h00000000; // NOP

            mem[42] = 32'h152A0002; // BNE $t1, $t2, +2 // branch on not equal
            //mem[43] = 32'h00000000; // NOP

            mem[43] = 32'h08000004; // J
            //mem[45] = 32'h00000000; // NOP

            mem[44] = 32'h0C000008; // JAL
            
            */
  
    $display("Test program loaded");

end


endmodule
