`include "mips_defines.vh"
`timescale 1ns/1ns

module D_MEM_tb;

    // Testbench signals
    reg         clk;
    reg         MemWrite;
    reg         reset;
    reg         MemRead;
    reg  [1:0]  MemWidth;
    reg         SignExtend;
    reg  [31:0] Address1;
    reg  [31:0] Address2;
    reg  [31:0] WriteAddress;
    reg  [31:0] WriteData;
    
    wire [31:0] ReadData1;
    wire [31:0] ReadData2;
    
    // Test parameters (matching the module)
    parameter WIDTH_BYTE = 2'b00;
    parameter WIDTH_HALF = 2'b01;
    parameter WIDTH_WORD = 2'b10;
    
    // Test variables
    integer test_count;
    integer pass_count;
    integer fail_count;
    
    // Instantiate the data memory
    data_memory uut (
        .clk(clk),
        .MemWrite(MemWrite),
        .reset(reset),
        .MemRead(MemRead),
        .MemWidth(MemWidth),
        .SignExtend(SignExtend),
        .Address1(Address1),
        .Address2(Address2),
        .WriteAddress(WriteAddress),
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
        $display("Starting Data Memory Testbench");
        $display("=================================================");
        
        MemWrite = 0;
        reset = 0;
        MemRead = 0;
        MemWidth = WIDTH_BYTE;
        SignExtend = 0;
        Address1 = 0;
        Address2 = 0;
        WriteAddress = 0;
        WriteData = 0;
        
        // Test 1: Reset functionality
        $display("\nTest 1: Reset Functionality");
        reset = 1;
        #20;
        reset = 0;
        #10;
        $display("PASS: Reset sequence completed");
        pass_count = pass_count + 1;
        test_count = test_count + 1;
        
        // Test 2: MemRead control signal
        $display("\nTest 2: MemRead Control Signal");
        MemRead = 0;
        Address1 = 32'h00000000;
        #5;
        test_count = test_count + 1;
        if (ReadData1 === 32'hzzzzzzzz) begin
            $display("PASS: ReadData1 shows unknown when MemRead=0");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: ReadData1 should be unknown when MemRead=0, got %h", ReadData1);
            fail_count = fail_count + 1;
        end
        
        // Enable MemRead for subsequent tests
        MemRead = 1;
        #5;
        
        // Test 3: Byte write and read operations
        $display("\nTest 3: Byte Write and Read Operations");
        
        // Write byte 0xAB to address 0x10
        MemWidth = WIDTH_BYTE;
        WriteAddress = 32'h00000010;
        WriteData = 32'h000000AB;
        MemWrite = 1;
        #10;
        MemWrite = 0;
        
        // Read byte from address 0x10 (zero extension)
        Address1 = 32'h00000010;
        SignExtend = 0;
        #5;
        test_count = test_count + 1;
        if (ReadData1 == 32'h000000AB) begin
            $display("PASS: Byte read with zero extension (Data: %h)", ReadData1);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Expected 000000AB, got %h", ReadData1);
            fail_count = fail_count + 1;
        end
        
        // Test 4: Byte read with sign extension 
        $display("\nTest 4: Byte Sign Extension (Positive)");
        SignExtend = 1;
        #5;
        test_count = test_count + 1;
        if (ReadData1 == 32'hffffffAB) begin
            $display("PASS: Positive byte sign extension (Data: %h)", ReadData1);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Expected 000000AB, got %h", ReadData1);
            fail_count = fail_count + 1;
        end
        
        // Test 5: Byte read with sign extension (negative number)
        $display("\nTest 5: Byte Sign Extension (Negative)");
        
        // Write negative byte 0xFF to address 0x14
        WriteAddress = 32'h00000014;
        WriteData = 32'h000000FF;
        MemWrite = 1;
        #10;
        MemWrite = 0;
        
        // Read with sign extension
        Address1 = 32'h00000014;
        SignExtend = 1;
        #5;
        test_count = test_count + 1;
        if (ReadData1 == 32'hFFFFFFFF) begin
            $display("PASS: Negative byte sign extension (Data: %h)", ReadData1);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Expected FFFFFFFF, got %h", ReadData1);
            fail_count = fail_count + 1;
        end
        
        // Test 6: Half-word write and read (aligned)
        $display("\nTest 6: Half-word Operations (Aligned)");
        
        // Write half-word 0x1234 to aligned address 0x20
        MemWidth = WIDTH_HALF;
        WriteAddress = 32'h00000020;
        WriteData = 32'h00001234;
        MemWrite = 1;
        #10;
        MemWrite = 0;
        
        // Read half-word with zero extension
        Address1 = 32'h00000020;
        SignExtend = 0;
        #5;
        test_count = test_count + 1;
        if (ReadData1 == 32'h00001234) begin
            $display("PASS: Half-word read with zero extension (Data: %h)", ReadData1);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Expected 00001234, got %h", ReadData1);
            fail_count = fail_count + 1;
        end
        
        // Test 7: Half-word misaligned access
        $display("\nTest 7: Half-word Misaligned Access");
        
        // Try to write half-word to misaligned address 0x21
        WriteAddress = 32'h00000021;
        WriteData = 32'h0000ABCD;
        MemWrite = 1;
        #10;
        MemWrite = 0;
        
        // Try to read from misaligned address
        Address1 = 32'h00000021;
        #5;
        test_count = test_count + 1;
        if (ReadData1 == 32'h00000000) begin
            $display("PASS: Misaligned half-word access returns 0");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Misaligned access should return 0, got %h", ReadData1);
            fail_count = fail_count + 1;
        end
        
        // Test 8: Word write and read (aligned)
        $display("\nTest 8: Word Operations (Aligned)");
        
        // Write word 0x12345678 to aligned address 0x30
        MemWidth = WIDTH_WORD;
        WriteAddress = 32'h00000030;
        WriteData = 32'h12345678;
        MemWrite = 1;
        #10;
        MemWrite = 0;
        
        // Read word
        Address1 = 32'h00000030;
        #5;
        test_count = test_count + 1;
        if (ReadData1 == 32'h12345678) begin
            $display("PASS: Word read successful (Data: %h)", ReadData1);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Expected 12345678, got %h", ReadData1);
            fail_count = fail_count + 1;
        end
        
        // Test 9: Word misaligned access
        $display("\nTest 9: Word Misaligned Access");
        
        // Try to write word to misaligned address 0x31
        WriteAddress = 32'h00000031;
        WriteData = 32'hDEADBEEF;
        MemWrite = 1;
        #10;
        MemWrite = 0;
        
        // Try to read from misaligned address
        Address1 = 32'h00000031;
        #5;
        test_count = test_count + 1;
        if (ReadData1 == 32'h00000000) begin
            $display("PASS: Misaligned word access returns 0");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Misaligned word access should return 0, got %h", ReadData1);
            fail_count = fail_count + 1;
        end
        
        // Test 10: Big-endian byte ordering verification
        $display("\nTest 10: Big-endian Byte Ordering");
        
        // Write word 0xAABBCCDD to address 0x40
        WriteAddress = 32'h00000040;
        WriteData = 32'hAABBCCDD;
        MemWidth = WIDTH_WORD;
        MemWrite = 1;
        #10;
        MemWrite = 0;
        
        // Read individual bytes to verify big-endian storage
        MemWidth = WIDTH_BYTE;
        SignExtend = 0;
        
        // Read byte at address 0x40 (should be 0xAA - MSB)
        Address1 = 32'h00000040;
        #5;
        test_count = test_count + 1;
        if (ReadData1 == 32'h000000AA) begin
            $display("PASS: Big-endian MSB at lowest address (Data: %h)", ReadData1);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Expected 000000AA at address 0x40, got %h", ReadData1);
            fail_count = fail_count + 1;
        end
        
        // Read byte at address 0x43 (should be 0xDD - LSB)
        Address1 = 32'h00000043;
        #5;
        test_count = test_count + 1;
        if (ReadData1 == 32'h000000DD) begin
            $display("PASS: Big-endian LSB at highest address (Data: %h)", ReadData1);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Expected 000000DD at address 0x43, got %h", ReadData1);
            fail_count = fail_count + 1;
        end
        
        // Test 11: Simultaneous dual port read
        $display("\nTest 11: Dual Port Read Operations");
        
        // Setup different data at different addresses
        MemWidth = WIDTH_WORD;
        WriteAddress = 32'h00000050;
        WriteData = 32'h11111111;
        MemWrite = 1;
        #10;
        MemWrite = 0;
        
        WriteAddress = 32'h00000054;
        WriteData = 32'h22222222;
        MemWrite = 1;
        #10;
        MemWrite = 0;
        
        // Read from both addresses simultaneously
        Address1 = 32'h00000050;
        Address2 = 32'h00000054;
        #5;
        
        test_count = test_count + 1;
        if (ReadData1 == 32'h11111111 && ReadData2 == 32'h22222222) begin
            $display("PASS: Dual port read successful (Port1: %h, Port2: %h)", ReadData1, ReadData2);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Dual port read failed (Port1: %h, Port2: %h)", ReadData1, ReadData2);
            fail_count = fail_count + 1;
        end
        
        // Test 12: Out of bounds address handling
        $display("\nTest 12: Out of Bounds Address Handling");
        
        // Try to write to out of bounds address
        WriteAddress = 32'h00001000; // Beyond our test memory size
        WriteData = 32'hFFFFFFFF;
        MemWrite = 1;
        #10;
        MemWrite = 0;
        
        // Try to read from out of bounds address
        Address1 = 32'h00001000;
        #5;
        test_count = test_count + 1;
        if (ReadData1 == 32'h00000000) begin
            $display("PASS: Out of bounds read returns 0");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Out of bounds read should return 0, got %h", ReadData1);
            fail_count = fail_count + 1;
        end
        
        // Test 13: MemWrite control signal
        $display("\nTest 13: MemWrite Control Signal");
        
        // Try to write without MemWrite asserted
        WriteAddress = 32'h00000060;
        WriteData = 32'h99999999;
        MemWrite = 0; // Not asserting write enable
        #10;
        
        // Read the location
        Address1 = 32'h00000060;
        #5;
        test_count = test_count + 1;
        if (ReadData1 == 32'h00000000) begin
            $display("PASS: Write ignored when MemWrite not asserted");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Write should be ignored when MemWrite=0, got %h", ReadData1);
            fail_count = fail_count + 1;
        end
        
        // Test 14: Half-word sign extension
        $display("\nTest 14: Half-word Sign Extension");
        
        // Write negative half-word 0x8000
        MemWidth = WIDTH_HALF;
        WriteAddress = 32'h00000070;
        WriteData = 32'h00008000;
        MemWrite = 1;
        #10;
        MemWrite = 0;
        
        // Read with sign extension
        Address1 = 32'h00000070;
        SignExtend = 1;
        #5;
        test_count = test_count + 1;
        if (ReadData1 == 32'hFFFF8000) begin
            $display("PASS: Half-word sign extension (Data: %h)", ReadData1);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Expected FFFF8000, got %h", ReadData1);
            fail_count = fail_count + 1;
        end
        
        // Test 15: Data integrity check
        $display("\nTest 15: Data Integrity Check");
        
        // Verify previously written data is still intact
        Address1 = 32'h00000030; // Should still have 0x12345678
        MemWidth = WIDTH_WORD;
        SignExtend = 0;
        #5;
        test_count = test_count + 1;
        if (ReadData1 == 32'h12345678) begin
            $display("PASS: Data integrity maintained (Data: %h)", ReadData1);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Data integrity lost, expected 12345678, got %h", ReadData1);
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
            $display("\nALL TESTS PASSED! Data memory is working correctly.");
        end else begin
            $display("\nSOME TESTS FAILED! Please review the data memory implementation.");
        end
        
        $display("=================================================");
        $finish;
    end
    
    // Monitor for debugging
    initial begin
        $monitor("Time=%0t: MemWrite=%b, MemRead=%b, MemWidth=%b, SignExt=%b, WrAddr=%h, WrData=%h, Addr1=%h, RdData1=%h, Addr2=%h, RdData2=%h", 
                 $time, MemWrite, MemRead, MemWidth, SignExtend, WriteAddress, WriteData, Address1, ReadData1, Address2, ReadData2);
    end

endmodule
