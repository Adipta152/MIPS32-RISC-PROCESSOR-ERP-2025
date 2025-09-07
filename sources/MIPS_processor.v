/**********************************************************************************
**********************************************************************************/
`include "mips_defines.vh"
`timescale 1ns/1ns

module mips_pipelined (
    input clk,
    input reset
);
    //================================================================
    // Wire Declarations
    //================================================================
    // --- IF Stage ---
    wire [31:0] pc_current; //pc_current is the CURRENT STATE OF PC
    wire [31:0] instruction_IF; //instruction_IF is combinationally driven....IF-ID register latches it in the next posedge
    wire [31:0] pc_plus_4_IF = pc_current + 4;

    // --- ID Stage ---
    wire [31:0] pc_plus_4_ID, instruction_ID;
    wire [31:0] read_data1_ID, read_data2_ID, immediate_extended_ID;
    wire [1:0]  jump_ID, pc_source_ctrl_ID;
    wire        reg_dst_ID, alu_src_ID, reg_write_ID, mem_read_ID, mem_write_ID, branch_ID, ALULUIen_ID,SignExtend_Dmemory_ID;
    wire [1:0]  mem_to_reg_ID, MemWidth_ID;
    wire [4:0]  alu_ctrl_ID;

    // --- EX Stage ---
    wire [31:0] pc_plus_4_EX, read_data1_EX, read_data2_EX, immediate_extended_EX, instruction_EX;
    wire [4:0]  rs_EX, rt_EX, rd_EX;
    wire        reg_dst_EX, alu_src_EX, reg_write_EX, mem_read_EX, mem_write_EX, branch_EX, ALULUIen_EX,SignExtend_Dmemory_EX;
    wire [4:0]  alu_ctrl_EX;
    wire [31:0] alu_operand_a, alu_operand_b, alu_result_EX;
    wire [4:0]  write_register_addr_EX;
    wire        zero_flag_EX,overflow_flag_EX;
    wire [31:0] branch_target_addr_EX = pc_plus_4_EX + (immediate_extended_EX << 2);
    wire [1:0]  forward_a_ctrl, forward_b_ctrl,mem_to_reg_EX, MemWidth_EX,pc_source_ctrl_EX;

    // --- MEM Stage ---
    wire [31:0] pc_plus_4_MEM, alu_result_MEM, store_data_MEM; 
    wire [4:0]  write_register_addr_MEM;
    wire        reg_write_MEM, mem_read_MEM, mem_write_MEM,SignExtend_Dmemory_MEM;
    wire [1:0]  mem_to_reg_MEM, MemWidth_MEM;
    wire [31:0] data_memory_read_data_MEM,dummy_MEM_read_port;

    // --- WB Stage ---
    wire [31:0] pc_plus_4_WB, alu_result_WB, data_memory_read_data_WB; 
    wire [4:0]  write_register_addr_WB;
    wire        reg_write_WB, SignExtend_Dmemory_WB;
    wire [1:0]  mem_to_reg_WB, MemWidth_WB; 
    wire [31:0] write_back_data_WB;

    // --- Hazard Unit Control Wires ---
    wire pc_write_en, if_id_write_en, id_ex_flush_ctrl;
    wire [1:0] pc_source_ctrl;

    //================================================================
    // IF Stage - Instruction Fetch
    //================================================================
    pc_logic PC_UNIT (
    .clk(clk),.reset(reset),.PC_write_enable(pc_write_en),
    .PC_source(pc_source_ctrl_EX),.branch_target_address(branch_target_addr_EX),
    .jump_target_address({pc_plus_4_ID[31:28], instruction_EX[25:0], 2'b00}),
    .pc_out(pc_current)
    );
    /* 
    pc_write_en is usually 1, when hazard comes, it can be 0, comes from hazard detection unit
    */

    instruction_memory IMEM (.addr(pc_current),.instruction(instruction_IF));
    /*
    instruction_IF is combinationally driven....IF-ID register latches it in the next posedge
    */

    //================================================================
    // IF/ID Pipeline Register
    //================================================================
    if_id_register IF_ID_REG (
    .clk(clk),.reset(reset),.stall(!if_id_write_en),.flush(id_ex_flush_ctrl),
    .pc_plus_4_in(pc_plus_4_IF),.instruction_in(instruction_IF),
    .pc_plus_4_out(pc_plus_4_ID),.instruction_out(instruction_ID)
    );
    /* 
    instruction_ID latched here and goes to control unit
    pc_plus_4_IF = pc_current + 4; latched here in pc_plus_4_ID
    instruction_IF connected to I memory output wires.....latched here in instruction_ID
    */

    //================================================================
    // ID Stage - Instruction Decode & Register Fetch
    //================================================================
    control_unit CTRL_UNIT (
    .instruction(instruction_ID),
    .RegDst(reg_dst_ID),.ALUSrc(alu_src_ID),.MemtoReg(mem_to_reg_ID),.ALULUIen(ALULUIen_ID),
    .RegWrite(reg_write_ID),.MemRead(mem_read_ID),.MemWrite(mem_write_ID),.SignExtend_Dmemory_out(SignExtend_Dmemory_ID),
    .Branch(branch_ID),.Jump(jump_ID),.ALUControl(alu_ctrl_ID), .pc_source(pc_source_ctrl_ID), .MemWidth(MemWidth_ID)
  );
 
    reg_file REG_FILE (
    .clk(clk),.RegWrite(reg_write_WB),.reset(reset),
    .ReadRegister1(instruction_ID[25:21]),.ReadRegister2(instruction_ID[20:16]),
    .WriteRegister(write_register_addr_WB),.WriteData(write_back_data_WB),
    .ReadData1(read_data1_ID),.ReadData2(read_data2_ID)
    );
 
    sign_extend SIGN_EXT (
    .immediate_in(instruction_ID[15:0]),
    .immediate_out(immediate_extended_ID)
    );

    hazard_detection_unit HAZARD_UNIT (
    .rs_ID(instruction_ID[25:21]),.rt_ID(instruction_ID[20:16]),
    .rt_EX(rt_EX),.MemRead_EX(mem_read_EX),
    .Branch_EX(branch_EX),.Zero_EX(zero_flag_EX),
    .PC_write_enable(pc_write_en),.IF_ID_write_enable(if_id_write_en),
    .ID_EX_flush(id_ex_flush_ctrl)
    );

    //================================================================
    // ID/EX Pipeline Register
    //================================================================
    id_ex_register ID_EX_REG (
    .clk(clk),
    .reset(reset),
    .flush(id_ex_flush_ctrl),
    
    // Control Signals In
    .RegDst_in(reg_dst_ID),
    .ALUSrc_in(alu_src_ID),
    .RegWrite_in(reg_write_ID),
    .MemRead_in(mem_read_ID),
    .MemWrite_in(mem_write_ID),
    .Branch_in(branch_ID),
    .Jump_in(jump_ID),
    .MemWidth_in(MemWidth_ID),
    .MemtoReg_in(mem_to_reg_ID),
    .ALUControl_in(alu_ctrl_ID),
    .ALULUIen_in(ALULUIen_ID),
    .SignExtend_Dmemory_in(SignExtend_Dmemory_ID),
    .pc_source_ctrl_in(pc_source_ctrl_ID),
    
    // Data In
    .pc_plus_4_in(pc_plus_4_ID),
    .read_data1_in(read_data1_ID),
    .read_data2_in(read_data2_ID),
    .immediate_in(immediate_extended_ID),
    .rs_in(instruction_ID[25:21]),
    .rt_in(instruction_ID[20:16]),
    .rd_in(instruction_ID[15:11]),
    .instruction_in(instruction_ID),
    
    // Control Signals Out
    .RegDst_out(reg_dst_EX),
    .ALUSrc_out(alu_src_EX),
    .RegWrite_out(reg_write_EX),
    .MemRead_out(mem_read_EX),
    .MemWrite_out(mem_write_EX),
    .Branch_out(branch_EX),
    .Jump_out(jump_EX),
    .MemWidth_out(MemWidth_EX),
    .MemtoReg_out(mem_to_reg_EX),
    .ALUControl_out(alu_ctrl_EX),
    .ALULUIen_out(ALULUIen_EX),
    .SignExtend_Dmemory_out(SignExtend_Dmemory_EX),
    .pc_source_ctrl_out(pc_source_ctrl_EX),
    
    // Data Out
    .pc_plus_4_out(pc_plus_4_EX),
    .read_data1_out(read_data1_EX),
    .read_data2_out(read_data2_EX),
    .immediate_out(immediate_extended_EX),
    .rs_out(rs_EX),
    .rt_out(rt_EX),
    .rd_out(rd_EX),
    .instruction_out(instruction_EX)
);

    //================================================================
    // EX Stage - Execute / Address Calculation
    //================================================================
    assign write_register_addr_EX = (reg_dst_EX)? rd_EX : rt_EX;

    assign alu_operand_a = (forward_a_ctrl == 2'b10)? alu_result_MEM :
                           (forward_a_ctrl == 2'b01)? write_back_data_WB :
                                                       read_data1_EX;
    assign alu_operand_b = (alu_src_EX)? ((ALULUIen_EX) ? ({instruction_EX[15:0],16'b0}) : immediate_extended_EX) :
                           (forward_b_ctrl == 2'b10)? alu_result_MEM :
                           (forward_b_ctrl == 2'b01)? write_back_data_WB :
                                                       read_data2_EX;

    alu ALU_UNIT (
    .OperandA(alu_operand_a),.OperandB(alu_operand_b),
    .Shamt(instruction_EX[10:6]),.ALUControl(alu_ctrl_EX),
    .ALUResult(alu_result_EX),.Zero(zero_flag_EX),.Overflow(overflow_flag_EX)
    );

    forwarding_unit FWD_UNIT (
    .rs_EX(rs_EX),.rt_EX(rt_EX),
    .rd_MEM(write_register_addr_MEM),.rd_WB(write_register_addr_WB),
    .RegWrite_MEM(reg_write_MEM),.RegWrite_WB(reg_write_WB),
    .ForwardA(forward_a_ctrl),.ForwardB(forward_b_ctrl)
    );

    //================================================================
    // EX/MEM Pipeline Register
    //================================================================
    ex_mem_register EX_MEM_REG (
    .clk(clk),.reset(reset), .SignExtend_Dmemory_in(SignExtend_Dmemory_EX),
    .RegWrite_in(reg_write_EX),.MemtoReg_in(mem_to_reg_EX),
    .MemRead_in(mem_read_EX),.MemWrite_in(mem_write_EX), .MemWidth_in(MemWidth_EX),
    .pc_plus_4_in(pc_plus_4_EX), .SignExtend_Dmemory_out(SignExtend_Dmemory_MEM),
    .alu_result_in(alu_result_EX),.store_data_in(read_data2_EX),
    .write_register_address_in(write_register_addr_EX),
    .RegWrite_out(reg_write_MEM),.MemtoReg_out(mem_to_reg_MEM),
    .MemRead_out(mem_read_MEM),.MemWrite_out(mem_write_MEM),
    .pc_plus_4_out(pc_plus_4_MEM), .MemWidth_out(MemWidth_MEM),
    .alu_result_out(alu_result_MEM),.store_data_out(store_data_MEM),
    .write_register_address_out(write_register_addr_MEM)
    );

    //================================================================
    // MEM Stage - Memory Access
    //================================================================
    data_memory DMEM (
    .clk(clk),.reset(reset),.MemWidth(MemWidth_MEM),.SignExtend(SignExtend_Dmemory_MEM),
    .MemWrite(mem_write_MEM),.MemRead(mem_read_MEM),
    .Address1(alu_result_MEM),.Address2(32'b0),
    .WriteAddress(alu_result_MEM),.WriteData(store_data_MEM),
    .ReadData1(data_memory_read_data_MEM),.ReadData2(dummy_MEM_read_port)
    );

    //================================================================
    // MEM/WB Pipeline Register
    //================================================================
    mem_wb_register MEM_WB_REG (
    .clk(clk),.reset(reset),
    .RegWrite_in(reg_write_MEM),.MemtoReg_in(mem_to_reg_MEM), .SignExtend_Dmemory_in(SignExtend_Dmemory_MEM),
    .pc_plus_4_in(pc_plus_4_MEM), .SignExtend_Dmemory_out(SignExtend_Dmemory_WB),
    .read_data_in(data_memory_read_data_MEM),.alu_result_in(alu_result_MEM),
    .write_register_address_in(write_register_addr_MEM), .MemWidth_in(MemWidth_MEM),
    .RegWrite_out(reg_write_WB),.MemtoReg_out(mem_to_reg_WB),
    .pc_plus_4_out(pc_plus_4_WB), .MemWidth_out(MemWidth_WB),
    .read_data_out(data_memory_read_data_WB),.alu_result_out(alu_result_WB),
    .write_register_address_out(write_register_addr_WB)
    );

    //================================================================
    // WB Stage - Write Back
    //================================================================
    // This MUX selects between the ALU result and the PC+4 value
    wire [31:0] jal_or_alu_result = (mem_to_reg_WB == 2'b10)? pc_plus_4_WB : alu_result_WB;

    // This final MUX selects between the memory data and the output of the first MUX
    assign write_back_data_WB = (mem_to_reg_WB == 2'b01)? data_memory_read_data_WB : jal_or_alu_result;
    
endmodule

