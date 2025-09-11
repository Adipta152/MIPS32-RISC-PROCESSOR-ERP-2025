
`timescale 1ns / 1ns
`include "mips_defines.vh"


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
    
initial begin

        cycle_count = 0;
        tests_passed = 24'b0;
                
        // Target registers for each instruction
        target_registers[0]  = 5'd8;   // $t0  (ADD rd=$t0) 
        target_registers[1]  = 5'd9;   // $t1  (ADDU rd=$t1) 
        target_registers[2]  = 5'd10;  // $t2  (SUB rd=$t2) 
        target_registers[3]  = 5'd11;  // $t3  (SUBU rd=$t3) 

        target_registers[4]  = 5'd17;  // $t4  (AND rd=$t4) 
        target_registers[5]  = 5'd18;  // $t5  (OR rd=$t5) 
        target_registers[6]  = 5'd20;  // $t6  (XOR rd=$t6) 
        


        expected_results[0]  = 32'h99999999;  
        expected_results[1]  = 32'hEEEEDDDE;  
        expected_results[2]  = 32'h00000000;  
        expected_results[3]  = 32'h789ABCDF; 
        
        expected_results[4] = 32'h048D159E;  
        expected_results[5] = 32'h15555111;  
        expected_results[6] = 32'hFF000000; 
        

end
    
    initial begin
        // Initialize processor
        reset = 1;
        #25;
        reset = 0;
        
        $display("\n=== STARTING COMPREHENSIVE ARITHMETIC & LOGIC INSTRUCTION TEST ===");
        
        // Run for enough cycles to execute all instructions plus pipeline delay
      #600;  // 60 cycles should be enough for all instructions
        
        $display("\n=== FINAL TEST SUMMARY ===");
        for (k = 0; k < 7; k = k + 1) begin
            if (tests_passed[k]) begin
                $display("PASS - Instruction %2d: PASSED", k);
            end else begin
                $display("FAIL - Instruction %2d: FAILED", k);
            end
        end
        
        // Count passed tests manually
        passed_count = 0;
        for (j = 0; j < 7; j = j + 1) begin
            if (tests_passed[j]) passed_count = passed_count + 1;
        end
        $display("\nOverall: %0d/%0d tests passed", passed_count,j);
        
        if (passed_count == 7) begin
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
            
            for (i = 0; i < 7; i = i + 1) begin
                if (uut.write_register_addr_WB === target_registers[i] && !tests_passed[i]) begin
                    $display("\n*** INSTRUCTION %0d RESULT ***", i);
                    
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
        if (!reset && cycle_count <= 15) begin // Limit debug output to first 30 cycles
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

