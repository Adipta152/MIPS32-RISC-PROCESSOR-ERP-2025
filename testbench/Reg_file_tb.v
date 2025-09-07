//DONE

`include "mips_defines.vh"
`timescale 1ns/1ns


module Reg_file_tb;

    reg         clk;
    reg         RegWrite;
    reg         reset;
    reg  [4:0]  ReadRegister1;
    reg  [4:0]  ReadRegister2;
    reg  [4:0]  WriteRegister;
    reg  [31:0] WriteData;
    
    wire [31:0] ReadData1;
    wire [31:0] ReadData2;
    
    // Test variables
    integer test_count;
    integer pass_count;
    integer fail_count;

    reg_file uut (
        .clk(clk),
        .RegWrite(RegWrite),
        .reset(reset),
        .ReadRegister1(ReadRegister1),
        .ReadRegister2(ReadRegister2),
        .WriteRegister(WriteRegister),
        .WriteData(WriteData),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2)
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end
    
    initial begin

        test_count = 0;
        pass_count = 0;
        fail_count = 0;
        
        $display("=================================================");
        $display("Starting Register File Testbench");
        $display("=================================================");
        
        // Initialize all signals
        RegWrite = 0;
        reset = 0;
        ReadRegister1 = 0;
        ReadRegister2 = 0;
        WriteRegister = 0;
        WriteData = 0;
        
        // Test 1: Reset
        $display("\nTest 1: Reset Functionality");
        reset = 1;
        #20;
        reset = 0;
        #10;
        
        // Check if register 0 reads 0
        ReadRegister1 = 5'b00000;
        #5;
        test_count = test_count + 1;
        if (ReadData1 == 32'b0) begin
            $display("PASS: Register 0 reads 0 after reset");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Register 0 should read 0, got %h", ReadData1);
            fail_count = fail_count + 1;
        end
        
        // Check if register 15 reads 0 after reset
        ReadRegister1 = 5'b01111;
        #5;
        test_count = test_count + 1;
        if (ReadData1 == 32'b0) begin
            $display("PASS: Register 15 reads 0 after reset");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Register 15 should read 0 after reset, got %h", ReadData1);
            fail_count = fail_count + 1;
        end
        
        // Test 2: Basic write and read functionality
        $display("\nTest 2: Basic Write and Read Functionality");
        
        // Write to register 1
        WriteRegister = 5'b00001;
        WriteData = 32'hDEADBEEF;
        RegWrite = 1;
        #10;
        RegWrite = 0;
        
        // Read from register 1
        ReadRegister1 = 5'b00001;
        #5;
        test_count = test_count + 1;
        if (ReadData1 == 32'hDEADBEEF) begin
            $display("PASS: Write/Read to register 1 successful (Data: %h)", ReadData1);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Register 1 should contain DEADBEEF, got %h", ReadData1);
            fail_count = fail_count + 1;
        end
        
        // Test 3: Write to register 0 (should not work)
        $display("\nTest 3: Register 0 Write Protection");
        
        WriteRegister = 5'b00000;
        WriteData = 32'hFFFFFFFF;
        RegWrite = 1;
        #10;
        RegWrite = 0;
        
        // Read from register 0
        ReadRegister1 = 5'b00000;
        #5;
        test_count = test_count + 1;
        if (ReadData1 == 32'b0) begin
            $display("PASS: Register 0 remains 0 (write protection works)");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Register 0 should always be 0, got %h", ReadData1);
            fail_count = fail_count + 1;
        end
        
        // Test 4: Multiple register writes
        $display("\nTest 4: Multiple Register Operations");
        
        // Write to register 5
        WriteRegister = 5'b00101;
        WriteData = 32'h12345678;
        RegWrite = 1;
        #10;
        RegWrite = 0;
        
        // Write to register 10
        WriteRegister = 5'b01010;
        WriteData = 32'h87654321;
        RegWrite = 1;
        #10;
        RegWrite = 0;
        
        // Read both registers simultaneously
        ReadRegister1 = 5'b00101;
        ReadRegister2 = 5'b01010;
        #5;
        
        test_count = test_count + 1;
        if (ReadData1 == 32'h12345678) begin
            $display("PASS: Register 5 contains correct data (%h)", ReadData1);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Register 5 should contain 12345678, got %h", ReadData1);
            fail_count = fail_count + 1;
        end
        
        test_count = test_count + 1;
        if (ReadData2 == 32'h87654321) begin
            $display("PASS: Register 10 contains correct data (%h)", ReadData2);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Register 10 should contain 87654321, got %h", ReadData2);
            fail_count = fail_count + 1;
        end
        
        // Test 5: Simultaneous read and write
        $display("\nTest 5: Simultaneous Read and Write Operations");
        
        // Write to register 7 while reading from register 5
        WriteRegister = 5'b00111;
        WriteData = 32'hABCDEF00;
        ReadRegister1 = 5'b00101; // Should still read old value
        RegWrite = 1;
        #5;
        
        test_count = test_count + 1;
        if (ReadData1 == 32'h12345678) begin
            $display("PASS: Read operation unaffected by simultaneous write");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Read should return 12345678, got %h", ReadData1);
            fail_count = fail_count + 1;
        end
        
        #5;
        RegWrite = 0;
        
        // Verify the write occurred
        ReadRegister1 = 5'b00111;
        #5;
        test_count = test_count + 1;
        if (ReadData1 == 32'hABCDEF00) begin
            $display("PASS: Register 7 write successful (%h)", ReadData1);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Register 7 should contain ABCDEF00, got %h", ReadData1);
            fail_count = fail_count + 1;
        end
        
        // Test 6: RegWrite signal control
        $display("\nTest 6: RegWrite Signal Control");
        
        // Attempt write without RegWrite asserted
        WriteRegister = 5'b01100;
        WriteData = 32'h11111111;
        RegWrite = 0; // Not asserting write enable
        #10;
        
        // Read the register
        ReadRegister1 = 5'b01100;
        #5;
        test_count = test_count + 1;
        if (ReadData1 == 32'b0) begin
            $display("PASS: Write ignored when RegWrite not asserted");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Register 12 should be 0 (no write), got %h", ReadData1);
            fail_count = fail_count + 1;
        end
        
        // Test 7: Edge case registers (highest address)
        $display("\nTest 7: Edge Case - Highest Register Address");
        
        // Write to register 31
        WriteRegister = 5'b11111;
        WriteData = 32'hFFFF0000;
        RegWrite = 1;
        #10;
        RegWrite = 0;
        
        // Read register 31
        ReadRegister1 = 5'b11111;
        #5;
        test_count = test_count + 1;
        if (ReadData1 == 32'hFFFF0000) begin
            $display("PASS: Register 31 write/read successful (%h)", ReadData1);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Register 31 should contain FFFF0000, got %h", ReadData1);
            fail_count = fail_count + 1;
        end
        
        // Test 8: Data integrity after multiple operations
        $display("\nTest 8: Data Integrity Verification");
        
        // Verify previously written data is still intact
        ReadRegister1 = 5'b00001; // Should still have DEADBEEF
        ReadRegister2 = 5'b00101; // Should still have 12345678
        #5;
        
        test_count = test_count + 1;
        if (ReadData1 == 32'hDEADBEEF) begin
            $display("PASS: Register 1 data integrity maintained");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Register 1 data corrupted, expected DEADBEEF, got %h", ReadData1);
            fail_count = fail_count + 1;
        end
        
        test_count = test_count + 1;
        if (ReadData2 == 32'h12345678) begin
            $display("PASS: Register 5 data integrity maintained");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Register 5 data corrupted, expected 12345678, got %h", ReadData2);
            fail_count = fail_count + 1;
        end
        
        // Test 9: Reset during operation
        $display("\nTest 9: Reset During Operation");
        
        reset = 1;
        #10;
        reset = 0;
        #5;
        
        // Check if all previously written registers are now zero
        ReadRegister1 = 5'b00001;
        ReadRegister2 = 5'b11111;
        #5;
        
        test_count = test_count + 1;
        if (ReadData1 == 32'b0 && ReadData2 == 32'b0) begin
            $display("PASS: Reset clears all registers");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Reset should clear all registers (R1:%h, R31:%h)", ReadData1, ReadData2);
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
            $display("\nALL TESTS PASSED! Register file is working correctly.");
        end else begin
            $display("\nSOME TESTS FAILED! Please review the register file implementation.");
        end
        
        $display("=================================================");
        $finish;
    end
    
    // Monitor for debugging
    initial begin
        $monitor("Time=%0t: RegWrite=%b, Reset=%b, WriteReg=%d, WriteData=%h, ReadReg1=%d, ReadData1=%h, ReadReg2=%d, ReadData2=%h", 
                 $time, RegWrite, reset, WriteRegister, WriteData, ReadRegister1, ReadData1, ReadRegister2, ReadData2);
    end

endmodule
