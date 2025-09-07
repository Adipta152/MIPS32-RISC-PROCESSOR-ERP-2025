/**********************************************************************************
**********************************************************************************/
`include "mips_defines.vh"
`timescale 1ns/1ns

module alu (
    // Inputs
    input  [31:0] OperandA,
    input  [31:0] OperandB,
    input  [4:0]  Shamt,
    input  [4:0]  ALUControl,

    // Outputs
    output [31:0] ALUResult,
    output        Zero,
    output        Overflow
);

    // Internal register to hold the ALU result from the procedural block.
    reg [31:0] ALUResult_reg;
    reg  Overflow_reg;

    assign ALUResult = ALUResult_reg;
    assign Overflow  = Overflow_reg;
    assign Zero = (ALUResult_reg == 32'b0);

    //-------CORE LOGIC----------------------------------------------------------------------

    always @(*) begin

        Overflow_reg = 1'b0; // Default overflow to 0 for non-arithmetic operations.

        case (ALUControl)

            `ALU_AND:  ALUResult_reg = OperandA & OperandB; // DONE
            `ALU_OR:   ALUResult_reg = OperandA | OperandB; // DONE
            `ALU_XOR:  ALUResult_reg = OperandA ^ OperandB; // DONE
            `ALU_NOR:  ALUResult_reg = ~(OperandA | OperandB); // DONE

            // Signed ADD: A + B. Check for overflow.

            `ALU_ADD: begin // DONE
                ALUResult_reg = OperandA + OperandB;
    
                if (OperandA[31] == OperandB[31] && ALUResult_reg[31]!= OperandA[31])
                    Overflow_reg = 1'b1;
                else
                    Overflow_reg = 1'b0;
                        end

            // Unsigned ADD: A + B. No overflow check.
            `ALU_ADDU: ALUResult_reg = OperandA + OperandB; // DONE

            // Signed SUB: A - B. Check for overflow.
            `ALU_SUB: begin // DONE
                ALUResult_reg = OperandA - OperandB;

                if (OperandA[31]!= OperandB[31] && ALUResult_reg[31]!= OperandA[31])
                    Overflow_reg = 1'b1;
                else
                    Overflow_reg = 1'b0;
                        end

            // Unsigned SUB: A - B. No overflow check.
            `ALU_SUBU: ALUResult_reg = OperandA - OperandB; // DONE

            // Set on Less Than (Signed). Use Verilog's signed comparison.
            `ALU_SLT: ALUResult_reg = ($signed(OperandA) < $signed(OperandB))? 32'd1 : 32'd0; // DONE

            // Set on Less Than (Unsigned).
            `ALU_SLTU: ALUResult_reg = (OperandA < OperandB)? 32'd1 : 32'd0; // DONE

            // Shift Left Logical by Shamt amount.
            `ALU_SLL: ALUResult_reg = OperandB << Shamt; // DONE

            // Shift Right Logical by Shamt amount.
            `ALU_SRL: ALUResult_reg = OperandB >> Shamt; // DONE

            // Shift Right Arithmetic by Shamt amount. Use Verilog's arithmetic shift. // DONE
            `ALU_SRA: ALUResult_reg = $signed(OperandB) >>> Shamt;

            // Shift Left Logical Variable (shift amount from lower 5 bits of OperandA).
            `ALU_SLLV: ALUResult_reg = OperandB << OperandA[4:0]; // DONE

            // Shift Right Logical Variable.
            `ALU_SRLV: ALUResult_reg = OperandB >> OperandA[4:0]; // DONE

            // Shift Right Arithmetic Variable.
            `ALU_SRAV: ALUResult_reg = $signed(OperandB) >>> OperandA[4:0]; // DONE

            // Load Upper Immediate. The immediate is already shifted left before
            // entering the ALU, so we just pass OperandB through.
            `ALU_LUI: ALUResult_reg = OperandB; // DONE

            // Rotate Right by Shamt amount.
            //`ALU_ROTR: ALUResult_reg = (OperandB >> Shamt) | (OperandB << (32 - Shamt)); // DONE

            // Rotate Right Variable by OperandA amount.
            //`ALU_ROTRV: ALUResult_reg = (OperandB >> OperandA[4:0]) | (OperandB << (32 - OperandA[4:0])); // DONE

            // Default case to handle unknown ALUControl values.

            default: ALUResult_reg = 32'hxxxxxxxx;
        endcase
    end

endmodule