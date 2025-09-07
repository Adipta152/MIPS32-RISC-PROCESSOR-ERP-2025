
`include "mips_defines.vh"
`timescale 1ns/1ns

module tb_control_unit();

    // Testbench signals
    reg [31:0] instruction;
    wire RegDst, ALUSrc, RegWrite, MemRead, MemWrite, Branch;
    wire [1:0] MemtoReg, MemWidth, Jump, pc_source;
    wire [4:0] ALUControl;
    
    // Test tracking
    integer test_count = 0;
    integer pass_count = 0;
    integer fail_count = 0;
    
    // Instantiate the control unit
    control_unit uut (
        .instruction(instruction),
        .RegDst(RegDst),
        .ALUSrc(ALUSrc),
        .MemtoReg(MemtoReg),
        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .Branch(Branch),
        .MemWidth(MemWidth),
        .Jump(Jump),
        .pc_source(pc_source),
        .ALUControl(ALUControl)
    );
    
    initial begin
        $display("=== CONTROL UNIT TESTBENCH ===");
        
        // ===== R-TYPE INSTRUCTIONS =====
        $display("--- R-TYPE INSTRUCTIONS ---");
        
        // Test ADD
        instruction = {`OP_RTYPE, 5'd9, 5'd10, 5'd8, 5'd0, `FUNCT_ADD};
        #1;
        test_count = test_count + 1;
        if (RegDst === 1 && ALUSrc === 0 && MemtoReg === 0 && RegWrite === 1 && 
            MemRead === 0 && MemWrite === 0 && Branch === 0 && MemWidth === 0 && 
            Jump === 0 && pc_source === 0 && ALUControl === `ALU_ADD) begin
            $display("PASS: ADD instruction");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: ADD instruction");
            $display("  Expected: RegDst=1 ALUSrc=0 ALUControl=%b", `ALU_ADD);
            $display("  Got:      RegDst=%b ALUSrc=%b ALUControl=%b", RegDst, ALUSrc, ALUControl);
            fail_count = fail_count + 1;
        end
        
        // Test ADDU
        instruction = {`OP_RTYPE, 5'd9, 5'd10, 5'd8, 5'd0, `FUNCT_ADDU};
        #1;
        test_count = test_count + 1;
        if (RegDst === 1 && ALUSrc === 0 && MemtoReg === 0 && RegWrite === 1 && 
            MemRead === 0 && MemWrite === 0 && Branch === 0 && MemWidth === 0 && 
            Jump === 0 && pc_source === 0 && ALUControl === `ALU_ADDU) begin
            $display("PASS: ADDU instruction");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: ADDU instruction");
            fail_count = fail_count + 1;
        end
        
        // Test SUB
        instruction = {`OP_RTYPE, 5'd9, 5'd10, 5'd8, 5'd0, `FUNCT_SUB};
        #1;
        test_count = test_count + 1;
        if (RegDst === 1 && ALUControl === `ALU_SUB) begin
            $display("PASS: SUB instruction");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: SUB instruction");
            fail_count = fail_count + 1;
        end
        
        // Test AND
        instruction = {`OP_RTYPE, 5'd9, 5'd10, 5'd8, 5'd0, `FUNCT_AND};
        #1;
        test_count = test_count + 1;
        if (RegDst === 1 && ALUControl === `ALU_AND) begin
            $display("PASS: AND instruction");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: AND instruction");
            fail_count = fail_count + 1;
        end
        
        // Test OR
        instruction = {`OP_RTYPE, 5'd9, 5'd10, 5'd8, 5'd0, `FUNCT_OR};
        #1;
        test_count = test_count + 1;
        if (RegDst === 1 && ALUControl === `ALU_OR) begin
            $display("PASS: OR instruction");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: OR instruction");
            fail_count = fail_count + 1;
        end
        
        // Test XOR
        instruction = {`OP_RTYPE, 5'd9, 5'd10, 5'd8, 5'd0, `FUNCT_XOR};
        #1;
        test_count = test_count + 1;
        if (RegDst === 1 && ALUControl === `ALU_XOR) begin
            $display("PASS: XOR instruction");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: XOR instruction");
            fail_count = fail_count + 1;
        end
        
        // Test NOR
        instruction = {`OP_RTYPE, 5'd9, 5'd10, 5'd8, 5'd0, `FUNCT_NOR};
        #1;
        test_count = test_count + 1;
        if (RegDst === 1 && ALUControl === `ALU_NOR) begin
            $display("PASS: NOR instruction");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: NOR instruction");
            fail_count = fail_count + 1;
        end
        
        // Test SLT
        instruction = {`OP_RTYPE, 5'd9, 5'd10, 5'd8, 5'd0, `FUNCT_SLT};
        #1;
        test_count = test_count + 1;
        if (RegDst === 1 && ALUControl === `ALU_SLT) begin
            $display("PASS: SLT instruction");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: SLT instruction");
            fail_count = fail_count + 1;
        end
        
        // Test SLL
        instruction = {`OP_RTYPE, 5'd0, 5'd10, 5'd8, 5'd4, `FUNCT_SLL};
        #1;
        test_count = test_count + 1;
        if (RegDst === 1 && ALUControl === `ALU_SLL) begin
            $display("PASS: SLL instruction");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: SLL instruction");
            fail_count = fail_count + 1;
        end
        
        // ===== I-TYPE ARITHMETIC INSTRUCTIONS =====
        $display("--- I-TYPE ARITHMETIC ---");
        
        // Test ADDI
        instruction = {`OP_ADDI, 5'd9, 5'd8, 16'h1234};
        #1;
        test_count = test_count + 1;
        if (RegDst === 0 && ALUSrc === 1 && RegWrite === 1 && ALUControl === `ALU_ADD) begin
            $display("PASS: ADDI instruction");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: ADDI instruction");
            $display("  Expected: RegDst=0 ALUSrc=1 RegWrite=1 ALUControl=%b", `ALU_ADD);
            $display("  Got:      RegDst=%b ALUSrc=%b RegWrite=%b ALUControl=%b", RegDst, ALUSrc, RegWrite, ALUControl);
            fail_count = fail_count + 1;
        end
        
        // Test ADDIU
        instruction = {`OP_ADDIU, 5'd9, 5'd8, 16'h1234};
        #1;
        test_count = test_count + 1;
        if (RegDst === 0 && ALUSrc === 1 && RegWrite === 1 && ALUControl === `ALU_ADDU) begin
            $display("PASS: ADDIU instruction");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: ADDIU instruction");
            fail_count = fail_count + 1;
        end
        
        // Test ANDI
        instruction = {`OP_ANDI, 5'd9, 5'd8, 16'h1234};
        #1;
        test_count = test_count + 1;
        if (RegDst === 0 && ALUSrc === 1 && RegWrite === 1 && ALUControl === `ALU_AND) begin
            $display("PASS: ANDI instruction");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: ANDI instruction");
            fail_count = fail_count + 1;
        end
        
        // Test ORI
        instruction = {`OP_ORI, 5'd9, 5'd8, 16'h1234};
        #1;
        test_count = test_count + 1;
        if (RegDst === 0 && ALUSrc === 1 && RegWrite === 1 && ALUControl === `ALU_OR) begin
            $display("PASS: ORI instruction");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: ORI instruction");
            fail_count = fail_count + 1;
        end
        
        // Test LUI
        instruction = {`OP_LUI, 5'd0, 5'd8, 16'h1234};
        #1;
        test_count = test_count + 1;
        if (RegDst === 0 && ALUSrc === 1 && RegWrite === 1 && ALUControl === `ALU_LUI) begin
            $display("PASS: LUI instruction");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: LUI instruction");
            fail_count = fail_count + 1;
        end
        
        // ===== LOAD/STORE INSTRUCTIONS =====
        $display("--- LOAD/STORE INSTRUCTIONS ---");
        
        // Test LW
        instruction = {`OP_LW, 5'd9, 5'd8, 16'h1234};
        #1;
        test_count = test_count + 1;
        if (RegDst === 0 && ALUSrc === 1 && MemtoReg === 1 && RegWrite === 1 && 
            MemRead === 1 && MemWrite === 0 && MemWidth === 2 && ALUControl === `ALU_ADDU) begin
            $display("PASS: LW instruction");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: LW instruction");
            $display("  Expected: MemRead=1 MemtoReg=1 MemWidth=2");
            $display("  Got:      MemRead=%b MemtoReg=%b MemWidth=%b", MemRead, MemtoReg, MemWidth);
            fail_count = fail_count + 1;
        end
        
        // Test LH
        instruction = {`OP_LH, 5'd9, 5'd8, 16'h1234};
        #1;
        test_count = test_count + 1;
        if (RegDst === 0 && ALUSrc === 1 && MemtoReg === 1 && RegWrite === 1 && 
            MemRead === 1 && MemWrite === 0 && MemWidth === 1) begin
            $display("PASS: LH instruction");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: LH instruction");
            fail_count = fail_count + 1;
        end
        
        // Test SW
        instruction = {`OP_SW, 5'd9, 5'd8, 16'h1234};
        #1;
        test_count = test_count + 1;
        if (ALUSrc === 1 && RegWrite === 0 && MemRead === 0 && MemWrite === 1 && MemWidth === 2) begin
            $display("PASS: SW instruction");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: SW instruction");
            $display("  Expected: MemWrite=1 MemWidth=2 RegWrite=0");
            $display("  Got:      MemWrite=%b MemWidth=%b RegWrite=%b", MemWrite, MemWidth, RegWrite);
            fail_count = fail_count + 1;
        end
        
        // ===== BRANCH INSTRUCTIONS =====
        $display("--- BRANCH INSTRUCTIONS ---");
        
        // Test BEQ
        instruction = {`OP_BEQ, 5'd9, 5'd8, 16'h1234};
        #1;
        test_count = test_count + 1;
        if (ALUSrc === 0 && Branch === 1 && pc_source === 1 && ALUControl === `ALU_SUBU) begin
            $display("PASS: BEQ instruction");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: BEQ instruction");
            $display("  Expected: Branch=1 pc_source=1 ALUControl=%b", `ALU_SUBU);
            $display("  Got:      Branch=%b pc_source=%b ALUControl=%b", Branch, pc_source, ALUControl);
            fail_count = fail_count + 1;
        end
        
        // Test BNE
        instruction = {`OP_BNE, 5'd9, 5'd8, 16'h1234};
        #1;
        test_count = test_count + 1;
        if (ALUSrc === 0 && Branch === 1 && pc_source === 1 && ALUControl === `ALU_SUBU) begin
            $display("PASS: BNE instruction");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: BNE instruction");
            fail_count = fail_count + 1;
        end
        
        // ===== JUMP INSTRUCTIONS =====
        $display("--- JUMP INSTRUCTIONS ---");
        
        // Test J
        instruction = {`OP_J, 26'h1234567};
        #1;
        test_count = test_count + 1;
        if (Jump === 1 && pc_source === 2 && RegWrite === 0) begin
            $display("PASS: J instruction");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: J instruction");
            $display("  Expected: Jump=1 pc_source=2 RegWrite=0");
            $display("  Got:      Jump=%b pc_source=%b RegWrite=%b", Jump, pc_source, RegWrite);
            fail_count = fail_count + 1;
        end
        
        // Test JAL
        instruction = {`OP_JAL, 26'h1234567};
        #1;
        test_count = test_count + 1;
        if (Jump === 2 && pc_source === 2 && RegWrite === 1 && MemtoReg === 2) begin
            $display("PASS: JAL instruction");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: JAL instruction");
            $display("  Expected: Jump=2 RegWrite=1 MemtoReg=2");
            $display("  Got:      Jump=%b RegWrite=%b MemtoReg=%b", Jump, RegWrite, MemtoReg);
            fail_count = fail_count + 1;
        end
        
        // ===== TEST SUMMARY =====
        $display("=== TEST SUMMARY ===");
        $display("Total Tests: %0d", test_count);
        $display("Passed:      %0d", pass_count);
        $display("Failed:      %0d", fail_count);
        
        if (fail_count == 0) begin
            $display("ALL TESTS PASSED!");
        end else begin
            $display("%0d TESTS FAILED", fail_count);
        end
        
        $finish;
    end

endmodule
