//DONE

/**********************************************************************************
* Description: The final pipeline register between the Memory (MEM) and Write
*              Back (WB) stages. It latches the data read from memory (for loads)
*              and the ALU result (for arithmetic ops), along with the final
*              control signals needed for the write-back operation.
**********************************************************************************/

`include "mips_defines.vh"
`timescale 1ns/1ns

module mem_wb_register (
    // Inputs from MEM Stage
    input         clk,
    input         reset,
    // Control Signals from MEM
    input         RegWrite_in, SignExtend_Dmemory_in, 
    input  [1:0]  MemtoReg_in,
    input  [1:0]  MemWidth_in,
    // Data from MEM
     input  [31:0] pc_plus_4_in,
    input  [31:0] read_data_in, 
    input  [31:0] alu_result_in,
    input  [4:0]  write_register_address_in,

    // Outputs to WB Stage
    output reg        RegWrite_out, SignExtend_Dmemory_out,
    output reg [1:0]  MemtoReg_out,
    output reg [1:0]  MemWidth_out,
    output reg [31:0] read_data_out,
    output reg [31:0] pc_plus_4_out, 
    output reg [31:0] alu_result_out,
    output reg [4:0]  write_register_address_out
);

    // Synchronous logic to latch inputs to outputs on the clock edge.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // On reset, clear control signals to a safe state.
            RegWrite_out <= 1'b0;
            MemtoReg_out <= 2'b0;
            MemWidth_out <= 2'b0;
            SignExtend_Dmemory_out <= 1'b0;
            // Clear data values.
            read_data_out <= 32'b0;
            pc_plus_4_out <= 32'b0;
            alu_result_out <= 32'b0;
            write_register_address_out <= 5'b0;
        end 
        else 
        begin
            // On a normal clock cycle, pass all inputs through to the outputs.
            RegWrite_out <= RegWrite_in;
            MemtoReg_out <= MemtoReg_in;
            pc_plus_4_out <= pc_plus_4_in;
            SignExtend_Dmemory_out <= SignExtend_Dmemory_in;
            MemWidth_out <= MemWidth_in;
            read_data_out <= read_data_in;
            alu_result_out <= alu_result_in;
            write_register_address_out <= write_register_address_in;
        end
    end

endmodule