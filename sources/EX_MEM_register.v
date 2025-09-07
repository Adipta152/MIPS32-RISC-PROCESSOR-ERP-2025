/**********************************************************************************
* Description: The pipeline register between the Execute (EX) and Memory (MEM)
* stages. This corrected version properly pipelines the PC+4 value
* required for the JAL instruction.
**********************************************************************************/

`include "mips_defines.vh"
`timescale 1ns/1ns

module ex_mem_register (
    // Inputs from EX Stage
    input         clk,
    input         reset,
    // Control Signals from EX
    input         RegWrite_in,
    input  [1:0]  MemtoReg_in,
    input  [1:0]  MemWidth_in,
    input         MemRead_in,
    input         MemWrite_in, SignExtend_Dmemory_in,
    // Data from EX
    input  [31:0] pc_plus_4_in, 
    input  [31:0] alu_result_in,
    input  [31:0] store_data_in,
    input  [4:0]  write_register_address_in,

    // Outputs to MEM Stage
    output reg        RegWrite_out,
    output reg [1:0]  MemtoReg_out,
    output reg [1:0]  MemWidth_out,
    output reg        MemRead_out,
    output reg        MemWrite_out, SignExtend_Dmemory_out,
    output reg [31:0] pc_plus_4_out, 
    output reg [31:0] alu_result_out,
    output reg [31:0] store_data_out,
    output reg [4:0]  write_register_address_out
);

    // Synchronous logic to latch inputs to outputs on the clock edge.
    always @(posedge clk or posedge reset)
    begin
        if (reset) begin
            // On reset, clear all control signals to a safe, non-destructive state.
            RegWrite_out <= 1'b0;
            MemtoReg_out <= 2'b0;
            MemRead_out  <= 1'b0;
            MemWrite_out <= 1'b0;
            MemWidth_out <= 2'b0;
            SignExtend_Dmemory_out <= 1'b0;
           
            pc_plus_4_out <= 32'b0; 
            alu_result_out <= 32'b0;
            store_data_out <= 32'b0;
            write_register_address_out <= 5'b0;
        end
        else
        begin
            // On a normal clock cycle, pass all inputs through to the outputs.
            RegWrite_out <= RegWrite_in;
            MemtoReg_out <= MemtoReg_in;
            MemRead_out  <= MemRead_in;
            MemWrite_out <= MemWrite_in;
            MemWidth_out <= MemWidth_in;
            pc_plus_4_out <= pc_plus_4_in; 
            alu_result_out <= alu_result_in;
            store_data_out <= store_data_in;
            SignExtend_Dmemory_out <= SignExtend_Dmemory_in;
            write_register_address_out <= write_register_address_in;
        end
    end

endmodule