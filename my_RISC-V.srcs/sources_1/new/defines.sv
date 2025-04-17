// //OPCOED
// typedef enum {
//     R_Type  = 7'b0110011,
//     L_Type  = 7'b0000011,
//     I_Type  = 7'b0010011,
//     S_Type  = 7'b0100011,
//     B_Type  = 7'b1100011,
//     LU_Type = 7'b0110111,
//     AU_Type = 7'b0010111,
//     J_Type  = 7'b1101111,
//     JL_Type = 7'b1100111
// } op_type;

// //func
// typedef enum {
//     ADD  = 4'b0_000,
//     SUB  = 4'b1_000,
//     SLL  = 4'b0_001,
//     SRL  = 4'b0_101,
//     SRA  = 4'b1_101,
//     SLT  = 4'b0_010,
//     SLTU = 4'b0_011,
//     XOR  = 4'b0_100,
//     OR   = 4'b0_110,
//     AND  = 4'b0_111
// } cal_type;

// //B_Type func
// typedef enum {
//     BEQ  = 4'b000,
//     BNE  = 4'b001,
//     BLT  = 4'b100,
//     BGE  = 4'b101,
//     BLTU = 4'b110,
//     BGEU = 4'b111
// } name;

//OPCOED
`define R_Type 7'b0110011
`define L_Type 7'b0000011
`define I_Type 7'b0010011
`define S_Type 7'b0100011
`define B_Type 7'b1100011
`define LU_Type 7'b0110111
`define AU_Type 7'b0010111
`define J_Type  7'b1101111
`define JL_Type 7'b1100111

//func
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
`define BEQ 4'b000
`define BNE 4'b001
`define BLT 4'b100
`define BGE 4'b101
`define BLTU 4'b110
`define BGEU 4'b111

