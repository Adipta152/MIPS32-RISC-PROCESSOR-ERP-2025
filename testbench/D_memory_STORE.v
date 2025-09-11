//DONE
`include "mips_defines.vh"
`timescale 1ns / 1ns
//***********************************************************************************

module data_memory (
    // Inputs
    input clk,
    input MemWrite,
    input reset,
    input MemRead,
    input [1:0] MemWidth,
    input SignExtend,
    input [31:0] Address1,
    input [31:0] Address2,
    input [31:0] WriteAddress,
    input [31:0] WriteData,
    
    // Outputs
    output [31:0] ReadData1,
    output [31:0] ReadData2
);

    parameter WIDTH_BYTE = 2'b00;
    parameter WIDTH_HALF = 2'b01;
    parameter WIDTH_WORD = 2'b10;
    parameter ADDR_WIDTH = 32;
    integer i;
    
    reg [7:0] d_memory [`DATA_MEM_SIZE-1:0];

    wire [ADDR_WIDTH-1:0] addr1_idx, addr2_idx, write_addr_idx;    
    assign addr1_idx = Address1[ADDR_WIDTH-1:0];     
    assign addr2_idx = Address2[ADDR_WIDTH-1:0];      
    assign write_addr_idx = WriteAddress[ADDR_WIDTH-1:0]; 
    
    // --- Synchronous Write Logic ---
    always @(negedge clk or posedge reset) begin
        if (reset) begin
        for (i = 0; i < `DATA_MEM_SIZE; i = i + 1) begin
            d_memory[i] = 8'b0;
        end
        end

        else if (MemWrite) begin
            case (MemWidth)
                // Store Byte (sb) - can write to any byte address
                WIDTH_BYTE: begin
                    if (WriteAddress < `DATA_MEM_SIZE) begin
                        d_memory[write_addr_idx] <= WriteData[7:0];
                    end
                end
                
                // Store Half-word (sh) - must be aligned to 2-byte boundary
                WIDTH_HALF: begin
                    if (write_addr_idx[0] == 1'b0 && (WriteAddress + 1) < `DATA_MEM_SIZE) begin
                        
                        d_memory[write_addr_idx] <= WriteData[15:8];     // MSB
                        d_memory[write_addr_idx + 1] <= WriteData[7:0];  // LSB
                    end
                end
                
                // Store Word (sw) - must be aligned to 4-byte boundary  
                WIDTH_WORD: begin
                    if (write_addr_idx[1:0] == 2'b00 && (WriteAddress + 3) < `DATA_MEM_SIZE) begin
                        
                        d_memory[write_addr_idx] <= WriteData[31:24];     // MSB
                        d_memory[write_addr_idx + 1] <= WriteData[23:16];
                        d_memory[write_addr_idx + 2] <= WriteData[15:8];
                        d_memory[write_addr_idx + 3] <= WriteData[7:0];   // LSB
                    end
                end
            endcase
        end
    end
    
    // --- Asynchronous Read Logic for Port 1 ---
    reg [31:0] read_data1_reg;
    
    always @(*) begin
        if (!MemRead) begin
            read_data1_reg = 32'hzzzzzzzz;  // Return unknown when MemRead is disabled
        end else begin
            case (MemWidth)
                WIDTH_BYTE: begin
                    if (Address1 < `DATA_MEM_SIZE) begin
                        if (SignExtend) begin
                            read_data1_reg = {{24{d_memory[addr1_idx][7]}}, d_memory[addr1_idx]};
                        end else begin
                            read_data1_reg = {24'b0, d_memory[addr1_idx]};
                        end
                    end else begin
                        read_data1_reg = 32'h00000000;
                    end
                end
                
                WIDTH_HALF: begin
                    if (addr1_idx[0] == 1'b0 && (Address1 + 1) < `DATA_MEM_SIZE) begin
                        
                        if (SignExtend) begin
                            read_data1_reg = {{16{d_memory[addr1_idx][7]}}, 
                                            d_memory[addr1_idx], d_memory[addr1_idx + 1]};
                        end else begin
                            read_data1_reg = {16'b0, d_memory[addr1_idx], d_memory[addr1_idx + 1]};
                        end
                    end else begin
                        read_data1_reg = 32'h00000000;
                    end
                end
                
                WIDTH_WORD: begin
                    if (addr1_idx[1:0] == 2'b00 && (Address1 + 3) < `DATA_MEM_SIZE) begin
                        
                        read_data1_reg = {d_memory[addr1_idx], 
                                        d_memory[addr1_idx + 1], 
                                        d_memory[addr1_idx + 2],
                                        d_memory[addr1_idx + 3]};
                    end else begin
                        read_data1_reg = 32'h00000000;
                    end
                end
                
                default: read_data1_reg = 32'h00000000;
            endcase
        end
    end
    
    // --- Asynchronous Read Logic for Port 2 ---
    reg [31:0] read_data2_reg;
    
    always @(*) begin
        if (!MemRead) begin
            read_data2_reg = 32'hzzzzzzzz;  // Return unknown when MemRead is disabled
        end else begin
            case (MemWidth)
                WIDTH_BYTE: begin
                    if (Address2 < `DATA_MEM_SIZE) begin
                        if (SignExtend) begin
                            read_data2_reg = {{24{d_memory[addr2_idx][7]}}, d_memory[addr2_idx]};
                        end else begin
                            read_data2_reg = {24'b0, d_memory[addr2_idx]};
                        end
                    end else begin
                        read_data2_reg = 32'h00000000;
                    end
                end
                
                WIDTH_HALF: begin
                    if (addr2_idx[0] == 1'b0 && (Address2 + 1) < `DATA_MEM_SIZE) begin
                        
                        if (SignExtend) begin
                            read_data2_reg = {{16{d_memory[addr2_idx][7]}}, 
                                            d_memory[addr2_idx], d_memory[addr2_idx + 1]};
                        end else begin
                            read_data2_reg = {16'b0, d_memory[addr2_idx], d_memory[addr2_idx + 1]};
                        end
                    end else begin
                        read_data2_reg = 32'h00000000;
                    end
                end
                
                WIDTH_WORD: begin
                    if (addr2_idx[1:0] == 2'b00 && (Address2 + 3) < `DATA_MEM_SIZE) begin
                        
                        read_data2_reg = {d_memory[addr2_idx], 
                                        d_memory[addr2_idx + 1], 
                                        d_memory[addr2_idx + 2],
                                        d_memory[addr2_idx + 3]};
                    end else begin
                        read_data2_reg = 32'h00000000;
                    end
                end
                
                default: read_data2_reg = 32'h00000000;
            endcase
        end
    end

    assign ReadData1 = read_data1_reg;
    assign ReadData2 = read_data2_reg;
    

endmodule
