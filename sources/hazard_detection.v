//DONE
/**********************************************************************************
Detects load-use data hazards and control hazards, and generates
*the necessary stall and flush signals for the pipeline.
**********************************************************************************/
`include "mips_defines.vh"
`timescale 1ns/1ns

module hazard_detection_unit (
    // Inputs
    input [4:0] rs_ID, rt_ID,      // Source registers of instruction in ID stage
    input [4:0] rt_EX,             // Destination register of instruction in EX stage
    input       MemRead_EX,        // Is the instruction in EX a load?
    input       Branch_EX,         // Is the instruction in EX a branch?
    input       Zero_EX,           // ALU Zero flag from EX stage (for beq)

    // Outputs to control the pipeline
    output reg PC_write_enable,
    output reg IF_ID_write_enable,
    output reg ID_EX_flush
);
  
  
    always @(*) begin
        // Default state: no hazards
        PC_write_enable    = 1'b1;
        IF_ID_write_enable = 1'b1;
        ID_EX_flush        = 1'b0;

        // 1. Load-Use Data Hazard Detection
        // If the instruction in EX is a load (MemRead_EX) and its destination
        // register (rt_EX) is a source for the instruction in ID, we must stall.

        if (MemRead_EX && ((rt_EX == rs_ID) || (rt_EX == rt_ID))) 
        begin

            PC_write_enable    = 1'b0; // Stall the PC
            IF_ID_write_enable = 1'b0; // Stall the IF/ID register (insert bubble)
            ID_EX_flush        = 1'b1; // Flush the instruction in EX (becomes NOP)
        end

        // 2. Control Hazard (Branch Taken)
        // If a branch is taken in the EX stage, flush the IF/ID register.
        if (Branch_EX && Zero_EX) 
        begin
            IF_ID_write_enable = 1'b1; // Allow the correct instruction to enter ID
            ID_EX_flush        = 1'b1; // Flush the incorrectly fetched instruction
        end
    end
endmodule