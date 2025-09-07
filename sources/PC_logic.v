//DONE
// CHECK PC_source, branch target, jump target
`include "mips_defines.vh"
`timescale 1ns/1ns

module pc_logic (
    input         clk,
    input         reset,
    input         PC_write_enable, // From Hazard Unit to enable/stall the PC
    input  [1:0]  PC_source,       // Selects the next PC source (comes from where)
    input  [31:0] branch_target_address,
    input  [31:0] jump_target_address,
    output [31:0] pc_out
);
    reg [31:0] pc_reg; // ACTUAL PROGRAM COUNTER
    assign pc_out = pc_reg;

    parameter PC_PLUS_4   = 2'b00;
    parameter PC_BRANCH   = 2'b01;
    parameter PC_JUMP     = 2'b10;
    parameter PC_JUMP_REG = 2'b11; // For jr (LATER)

    wire [31:0] pc_plus_4 = pc_reg + 32'd4;
    wire [31:0] next_pc;

    // Combinational logic to select the source for the next PC value
    assign next_pc = (PC_source == PC_BRANCH)? branch_target_address :
                     (PC_source == PC_JUMP)  ? jump_target_address :
                                                pc_plus_4; // Default is PC+4

    // Synchronous logic to update the PC register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_reg <= 32'h00000000; // Start execution at address 0
        end 
        else if (PC_write_enable) begin
            pc_reg <= next_pc;
        end
        // If PC_write_enable is low, the PC is stalled (holds its value).
    end

    
endmodule