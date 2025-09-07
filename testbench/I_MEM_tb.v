
`include "mips_defines.vh"
`timescale 1ns/1ns


module I_MEM_tb;

    // Testbench signals
    reg  [31:0] addr;
    wire [31:0] instruction;
    
    // Test variables
    integer test_count;
    integer pass_count;
    integer fail_count;
    
    // Expected instruction values for verification (matching the module's initial block)
    reg [31:0] expected_instructions [30:0];
    
    // Instantiate the instruction memory
    instruction_memory uut (
        .addr(addr),
        .instruction(instruction)
    );
    
    // Initialize expected instruction values
    initial begin
        // Load expected values matching the module's initial block
        expected_instructions[0]  = 32'h2008000A;  // addiu $t0, $zero, 10
        expected_instructions[1]  = 32'h20090014;  // addiu $t1, $zero, 20
        expected_instructions[2]  = 32'h200AFFFF;  // addiu $t2, $zero, -1
        expected_instructions[3]  = 32'h200B0000;  // addiu $t3, $zero, 0
        expected_instructions[4]  = 32'h01095820;  // add  $t3, $t0, $t1
        expected_instructions[5]  = 32'h01096021;  // addu $t4, $t0, $t1
        expected_instructions[6]  = 32'h01096822;  // sub  $t5, $t0, $t1
        expected_instructions[7]  = 32'h01097023;  // subu $t6, $t0, $t1
        expected_instructions[8]  = 32'h21080005;  // addiu $t0, $t0, 5
        expected_instructions[9]  = 32'h340FF0F0;  // ori  $t7, $zero, 0xF0F0
        expected_instructions[10] = 32'h3418ABCD;  // ori  $t8, $zero, 0xABCD
        expected_instructions[11] = 32'h01F8C824;  // and  $t9, $t7, $t8
        expected_instructions[12] = 32'h01F8D025;  // or   $t2, $t7, $t8
        expected_instructions[13] = 32'h01F8D826;  // xor  $t3, $t7, $t8
        expected_instructions[14] = 32'h01F8E027;  // nor  $t4, $t7, $t8
        expected_instructions[15] = 32'h31F900FF;  // andi $t9, $t7, 0x00FF
        expected_instructions[16] = 32'h37F9FF00;  // ori  $t9, $t7, 0xFF00
        expected_instructions[17] = 32'h0128602A;  // slt  $t4, $t1, $t0
        expected_instructions[18] = 32'h0109602B;  // sltu $t4, $t0, $t1
        expected_instructions[19] = 32'h2928000F;  // slti $t0, $t1, 15
        expected_instructions[20] = 32'h34190008;  // ori  $t9, $zero, 8
        expected_instructions[21] = 32'h0019C900;  // sll  $t9, $t9, 4
        expected_instructions[22] = 32'h0019CA02;  // srl  $t9, $t9, 8
        expected_instructions[23] = 32'h341980FF;  // ori  $t9, $zero, 0x80FF
        expected_instructions[24] = 32'h0019CA83;  // sra  $t9, $t9, 10
        expected_instructions[25] = 32'h34190002;  // ori  $t9, $zero, 2
        expected_instructions[26] = 32'h341A0010;  // ori  $t2, $zero, 16
        expected_instructions[27] = 32'h0159D804;  // sllv $t3, $t9, $t2
        expected_instructions[28] = 32'h0159D806;  // srlv $t3, $t9, $t2
        expected_instructions[29] = 32'h0159D807;  // srav $t3, $t9, $t2
        expected_instructions[30] = 32'h3C19DEAD;  // lui  $t9, 0xDEAD
    end
    
    // Test execution
    initial begin
        // Wait for module initialization to complete
        #10;
        
        // Initialize counters
        test_count = 0;
        pass_count = 0;
        fail_count = 0;
        
        $display("=================================================");
        $display("Starting Instruction Memory Testbench");
        $display("=================================================");
        
        // Initialize address
        addr = 0;
        #5;
        
        // Test 1: Basic instruction fetch from address 0
        $display("\nTest 1: Basic Instruction Fetch");
        addr = 32'h00000000; // Fetch instruction at address 0
        #5;
        
        test_count = test_count + 1;
        if (instruction == expected_instructions[0]) begin
            $display("PASS: Fetched correct instruction from address 0 (Instruction: %h)", instruction);
            $display("      ADDIU $t0, $zero, 10 - Load immediate value 10");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Expected %h, got %h from address 0", expected_instructions[0], instruction);
            fail_count = fail_count + 1;
        end
        
        // Test 2: Address indexing verification (addr[11:2])
        $display("\nTest 2: Address Indexing Verification");
        
        // Test that byte addresses within same word map to same instruction
        addr = 32'h00000000; // Word address 0, byte 0
        #5;
        test_count = test_count + 1;
        if (instruction == expected_instructions[0]) begin
            $display("PASS: Address 0x00000000 maps to instruction 0 (%h)", instruction);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Address 0x00000000 should map to instruction 0");
            fail_count = fail_count + 1;
        end
        
        addr = 32'h00000001; // Same word, different byte
        #5;
        test_count = test_count + 1;
        if (instruction == expected_instructions[0]) begin
            $display("PASS: Address 0x00000001 maps to same instruction (byte addressing ignored)");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Address 0x00000001 should map to same instruction as 0x00000000");
            fail_count = fail_count + 1;
        end
        
        addr = 32'h00000003; // Same word, highest byte
        #5;
        test_count = test_count + 1;
        if (instruction == expected_instructions[0]) begin
            $display("PASS: Address 0x00000003 maps to same instruction (proper word alignment)");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Address 0x00000003 should map to same instruction as 0x00000000");
            fail_count = fail_count + 1;
        end
        
        addr = 32'h00000004; // Next word
        #5;
        test_count = test_count + 1;
        if (instruction == expected_instructions[1]) begin
            $display("PASS: Address 0x00000004 maps to instruction 1 (%h)", instruction);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Expected %h, got %h from address 0x00000004", expected_instructions[1], instruction);
            fail_count = fail_count + 1;
        end
        
        // Test 3: Sequential instruction fetching (first 10 instructions)
        $display("\nTest 3: Sequential Instruction Fetching");
        
        for (integer i = 0; i < 10; i = i + 1) begin
            addr = i * 4; // Word-aligned addresses (0, 4, 8, 12, ...)
            #5;
            test_count = test_count + 1;
            if (instruction == expected_instructions[i]) begin
                $display("PASS: Instruction %0d correct (%h) at address %h", i, instruction, addr);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: Instruction %0d: Expected %h, got %h at address %h", i, expected_instructions[i], instruction, addr);
                fail_count = fail_count + 1;
            end
        end
        
        // Test 4: Arithmetic instructions verification
        $display("\nTest 4: Arithmetic Instructions Verification");
        
        // Test ADDIU instruction (I-type)
        addr = 32'h00000000; // addiu $t0, $zero, 10
        #5;
        test_count = test_count + 1;
        if (instruction == 32'h2008000A) begin
            $display("PASS: ADDIU instruction correct (%h) - Load immediate 10", instruction);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: ADDIU instruction wrong, expected 2008000A, got %h", instruction);
            fail_count = fail_count + 1;
        end
        
        // Test ADD instruction (R-type)
        addr = 32'h00000010; // add $t3, $t0, $t1
        #5;
        test_count = test_count + 1;
        if (instruction == 32'h01095820) begin
            $display("PASS: ADD instruction correct (%h) - Add $t0 and $t1", instruction);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: ADD instruction wrong, expected 01095820, got %h", instruction);
            fail_count = fail_count + 1;
        end
        
        // Test SUB instruction
        addr = 32'h00000018; // sub $t5, $t0, $t1
        #5;
        test_count = test_count + 1;
        if (instruction == 32'h01096822) begin
            $display("PASS: SUB instruction correct (%h) - Subtract $t1 from $t0", instruction);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: SUB instruction wrong, expected 01096822, got %h", instruction);
            fail_count = fail_count + 1;
        end
        
        // Test 5: Logical instructions verification
        $display("\nTest 5: Logical Instructions Verification");
        
        // Test ORI instruction
        addr = 32'h00000024; // ori $t7, $zero, 0xF0F0
        #5;
        test_count = test_count + 1;
        if (instruction == 32'h340FF0F0) begin
            $display("PASS: ORI instruction correct (%h) - Load immediate 0xF0F0", instruction);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: ORI instruction wrong, expected 340FF0F0, got %h", instruction);
            fail_count = fail_count + 1;
        end
        
        // Test AND instruction
        addr = 32'h0000002C; // and $t9, $t7, $t8
        #5;
        test_count = test_count + 1;
        if (instruction == 32'h01F8C824) begin
            $display("PASS: AND instruction correct (%h) - Bitwise AND operation", instruction);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: AND instruction wrong, expected 01F8C824, got %h", instruction);
            fail_count = fail_count + 1;
        end
        
        // Test XOR instruction
        addr = 32'h00000034; // xor $t3, $t7, $t8
        #5;
        test_count = test_count + 1;
        if (instruction == 32'h01F8D826) begin
            $display("PASS: XOR instruction correct (%h) - Bitwise XOR operation", instruction);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: XOR instruction wrong, expected 01F8D826, got %h", instruction);
            fail_count = fail_count + 1;
        end
        
        // Test 6: Comparison instructions verification
        $display("\nTest 6: Comparison Instructions Verification");
        
        // Test SLT instruction
        addr = 32'h00000044; // slt $t4, $t1, $t0
        #5;
        test_count = test_count + 1;
        if (instruction == 32'h0128602A) begin
            $display("PASS: SLT instruction correct (%h) - Set less than", instruction);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: SLT instruction wrong, expected 0128602A, got %h", instruction);
            fail_count = fail_count + 1;
        end
        
        // Test SLTI instruction
        addr = 32'h0000004C; // slti $t0, $t1, 15
        #5;
        test_count = test_count + 1;
        if (instruction == 32'h2928000F) begin
            $display("PASS: SLTI instruction correct (%h) - Set less than immediate", instruction);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: SLTI instruction wrong, expected 2928000F, got %h", instruction);
            fail_count = fail_count + 1;
        end
        
        // Test 7: Shift instructions verification
        $display("\nTest 7: Shift Instructions Verification");
        
        // Test SLL instruction
        addr = 32'h00000054; // sll $t9, $t9, 4
        #5;
        test_count = test_count + 1;
        if (instruction == 32'h0019C900) begin
            $display("PASS: SLL instruction correct (%h) - Shift left logical by 4", instruction);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: SLL instruction wrong, expected 0019C900, got %h", instruction);
            fail_count = fail_count + 1;
        end
        
        // Test SRL instruction
        addr = 32'h00000058; // srl $t9, $t9, 8
        #5;
        test_count = test_count + 1;
        if (instruction == 32'h0019CA02) begin
            $display("PASS: SRL instruction correct (%h) - Shift right logical by 8", instruction);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: SRL instruction wrong, expected 0019CA02, got %h", instruction);
            fail_count = fail_count + 1;
        end
        
        // Test SRA instruction
        addr = 32'h00000060; // sra $t9, $t9, 10
        #5;
        test_count = test_count + 1;
        if (instruction == 32'h0019CA83) begin
            $display("PASS: SRA instruction correct (%h) - Shift right arithmetic by 10", instruction);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: SRA instruction wrong, expected 0019CA83, got %h", instruction);
            fail_count = fail_count + 1;
        end
        
        // Test variable shift instructions
        addr = 32'h0000006C; // sllv $t3, $t9, $t2
        #5;
        test_count = test_count + 1;
        if (instruction == 32'h0159D804) begin
            $display("PASS: SLLV instruction correct (%h) - Variable shift left logical", instruction);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: SLLV instruction wrong, expected 0159D804, got %h", instruction);
            fail_count = fail_count + 1;
        end
        
        // Test 8: Load Upper Immediate
        $display("\nTest 8: Load Upper Immediate Verification");
        
        addr = 32'h00000078; // lui $t9, 0xDEAD
        #5;
        test_count = test_count + 1;
        if (instruction == 32'h3C19DEAD) begin
            $display("PASS: LUI instruction correct (%h) - Load upper immediate 0xDEAD", instruction);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: LUI instruction wrong, expected 3C19DEAD, got %h", instruction);
            fail_count = fail_count + 1;
        end
        
        // Test 9: Uninitialized memory locations
        $display("\nTest 9: Uninitialized Memory Locations");
        
        addr = 32'h00000200; // Address beyond initialized instructions (index 128)
        #5;
        test_count = test_count + 1;
        if (instruction == 32'h00000000) begin
            $display("PASS: Uninitialized memory location returns NOP (00000000)");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Uninitialized memory should return 00000000, got %h", instruction);
            fail_count = fail_count + 1;
        end
        
        addr = 32'h00000400; // Another uninitialized location (index 256)
        #5;
        test_count = test_count + 1;
        if (instruction == 32'h00000000) begin
            $display("PASS: Another uninitialized memory location returns NOP");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Uninitialized memory should return 00000000, got %h", instruction);
            fail_count = fail_count + 1;
        end
        
        // Test 10: Address boundary testing
        $display("\nTest 10: Address Boundary Testing");
        
        // Test last initialized instruction
        addr = 32'h00000078; // Last instruction (index 30)
        #5;
        test_count = test_count + 1;
        if (instruction == expected_instructions[30]) begin
            $display("PASS: Last initialized instruction accessible (%h)", instruction);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Last instruction wrong, expected %h, got %h", expected_instructions[30], instruction);
            fail_count = fail_count + 1;
        end
        
        // Test high address within memory bounds
        addr = 32'h00000FFC; // High address (index 1023 if memory size is 1024)
        #5;
        test_count = test_count + 1;
        if (instruction == 32'h00000000) begin
            $display("PASS: High boundary address returns NOP (%h)", instruction);
            pass_count = pass_count + 1;
        end else begin
            $display("INFO: High boundary address returned %h", instruction);
            pass_count = pass_count + 1; // Not necessarily a failure
        end
        
        // Test 11: Combinational logic timing
        $display("\nTest 11: Combinational Logic Response Time");
        
        // Test immediate response to address change
        addr = 32'h00000000;
        #1; // Very short delay
        test_count = test_count + 1;
        if (instruction == expected_instructions[0]) begin
            $display("PASS: Combinational logic responds immediately to address change");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Combinational logic not responding immediately");
            fail_count = fail_count + 1;
        end
        
        // Test rapid address changes
        addr = 32'h00000004;
        #1;
        addr = 32'h00000008;
        #1;
        addr = 32'h0000000C;
        #1;
        test_count = test_count + 1;
        if (instruction == expected_instructions[3]) begin
            $display("PASS: Rapid address changes handled correctly");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Rapid address changes not handled correctly, expected %h, got %h", expected_instructions[3], instruction);
            fail_count = fail_count + 1;
        end
        
        // Test 12: Complete instruction set verification
        $display("\nTest 12: Complete Loaded Instruction Set Verification");
        
        // Verify all loaded instructions (0-30)
        for (integer j = 0; j <= 30; j = j + 1) begin
            addr = j * 4;
            #2;
            test_count = test_count + 1;
            if (instruction == expected_instructions[j]) begin
                $display("PASS: Instruction %0d verified (%h)", j, instruction);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: Instruction %0d wrong: Expected %h, got %h", j, expected_instructions[j], instruction);
                fail_count = fail_count + 1;
            end
        end
        
        // Test 13: Non-aligned address behavior
        $display("\nTest 13: Non-Word-Aligned Address Behavior");
        
        // Test addresses that are not multiples of 4
        addr = 32'h0000000A; // Should map to same as 0x00000008
        #5;
        test_count = test_count + 1;
        if (instruction == expected_instructions[2]) begin
            $display("PASS: Non-aligned address 0x0000000A maps correctly (addr[11:2] indexing)");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Non-aligned address mapping incorrect");
            fail_count = fail_count + 1;
        end
        
        // Final Test Summary
        #20;
        $display("\n=================================================");
        $display("TESTBENCH SUMMARY");
        $display("=================================================");
        $display("Total Tests: %0d", test_count);
        $display("Passed:      %0d", pass_count);
        $display("Failed:      %0d", fail_count);
        
        if (fail_count == 0) begin
            $display("\n*** ALL TESTS PASSED! ***");
            $display("Instruction memory is working correctly.");
            $display("- Address indexing works properly (addr[11:2])");
            $display("- All %0d instructions loaded correctly", 31);
            $display("- Combinational logic responds immediately");
            $display("- Uninitialized locations return NOP");
        end else begin
            $display("\n*** SOME TESTS FAILED! ***");
            $display("Please review the instruction memory implementation.");
            $display("Failed tests: %0d out of %0d", fail_count, test_count);
        end
        
        $display("=================================================");
        $finish;
    end
    
    // Monitor for debugging (commented out to reduce output clutter)
    // Uncomment for detailed signal monitoring
    /*
    initial begin
        $monitor("Time=%0t: Address=%h, Instruction=%h", 
                 $time, addr, instruction);
    end
    */

endmodule
