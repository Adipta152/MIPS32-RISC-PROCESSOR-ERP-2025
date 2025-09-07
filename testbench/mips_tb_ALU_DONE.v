

`include "mips_defines.vh"
`timescale 1ns/1ns


module mips_tb();
    
    reg clk;
    reg reset;
    integer cycle_count;
    reg [31:0] expected_results [0:23]; // An array of 24 elements, each a 32-bit register, to store the correct result for each test.
    reg [4:0] target_registers [0:23]; // An array to store the 5-bit address of the destination register for each of the 24 test instructions.
    reg [23:0] tests_passed; // A 24-bit vector where each bit corresponds to a test. bit[i] = 1 means test 'i' passed.
    integer i,j,k,passed_count;
    
    mips_pipelined uut (
        .clk(clk),
        .reset(reset)
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns period for easier debugging
    end
    
    //================================================================
    // Initialize Expected Results and Test Data
    //================================================================
initial begin

        cycle_count = 0;
        tests_passed = 24'b0;
                
        // Target registers for each instruction
        target_registers[0]  = 5'd8;   // $t0  (ADD rd=$t0) 
        target_registers[1]  = 5'd9;   // $t1  (ADDU rd=$t1) 
        target_registers[2]  = 5'd10;  // $t2  (SUB rd=$t2) 
        target_registers[3]  = 5'd11;  // $t3  (SUBU rd=$t3) 
        target_registers[4]  = 5'd12;  // $t4  (AND rd=$t4) 
        target_registers[5]  = 5'd13;  // $t5  (OR rd=$t5) 
        target_registers[6]  = 5'd14;  // $t6  (XOR rd=$t6) 
        target_registers[7]  = 5'd15;  // $t7  (NOR rd=$t7) 
        target_registers[8]  = 5'd24;  // $t8  (SLT rd=$t8) 
        target_registers[9]  = 5'd25;  // $t9  (SLTU rd=$t9) 
        target_registers[10] = 5'd16;  // $s0  (SLL rd=$s0) 
        target_registers[11] = 5'd17;  // $s1  (SRL rd=$s1) 
        target_registers[12] = 5'd18;  // $s2  (SRA rd=$s2) 
        target_registers[13] = 5'd20;  // $s4  (SLLV rd=$s4) 
        target_registers[14] = 5'd23;  // $s7  (SRLV rd=$s7) 
        target_registers[15] = 5'd4;   // $a0  (SRAV rd=$a0) 
        target_registers[16] = 5'd5;   // $a1  (ADDI rt=$a1)  
        target_registers[17] = 5'd6;   // $a2  (ADDIU rt=$a2) 
        target_registers[18] = 5'd7;   // $a3  (SLTI rt=$a3) 
        target_registers[19] = 5'd2;   // $v0  (SLTIU rt=$v0) 
        target_registers[20] = 5'd3;   // $v1  (ANDI rt=$v1) 
        target_registers[21] = 5'd26;  // $k0  (ORI rt=$k0) 
        target_registers[22] = 5'd27;  // $k1  (XORI rt=$k1) 
        target_registers[23] = 5'd28;  // $gp  (LUI rt=$gp) 

                
        // Expected results (calculated based on assumed register values)
        expected_results[0]  = 32'h99999999;  // ADD:   $s0 + $s1 = 0x12345678 + 0x87654321
        expected_results[1]  = 32'h00000000;  // ADDU:  $s2 + $s3 = 0xAAAABBBB + 0x55554445 (overflow wraps)
        expected_results[2]  = 32'hFFFE0001;  // SUB:   $s4 - $s5 = 0xFFFF0000 - 0x0000FFFF
        expected_results[3]  = 32'h8ACF1357;  // SUBU:  $s6 - $s7 = 0x12345678 - 0x87654321
        expected_results[4]  = 32'h00000000;  // AND:   $a0 & $a1 = 0xF0F0F0F0 & 0x0F0F0F0F
        expected_results[5]  = 32'hFFFFFFFF;  // OR:    $a2 | $a3 = 0xFF00FF00 | 0x00FF00FF
        expected_results[6]  = 32'h14530451;  // XOR:   $v0 ^ $v1 = 0xDEADBEEF ^ 0xCAFEBABE
        expected_results[7]  = 32'hCCCCCCCC;  // NOR:   ~($k0 | $k1) = ~(0x11111111 | 0x22222222)
        expected_results[8]  = 32'h00000001;  // SLT:   $t8 < $fp (result depends on $t8 initial value)
        expected_results[9]  = 32'h00000000;  // SLTU:  $sp < $ra (unsigned) = 0x90000000 < 0x80000000 = 0
        expected_results[10] = 32'h00000000;  // SLL:   $zero << 1 = 0
        expected_results[11] = 32'h048D159E;  // SRL:   $at >> 2 = 0x12345678 >> 2
        expected_results[12] = 32'h15555111;  // SRA:   $s3 >> 2 = 0x55554444 >> 2 (arithmetic shift)
        expected_results[13] = 32'hFF000000;  // SLLV:  $s5 << ($s6 & 0x1F) = 0x0000FFFF << 24
        expected_results[14] = 32'h99999999;  // SRLV:  $t0 >> ($t1 & 0x1F) = 0x99999999 >> 0
        expected_results[15] = 32'hFFFFFFFF;  // SRAV:  $t2 >> ($t3 & 0x1F) = 0xFFFE0001 >> 23 (sign-extended)
        expected_results[16] = 32'h00000064;  // ADDI:  $t4 + 100 = 0 + 100
        expected_results[17] = 32'h000000C7;  // ADDIU: $t5 + 200 = 0xFFFFFFFF + 200
        expected_results[18] = 32'h00000000;  // SLTI:  $t6 < 50 = 0 (since $t6 = 0x14530451 > 50)
        expected_results[19] = 32'h00000000;  // SLTIU: $t7 < 75 = 0 (since $t7 = 0xCCCCCCCC > 75)
        expected_results[20] = 32'h00000001;  // ANDI:  $t8 & 0xFF = 1 & 0xFF = 1
        expected_results[21] = 32'h000000F0;  // ORI:   $t9 | 0xF0 = 0 | 0xF0 = 0xF0
        expected_results[22] = 32'h000000AA;  // XORI:  $s0 ^ 0xAA = 0 ^ 0xAA = 0xAA
        expected_results[23] = 32'h10000000;  // LUI:   4096 << 16 = 0x10000000

end
    
    //================================================================
    // Test Sequence
    //================================================================
    initial begin
        // Initialize processor
        reset = 1;
        #25;
        reset = 0;
        
        $display("\n=== STARTING COMPREHENSIVE ARITHMETIC & LOGIC INSTRUCTION TEST ===");
        
        // Run for enough cycles to execute all instructions plus pipeline delay
      #600;  // 60 cycles should be enough for all instructions
        
        $display("\n=== FINAL TEST SUMMARY ===");
        for (k = 0; k < 24; k = k + 1) begin
            if (tests_passed[k]) begin
                $display("PASS - Instruction %2d: PASSED", k);
            end else begin
                $display("FAIL - Instruction %2d: FAILED", k);
            end
        end
        
        // Count passed tests manually
        passed_count = 0;
        for (j = 0; j < 24; j = j + 1) begin
            if (tests_passed[j]) passed_count = passed_count + 1;
        end
        $display("\nOverall: %0d/24 tests passed", passed_count);
        
        if (passed_count == 24) begin
            $display("ALL TESTS PASSED!");
        end else begin
            $display("Some tests failed. Check individual results above.");
        end
        
        $display("\n=== SIMULATION COMPLETE ===");
        $finish;
    end
    
    //================================================================
    // Cycle Counter
    
    always @(posedge clk) begin
        if (!reset) cycle_count = cycle_count + 1;
    end
    
    //================================================================
    // Result Checker - Monitor WB stage for all target registers
    //================================================================
    always @(posedge clk) begin
        if (!reset && uut.reg_write_WB) begin
            // Check only when not in reset AND when the processor is actually writing to a register in the Write-Back (WB) stage.
            // 'uut.reg_write_WB' is a control signal from the DUT indicating a write is happening.
            
            for (i = 0; i < 24; i = i + 1) begin
                if (uut.write_register_addr_WB === target_registers[i] && !tests_passed[i]) begin
                    $display("\n*** INSTRUCTION %0d RESULT ***", i);
                    case (i)
                        0:  $display("ADD   $t0, $s0, $s1");
                        1:  $display("ADDU  $t1, $s2, $s3");
                        2:  $display("SUB   $t2, $s4, $s5");
                        3:  $display("SUBU  $t3, $s6, $s7");
                        4:  $display("AND   $t4, $a0, $a1");
                        5:  $display("OR    $t5, $a2, $a3");
                        6:  $display("XOR   $t6, $v0, $v1");
                        7:  $display("NOR   $t7, $k0, $k1");
                        8:  $display("SLT   $t8, $gp, $fp");
                        9:  $display("SLTU  $t9, $sp, $ra");
                        10: $display("SLL   $s0, $zero, 5");
                        11: $display("SRL   $s1, $at, 3");
                        12: $display("SRA   $s2, $s3, 4");
                        13: $display("SLLV  $s4, $s5, $s6");
                        14: $display("SRLV  $s7, $t0, $t1");
                        15: $display("SRAV  $a0, $t2, $t3");
                        16: $display("ADDI  $a1, $t4, 100");
                        17: $display("ADDIU $a2, $t5, 200");
                        18: $display("SLTI  $a3, $t6, 50");
                        19: $display("SLTIU $v0, $t7, 75");
                        20: $display("ANDI  $v1, $t8, 255");
                        21: $display("ORI   $k0, $t9, 240");
                        22: $display("XORI  $k1, $s0, 170");
                        23: $display("LUI   $gp, 4096");
                    endcase
                    $display("Writing 0x%08x to register $%0d", uut.write_back_data_WB, uut.write_register_addr_WB);
                    $display("Expected: 0x%08x", expected_results[i]);
                    
                    if (uut.write_back_data_WB === expected_results[i]) begin
                        $display("PASS - Instruction %0d executed correctly!", i);
                        tests_passed[i] = 1'b1;
                    end else begin
                        $display("FAIL - Instruction %0d failed!", i);
                        $display("   Expected: 0x%08x, Got: 0x%08x", expected_results[i], uut.write_back_data_WB);
                    end
                end
            end
        end
    end
    
    //================================================================
    //Pipeline Debug Monitor
    //================================================================
    always @(posedge clk) begin
        if (!reset && cycle_count <= 30) begin // Limit debug output to first 30 cycles
            $display("\n==================== CYCLE %0d ====================", cycle_count);
            
            // IF STAGE
            $display("--- IF STAGE ---");
            $display("PC:               0x%08x", uut.pc_current);
            $display("Instruction IF:   0x%08x", uut.instruction_IF);
            
            // ID STAGE  
            $display("--- ID STAGE ---");
            $display("Instruction ID:   0x%08x", uut.instruction_ID);
            //$display("Sign extended Immediate:    0x%08x", uut.immediate_extended_ID);
            $display("Read Data1 ID:    0x%08x (from $%0d)", uut.read_data1_ID, uut.instruction_ID[25:21]);
            $display("Read Data2 ID:    0x%08x (from $%0d)", uut.read_data2_ID, uut.instruction_ID[20:16]);
            $display("ALU Control:      %b", uut.alu_ctrl_ID);
            $display("ALU LUI:      %b", uut.ALULUIen_ID);
            
            // EX STAGE
            $display("--- EX STAGE ---");
            $display("ALU Result:       0x%08x", uut.alu_result_EX);
            $display("Write Reg Addr:   $%0d", uut.write_register_addr_EX);
            $display("RegWrite EX:      %b", uut.reg_write_EX);
            $display("ALU LUI:      %b", uut.ALULUIen_EX);
            
            // MEM STAGE
            $display("--- MEM STAGE ---");
            $display("ALU Result MEM:   0x%08x", uut.alu_result_MEM);
            $display("Write Reg Addr:   $%0d", uut.write_register_addr_MEM);
            $display("RegWrite MEM:     %b", uut.reg_write_ID);
            $display("RegWrite MEM:     %b", uut.reg_write_EX);
            $display("RegWrite MEM:     %b", uut.reg_write_MEM);
            $display("RegWrite MEM:     %b", uut.reg_write_WB);
            
            // WB STAGE
            $display("--- WB STAGE ---");
            $display("Write Back Data:  0x%08x", uut.write_back_data_WB);
            $display("Write Reg Addr:   $%0d", uut.write_register_addr_WB);
            $display("RegWrite WB:      %b", uut.reg_write_WB);
            $display("RegWrite WB:      %b", uut.mem_to_reg_WB);

        end
    end

endmodule

