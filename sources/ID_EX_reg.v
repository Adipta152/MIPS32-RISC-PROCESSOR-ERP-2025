//DONE
`include "mips_defines.vh"
`timescale 1ns/1ns

module id_ex_register(
    input         clk, reset, flush,
    // Control Signals In
    input         RegDst_in, ALUSrc_in, RegWrite_in, MemRead_in, MemWrite_in, Branch_in, ALULUIen_in,SignExtend_Dmemory_in,
    input  [1:0]  Jump_in, MemWidth_in, MemtoReg_in, pc_source_ctrl_in,
    input  [4:0]  ALUControl_in,
    // Data In
    input  [31:0] pc_plus_4_in, read_data1_in, read_data2_in, immediate_in,instruction_in,
    input  [4:0]  rs_in, rt_in, rd_in,
    // Control Signals Out
    output reg        RegDst_out, ALUSrc_out, RegWrite_out, MemRead_out, MemWrite_out, Branch_out, ALULUIen_out,SignExtend_Dmemory_out,
    output reg [1:0]  Jump_out, MemWidth_out, MemtoReg_out, pc_source_ctrl_out,
    output reg [4:0]  ALUControl_out,
    // Data Out
    output reg [31:0] pc_plus_4_out, read_data1_out, read_data2_out, immediate_out, instruction_out,
    output reg [4:0]  rs_out, rt_out, rd_out
);

    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            // Reset all control signals
            RegDst_out <= 1'b0;
            ALUSrc_out <= 1'b0;
            RegWrite_out <= 1'b0;
            MemRead_out <= 1'b0;
            MemWrite_out <= 1'b0;
            Branch_out <= 1'b0;
            ALULUIen_out <= 1'b0;
            SignExtend_Dmemory_out <= 1'b0;
            Jump_out <= 2'b00;
            MemWidth_out <= 2'b00;
            MemtoReg_out <= 2'b00;
            ALUControl_out <= 5'b00000;
            pc_source_ctrl_out <= 2'b00;
            
            
            // Reset all data signals
            pc_plus_4_out <= 32'h00000000;
            read_data1_out <= 32'h00000000;
            read_data2_out <= 32'h00000000;
            immediate_out <= 32'h00000000;
            instruction_out <= 32'h00000000; // can create issues for hazard
            rs_out <= 5'b00000;
            rt_out <= 5'b00000;
            rd_out <= 5'b00000;
            
        end else begin
            // Pass all inputs to outputs
            RegDst_out <= RegDst_in;
            ALUSrc_out <= ALUSrc_in;
            RegWrite_out <= RegWrite_in;
            MemRead_out <= MemRead_in;
            MemWrite_out <= MemWrite_in;
            Branch_out <= Branch_in;
            Jump_out <= Jump_in;
            MemWidth_out <= MemWidth_in;
            MemtoReg_out <= MemtoReg_in;
            ALUControl_out <= ALUControl_in;
            ALULUIen_out <= ALULUIen_in;
            SignExtend_Dmemory_out <= SignExtend_Dmemory_in;
            
            pc_plus_4_out <= pc_plus_4_in;
            read_data1_out <= read_data1_in;
            read_data2_out <= read_data2_in;
            immediate_out <= immediate_in;
            instruction_out <= instruction_in;
            rs_out <= rs_in;
            rt_out <= rt_in;
            rd_out <= rd_in; 
            pc_source_ctrl_out <= pc_source_ctrl_in;
        end
    end
endmodule
