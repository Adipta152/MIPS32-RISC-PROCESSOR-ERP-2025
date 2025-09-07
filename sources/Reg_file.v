//DONE

`include "mips_defines.vh"
`timescale 1ns/1ns

module reg_file (
    // Inputs
    input         clk,
    input         RegWrite,                      // From WB stage: Enables a write operation when asserted.
    input         reset,                     
    input  [4:0]  ReadRegister1,                 // From ID stage: Address of the first register to read (rs).
    input  [4:0]  ReadRegister2,                 // From ID stage: Address of the second register to read (rt).
    input  [4:0]  WriteRegister,                 // From WB stage: Address of the destination register to write to.
    input  [31:0] WriteData,                     // From WB stage: The 32-bit data to be written.

    // Outputs
    output [31:0] ReadData1,                     // To ID stage: The 32-bit data read from ReadRegister1.
    output [31:0] ReadData2                      // To ID stage: The 32-bit data read from ReadRegister2.
);

    reg [31:0] registers [31:0];
    integer i;

    // --- Sync Write Logic ---

    always @(posedge clk) begin
        if(reset) begin
           /* for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 0;
            end
            */
            //Loading Reg bank with required data
            /*
            registers[0]  = 32'h00000000;  //$zero
            registers[1]  = 32'h12345678;  //$at
            registers[2]  = 32'hDEADBEEF;  //$v0
            registers[3]  = 32'hCAFEBABE;  //$v1
            registers[4]  = 32'hF0F0F0F0;  //$a0
            registers[5]  = 32'h0F0F0F0F;  //$a1
            registers[6]  = 32'hFF00FF00;  //$a2
            registers[7]  = 32'h00FF00FF;  //$a3
            registers[8]  = 32'h00000010;  //$t0
            registers[9]  = 32'h00000004;  //$t1
            registers[10] = 32'h0000FFFF;  //$t2
            registers[11] = 32'h00000008;  //$t3
            registers[12] = 32'h00000000;  //$t4
            registers[13] = 32'h00000000;  //$t5
            registers[14] = 32'h00000064;  //$t6
            registers[15] = 32'h00000020; // $t7
            registers[16] = 32'h12345678; // $s0
            registers[17] = 32'h87654321; // $s1
            registers[18] = 32'hAAAABBBB;  //$s2
            registers[19] = 32'h55554445; // $s3
            registers[20] = 32'hFFFF0000;  //$s4
            registers[21] = 32'h0000FFFF; // $s5
            registers[22] = 32'h12345678; // $s6
            registers[23] = 32'h87654321; // $s7
            registers[24] = 32'h00000001; // $t8
            registers[25] = 32'h00000000; // $t9
            registers[26] = 32'h11111111; // $k0
            registers[27] = 32'h22222222; // $k1
            registers[28] = 32'h80000000; // $gp
            registers[29] = 32'h90000000; // $sp
            registers[30] = 32'h7FFFFFFF; // $fp
            registers[31] = 32'h80000000; // $ra
            */
            registers[0]  = 32'h00000000;  // $zero
            registers[1]  = 32'h12345678;  // $at
            registers[2]  = 32'hDEADBEEF;  // $v0
            registers[3]  = 32'hCAFEBABE;  // $v1
            registers[4]  = 32'hF0F0F0F0;  // $a0
            registers[5]  = 32'h0F0F0F0F;  // $a1
            registers[6]  = 32'hFF00FF00;  // $a2
            registers[7]  = 32'h00FF00FF;  // $a3
            registers[8]  = 32'h00000010;  // $t0
            registers[9]  = 32'h00000004;  // $t1
            registers[10] = 32'h0000FFFF;  // $t2
            registers[11] = 32'h00000008;  // $t3
            registers[12] = 32'h00000000;  // $t4
            registers[13] = 32'h00000000;  // $t5
            registers[14] = 32'h00000064;  // $t6
            registers[15] = 32'h00000020;  // $t7
            registers[16] = 32'h12345678;  // $s0
            registers[17] = 32'h87654321;  // $s1
            registers[18] = 32'hAAAABBBB;  // $s2
            registers[19] = 32'h55554445;  // $s3
            registers[20] = 32'hFFFF0000;  // $s4
            registers[21] = 32'h0000FFFF;  // $s5
            registers[22] = 32'h12345678;  // $s6
            registers[23] = 32'h87654321;  // $s7
            registers[24] = 32'h00000001;  // $t8
            registers[25] = 32'h00000000;  // $t9
            registers[26] = 32'h11111111;  // $k0
            registers[27] = 32'h22222222;  // $k1
            registers[28] = 32'h80000000;  // $gp
            registers[29] = 32'h90000000;  // $sp
            registers[30] = 32'h7FFFFFFF;  // $fp
            registers[31] = 32'h80000000;  // $ra
        end
    
        else if (RegWrite && (WriteRegister!= 5'b00000)) begin
            registers[WriteRegister] <= WriteData;
        end
    end
    
    // --- Async Read Logic ---
    // Read Port 1:
    assign ReadData1 = (ReadRegister1 == 5'b00000)? 32'b0 : registers[ReadRegister1];
    // Read Port 2:
    assign ReadData2 = (ReadRegister2 == 5'b00000)? 32'b0 : registers[ReadRegister2];

endmodule