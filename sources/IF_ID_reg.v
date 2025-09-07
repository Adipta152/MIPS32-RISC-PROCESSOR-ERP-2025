//DOUBT IN FLUSHING MECHANISM

`include "mips_defines.vh"
`timescale 1ns/1ns

module if_id_register (
    input         clk, reset, stall, flush,
    input  [31:0] pc_plus_4_in, instruction_in,
    output reg [31:0] pc_plus_4_out, instruction_out);
    
    always @(posedge clk or posedge reset) begin
        if (reset || flush) 
        begin
            pc_plus_4_out   <= 32'b0; 
            instruction_out <= 32'b0; // Flush to a NOP (sll $0, $0, 0)
        end 
        
        else if (!stall) 
        begin
            pc_plus_4_out   <= pc_plus_4_in;
            instruction_out <= instruction_in; // instruction_out is the INSTRUCTION REGISTER
        end
        // If stalled, registers hold their current values.
    end
endmodule