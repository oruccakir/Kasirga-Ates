// File: definitions.vh
// Purpose: Contains definitions for the pipeline processor.

// Control signals for registers
`define INTEGER_REGISTER        2'b00
`define FLOAT_REGISTER          2'b01
`define CSR_REGISTER            2'b10
`define NONE_REGISTER           2'b11
// Control Signals for ALU operations
`define ALU_ADD                 5'h0
`define ALU_SUB                 5'h1
`define ALU_XOR                 5'h2
`define ALU_OR                  5'h3
`define ALU_AND                 5'h4
`define ALU_SLL                 5'h5
`define ALU_SRL                 5'h6
`define ALU_SRA                 5'h7
`define ALU_SLT                 5'h8
`define ALU_SLTU                5'h9
`define ALU_ADDI                5'ha
`define ALU_SLTI                5'hb
`define ALU_SLTIU               5'hc
`define ALU_XORI                5'hd
`define ALU_ORI                 5'he
`define ALU_ANDI                5'hf
`define ALU_SLLI                5'h10
`define ALU_SRLI                5'h11
`define ALU_SRAI                5'h12

// Control Signals integer multiplication and division operations
`define INT_MUL                 4'h0
`define INT_MULH                4'h1
`define INT_MULHSU              4'h2
`define INT_MULHU               4'h3
`define INT_DIV                 4'h4
`define INT_DIVU                4'h5
`define INT_REM                 4'h6
`define INT_REMU                4'h7


// Control Signals for Memory operations
// for integer memory operations
`define MEM_LOAD                3'b000
`define MEM_STORE               3'b001
// for floating point memory operations
`define FMEM_LOAD               3'b010
`define FMEM_STORE              3'b011
// for atomic memory operations
`define ATOM_MEM_LOAD           3'b100
`define ATOM_MEM_STORE          3'b101

// Control Signals for Atomic operations
`define ATOM_LOAD               4'h0
`define ATOM_STORE              4'h1
`define ATOM_SWAP               4'h2
`define ATOM_ADD                4'h3
`define ATOM_XOR                4'h4
`define ATOM_AND                4'h5
`define ATOM_OR                 4'h6
`define ATOM_MIN                4'h7
`define ATOM_MAX                4'h8
`define ATOM_MINU               4'h9
`define ATOM_MAXU               4'hA

// Control Signals for floating point operations
`define FLT_LOAD                5'h0
`define FLT_STORE               5'h1
`define FLT_FMADD               5'h2
`define FLT_FMSUB               5'h3
`define FLT_FNMSUB              5'h4
`define FLT_FNMADD              5'h5
`define FLT_FADD                5'h6
`define FLT_FSUB                5'h7
`define FLT_FMUL                5'h8
`define FLT_FDIV                5'h9
`define FLT_FSQRT               5'hA
`define FLT_FSGNJ               5'hB
`define FLT_FSGNJN              5'hC
`define FLT_FSGNJX              5'hD
`define FLT_FMIN                5'hE
`define FLT_FMAX                5'hF
`define FLT_FCVTW               5'h10
`define FLT_FCVTWU              5'h11
`define FLT_FMVXW               5'h12
`define FLT_FEQ                 5'h13
`define FLT_FLT                 5'h14
`define FLT_FLE                 5'h15
`define FLT_FCLASS              5'h16
`define FLT_FCVTSW              5'h17
`define FLT_FCVTSWU             5'h18
`define FLT_FMVWX               5'h19

// Control Signals for bit manipulation operations
`define BT_ANDN                 5'h0
`define BT_CLMUL                5'h1
`define BT_CLMULH               5'h2
`define BT_CLMULR               5'h3
`define BT_CLZ                  5'h4
`define BT_CPOP                 5'h5
`define BT_CTZ                  5'h6
`define BT_MAX                  5'h7
`define BT_MAXU                 5'h8
`define BT_MIN                  5'h9
`define BT_MINU                 5'hA
`define BT_ORCB                 5'hB
`define BT_ORN                  5'hC
`define BT_REV8                 5'hD
`define BT_ROL                  5'hE
`define BT_ROR                  5'hF
`define BT_RORI                 5'h10
`define BT_BCLR                 5'h11
`define BT_BCLRI                5'h12
`define BT_BEXT                 5'h13
`define BT_BEXTI                5'h14
`define BT_BINV                 5'h15
`define BT_BINVI                5'h16
`define BT_BSET                 5'h17
`define BT_BSETI                5'h18
`define BT_SEXT                 5'h19
`define BT_SEXTI                5'h1A
`define BT_SH1ADD               5'h1B
`define BT_SH2ADD               5'h1C
`define BT_SH3ADD               5'h1D
`define BT_XNOR                 5'h1E
`define BT_ZEXT                 5'h1F


// UNIT SELECTION UNIT SELECTION
`define FLOATING_POINT_UNIT             4'h0
`define ARITHMETIC_LOGIC_UNIT           4'h1
`define INTEGER_MULTIPLICATION_UNIT     4'h2
`define INTEGER_DIVISION_UNIT           4'h3
`define BRANCH_RESOLVER_UNIT            4'h4
`define CONTROL_UNIT                    4'h5
`define CONTROL_STATUS_UNIT             4'h6
`define ATOMIC_UNIT                     4'h7
`define BIT_MANIPULATION_UNIT           4'h8
`define MEMORY_UNIT                     4'h9
`define NONE_UNIT                       4'hf

// FLOATING POINT UNIT SELECTION
`define FLOATING_MULTIPLICATION_UNIT    1'b0
`define FLOATING_DIVISION_UNIT          1'b1

// For branhc resolver unit instructions
`define BRANCH_BEQ                      5'h0
`define BRANCH_BNE                      5'h1
`define BRANCH_BLT                      5'h2
`define BRANCH_BGE                      5'h3
`define BRANCH_BLTU                     5'h4
`define BRANCH_BGEU                     5'h5
`define BRANCH_JAL                      5'h6
`define BRANCH_JALR                     5'h7

// For memory instructions
`define MEM_LB                          3'h0
`define MEM_LH                          3'h1
`define MEM_LW                          3'h2
`define MEM_LBU                         3'h3
`define MEM_LHU                         3'h4
`define MEM_SB                          3'h5
`define MEM_SH                          3'h6
`define MEM_SW                          3'h7

`define NONE_LUI                        5'h0


`define BRANCH_TAKEN                    1'b1
`define BRANCH_NOT_TAKEN                1'b0

`define RUN_NONE_UNIT                     11'b00000000000;
`define RUN_FLOATING_POINT_UNIT           11'b10000000000;
`define RUN_ARITHMETIC_LOGIC_UNIT         11'b01000000000;
`define RUN_INTEGER_MULTIPLICATION_UNIT   11'b00100000000;
`define RUN_INTEGER_DIVISION_UNIT         11'b00010000000;
`define RUN_BRANCH_RESOLVER_UNIT          11'b00001000000;
`define RUN_CONTROL_UNIT                  11'b00000100000;
`define RUN_CONTROL_STATUS_UNIT           11'b00000010000;
`define RUN_ATOMIC_UNIT                   11'b00000001000;
`define RUN_BIT_MANIPULATION_UNIT         11'b00000000100;
`define RUN_MEMORY_UNIT                   11'b00000000010;
`define RUN_BRANCH_RESOLVER_AND_ALU       11'b00001000001;
`define RUN_MEMORY_UNIT_AND_ALU           11'b00000000011;


