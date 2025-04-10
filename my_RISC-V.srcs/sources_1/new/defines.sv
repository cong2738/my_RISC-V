//OPCOED
`define R_Type 7'b0110011
`define L_Type 7'b0000011
`define I_Type 7'b0010011
`define S_Type 7'b0100011
`define B_Type 7'b1100011

//R_Type func
`define ADD 4'b0_000
`define SUB 4'b1_000
`define SLL 4'b0_001
`define SRL 4'b0_101
`define SRA 4'b1_101
`define SLT 4'b0_010
`define SLTU 4'b0_011
`define XOR 4'b0_100
`define OR 4'b0_110
`define AND 4'b0_111

//B_Type func
`define BEQ 4'b0_000
`define BNE 4'b0_001
`define BLT 4'b0_100
`define BGE 4'b0_101
`define BLTU 4'b0_110
`define BGEU 4'b0_111

