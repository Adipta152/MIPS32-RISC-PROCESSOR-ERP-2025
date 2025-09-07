
`include "mips_defines.vh"
`timescale 1ns/1ns

module control_unit (
    input  [31:0] instruction,

    output reg        RegDst,
    output reg        ALUSrc,
    output reg        ALULUIen, 
    output reg        SignExtend_Dmemory_out,  
    output reg  [1:0] MemtoReg,
    output reg        RegWrite,
    output reg        MemRead,
    output reg        MemWrite,
    output reg        Branch,
    output reg   [1:0] MemWidth,
    output reg [1:0]  Jump,
    output reg [1:0]  pc_source,
    output reg [4:0]  ALUControl
);

    wire [5:0] opcode = instruction[31:26];
    wire [5:0] funct  = instruction[5:0];

    always @(*) begin
        // Default values
        RegDst=1'b0;ALUSrc=1'b0;MemtoReg=2'b00;RegWrite=1'b0;MemRead=1'b0;MemWrite=1'b0;Branch=1'b0;Jump=2'b00;pc_source = 2'b00;
        ALUControl = 5'b00000; MemWidth = 2'b00; ALULUIen = 1'b0; SignExtend_Dmemory_out = 1'b0;

        case (opcode)
            `OP_RTYPE: begin
                RegDst   = 1'b1;     // Write to the 'rd' field
                ALUSrc   = 1'b0;     // Second ALU operand is from register file
                MemtoReg = 2'b00;     // Write-back data is from ALU result
                RegWrite = 1'b1;      // R-type instructions write to a register
                pc_source = 2'b00;    // PC+4 selected by default 

                // Nested case to decode the specific ALU operation from the 'funct' field
                case (funct)
                    `FUNCT_ADD:  ALUControl = `ALU_ADD;
                    `FUNCT_ADDU: ALUControl = `ALU_ADDU;
                    `FUNCT_SUB:  ALUControl = `ALU_SUB;
                    `FUNCT_SUBU: ALUControl = `ALU_SUBU;
                    `FUNCT_AND:  ALUControl = `ALU_AND;
                    `FUNCT_OR:   ALUControl = `ALU_OR;
                    `FUNCT_XOR:  ALUControl = `ALU_XOR;
                    `FUNCT_NOR:  ALUControl = `ALU_NOR;
                    `FUNCT_SLT:  ALUControl = `ALU_SLT;
                    `FUNCT_SLTU: ALUControl = `ALU_SLTU;
                    `FUNCT_SLL:  ALUControl = `ALU_SLL;
                    `FUNCT_SRL:  ALUControl = `ALU_SRL;
                    `FUNCT_SRA:  ALUControl = `ALU_SRA;
                    `FUNCT_SLLV: ALUControl = `ALU_SLLV;
                    `FUNCT_SRLV: ALUControl = `ALU_SRLV;
                    `FUNCT_SRAV: ALUControl = `ALU_SRAV;
                     default:    ALUControl = 5'b00000; // Undefined R-type

                endcase
            end

            // --- I-Type Instructions ---
            `OP_LW: begin
                RegDst     = 1'b0;     // Write to the 'rt' field
                ALUSrc     = 1'b1;     // Second ALU operand is the immediate
                MemtoReg   = 2'b01;     // Write-back data is from memory
                RegWrite   = 1'b1;     // lw writes to a register
                MemRead    = 1'b1; 
                MemWidth = 2'b10;    // lw READS from memory
                ALUControl = `ALU_ADDU;  // ALU must add for address calculation
            end
             `OP_LH: begin
                RegDst     = 1'b0;     // Write to the 'rt' field
                ALUSrc     = 1'b1;     // Second ALU operand is the immediate
                MemtoReg   = 2'b01;     // Write-back data is from memory
                RegWrite   = 1'b1;     // lw writes to a register
                MemRead    = 1'b1;      // lw READS from memory
                MemWidth = 2'b01;     
                SignExtend_Dmemory_out = 1'b1;
                ALUControl = `ALU_ADDU;  // ALU must add for address calculation
             end
            `OP_LHU: begin
                RegDst     = 1'b0;     // Write to the 'rt' field
                ALUSrc     = 1'b1;     // Second ALU operand is the immediate
                MemtoReg   = 2'b01;     // Write-back data is from memory
                RegWrite   = 1'b1;     // lw writes to a register
                MemRead    = 1'b1;      // lw READS from memory
                MemWidth = 2'b01;     
                SignExtend_Dmemory_out = 1'b0;
                ALUControl = `ALU_ADDU;  // ALU must add for address calculation

            end
             `OP_LB: begin
                RegDst     = 1'b0;     // Write to the 'rt' field
                ALUSrc     = 1'b1;     // Second ALU operand is the immediate
                MemtoReg   = 2'b01;     // Write-back data is from memory
                RegWrite   = 1'b1;     // lw writes to a register
                MemRead    = 1'b1;     // lw READS from memory
                MemWidth = 2'b00;  
                SignExtend_Dmemory_out = 1'b1; 
                ALUControl = `ALU_ADDU;  // ALU must add for address calculation
            end
            `OP_LBU: begin
                RegDst     = 1'b0;     // Write to the 'rt' field
                ALUSrc     = 1'b1;     // Second ALU operand is the immediate
                MemtoReg   = 2'b01;     // Write-back data is from memory
                RegWrite   = 1'b1;     // lw writes to a register
                MemRead    = 1'b1;     // lw READS from memory
                MemWidth = 2'b00;  
                SignExtend_Dmemory_out = 1'b0; 
                ALUControl = `ALU_ADDU;  // ALU must add for address calculation
            end
            `OP_SW: begin
                ALUSrc     = 1'b1;     // Second ALU operand is the immediate
                MemWrite   = 1'b1;
                MemWidth = 2'b10;     // sw WRITES to memory
                ALUControl = `ALU_ADDU;  // ALU must add for address calculation
            end
            `OP_SH: begin
                ALUSrc     = 1'b1;     // Second ALU operand is the immediate
                MemWrite   = 1'b1;
                MemWidth = 2'b01;     // sw WRITES to memory
                SignExtend_Dmemory_out = 1'b1;
                ALUControl = `ALU_ADDU;  // ALU must add for address calculation
            end
            `OP_SB: begin
                ALUSrc     = 1'b1;     // Second ALU operand is the immediate
                MemWrite   = 1'b1;     // sw WRITES to memory
                MemWidth = 2'b00;     
                SignExtend_Dmemory_out = 1'b1;
                ALUControl = `ALU_ADDU;  // ALU must add for address calculation
            end
            `OP_BEQ: begin
                ALUSrc     = 1'b0;     // Compare two registers
                Branch     = 1'b1;     // This is a branch instruction
                ALUControl = `ALU_SUBU;  // ALU subtracts to check for equality (Zero flag)
                pc_source = 2'b01; // = 01 FOR BRANCH INSTRUCTIONS
            end
            `OP_BNE: begin
                ALUSrc     = 1'b0;     // Compare two registers
                Branch     = 1'b1;     // This is a branch instruction
                ALUControl = `ALU_SUBU; // ALU subtracts to check for equality
                pc_source = 2'b01;  // = 01 FOR BRANCH INSTRUCTIONS 
            end
            `OP_ADDI: begin
                RegDst     = 1'b0;
                ALUSrc     = 1'b1;
                RegWrite   = 1'b1;
                ALUControl = `ALU_ADD;
            end
            `OP_ADDIU: begin
                RegDst     = 1'b0;
                ALUSrc     = 1'b1;
                RegWrite   = 1'b1;
                ALUControl = `ALU_ADDU;
            end
            `OP_SLTI: begin
                RegDst     = 1'b0;
                ALUSrc     = 1'b1;
                RegWrite   = 1'b1;
                ALUControl = `ALU_SLT;
                end
            `OP_SLTIU: begin
                RegDst     = 1'b0;
                ALUSrc     = 1'b1;
                RegWrite   = 1'b1;
                ALUControl = `ALU_SLTU;
            end
            `OP_ANDI: begin
                RegDst     = 1'b0;
                ALUSrc     = 1'b1;
                RegWrite   = 1'b1;
                ALUControl = `ALU_AND;
            end
            `OP_ORI: begin
                RegDst     = 1'b0;
                ALUSrc     = 1'b1;
                RegWrite   = 1'b1;
                ALUControl = `ALU_OR;
                end
            `OP_XORI: begin
                RegDst     = 1'b0;
                ALUSrc     = 1'b1;
                RegWrite   = 1'b1;
                ALUControl = `ALU_XOR;
            end
           // RECHECK LUI
            `OP_LUI: begin
                RegDst     = 1'b0;
                ALUSrc     = 1'b1;
                RegWrite   = 1'b1;
                ALULUIen = 1'b1;
                ALUControl = `ALU_LUI;
            end

            // --- J-Type Instructions ---
            `OP_J: begin
                Jump = 2'b01;
                pc_source = 2'b10; // = 01 FOR BRANCH INSTRUCTIONS
            end
            `OP_JAL: begin
                RegWrite = 1'b1;     // jal writes the return address to $ra
                Jump     = 2'b10;
                MemtoReg = 2'b10;
                pc_source = 2'b10; // = 01 FOR BRANCH INSTRUCTIONS
            end
        
            // --- Default Case for any other opcode ---
            default: begin
                // All signals remain at their safe, default values
            end
        endcase
    end

endmodule