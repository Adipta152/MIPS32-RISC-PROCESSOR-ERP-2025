/**********************************************************************************
Implements forwarding logic to resolve data hazards. It checks
*              for dependencies between the EX, MEM, and WB stages and controls
*              multiplexers to forward results directly to the ALU.
**********************************************************************************/

`include "mips_defines.vh"
`timescale 1ns/1ns

module forwarding_unit (
    // Inputs from pipeline registers
    input [4:0] rs_EX, rt_EX,           // Source registers in EX stage
    input [4:0] rd_MEM, rd_WB,           // Destination registers in MEM and WB stages
    input       RegWrite_MEM, RegWrite_WB, // Write-enable signals from later stages

    // Outputs to control ALU input multiplexers
    output [1:0] ForwardA, ForwardB
);
    // Forwarding codes:
    // 00: No forwarding (use data from ID/EX register)
    // 01: Forward from MEM/WB register (WB stage result)
    // 10: Forward from EX/MEM register (MEM stage result)

    always @(*) begin
    // **Safe defaults**: No forwarding
    ForwardA = 2'b00;  
    ForwardB = 2'b00;

     // Logic for ForwardA
    if (RegWrite_MEM && (rd_MEM != 5'b0) && (rd_MEM == rs_EX))
        ForwardA = 2'b10;  // MEM Hazard
    else if (RegWrite_WB && (rd_WB != 5'b0) && (rd_WB == rs_EX))
        ForwardA = 2'b01;  // WB Hazard

    // Logic for ForwardB
    if (RegWrite_MEM && (rd_MEM != 5'b0) && (rd_MEM == rt_EX))
        ForwardB = 2'b10;  // MEM Hazard
    else if (RegWrite_WB && (rd_WB != 5'b0) && (rd_WB == rt_EX))
        ForwardB = 2'b01;  // WB Hazard

    end
   
endmodule