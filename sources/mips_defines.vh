`define INST_MEM_SIZE   1024
`define DATA_MEM_SIZE   4294967296

//RTYPE INSTRUCTIONS

`define OP_RTYPE   6'b000000  // For add, sub, and, slt, etc.

//R-TYPE ALU BASED INSTRUCTIONS

`define FUNCT_ADD   6'b100000
`define FUNCT_ADDU  6'b100001
`define FUNCT_SUB   6'b100010
`define FUNCT_SUBU  6'b100011
`define FUNCT_AND   6'b100100
`define FUNCT_OR    6'b100101
`define FUNCT_XOR   6'b100110
`define FUNCT_NOR   6'b100111
`define FUNCT_SLT   6'b101010
`define FUNCT_SLTU  6'b101011
`define FUNCT_SLL   6'b000000
`define FUNCT_SRL   6'b000010
`define FUNCT_SRA   6'b000011
`define FUNCT_SLLV  6'b000100
`define FUNCT_SRLV  6'b000110
`define FUNCT_SRAV  6'b000111
//`define FUNCT_JR    6'b001000;
//`define FUNCT_JALR  6'b001001;


`define ALU_OR     5'b00001
`define ALU_XOR    5'b00010
`define ALU_NOR    5'b00011
`define ALU_ADD    5'b00100  // Signed Add
`define ALU_ADDU   5'b00101  // Unsigned Add
`define ALU_SUB    5'b00110  // Signed Subtract
`define ALU_SUBU   5'b00111  // Unsigned Subtract
`define ALU_SLT    5'b01000  // Set on Less Than (Signed)
`define ALU_SLTU   5'b01001  // Set on Less Than (Unsigned)
`define ALU_SLL    5'b01010  // Shift Left Logical
`define ALU_SRL    5'b01011  // Shift Right Logical
`define ALU_SRA    5'b01100  // Shift Right Arithmetic
`define ALU_SLLV   5'b01101  // Shift Left Logical Variable
`define ALU_SRLV   5'b01110  // Shift Right Logical Variable
`define ALU_SRAV   5'b01111  // Shift Right Arithmetic Variable
`define ALU_AND    5'b10000
`define ALU_LUI    5'b10001  // Load Upper Immediate

//ITYPE INSTRUCTIONS

`define OP_ADDI   6'b001000
`define OP_ADDIU  6'b001001
`define OP_SLTI   6'b001010
`define OP_SLTIU  6'b001011
`define OP_ANDI   6'b001100
`define OP_ORI    6'b001101
`define OP_XORI   6'b001110
`define OP_LUI    6'b001111

//--------------------------
`define OP_BEQ    6'b000100
`define OP_BNE    6'b000101
//`define OP_BLEZ   6'b000110
//`define OP_BGTZ   6'b000111

//----------------------------------
`define OP_LB     6'b100000
`define OP_LH     6'b100001
`define OP_LBU     6'b100100
`define OP_LHU     6'b100101
`define OP_LW     6'b100011
`define OP_SB     6'b101000
`define OP_SH     6'b101001
`define OP_SW     6'b101011


//JTYPE INSTRUCTIONS

`define OP_J    6'b000010
`define OP_JAL  6'b000011

