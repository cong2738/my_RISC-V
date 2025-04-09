`timescale 1ns / 1ps

module rom (
    input  logic [31:0] addr,
    output logic [31:0] data
);
    logic [31:0] rom[0:15];
    initial begin
        //          _funcn7 _rs2  _rs1  _f3 _rd   _opcode;      R_Type
        rom[0] = 32'b0000000_00001_00010_000_00100_0110011; //  add x4, x2, x1
        rom[1] = 32'b0100000_00001_00010_000_00101_0110011; //  add x4, x2, x1
        //          _imm    _rs2  _rs1  _f3 _imm5   _opcode;      S_Type
        rom[2] = 32'b0000000_00010_00000_010_01000_0100011; //  sw  x2, 8(ram0);
        //          _imm    _imm  _rs1  _f3 _rd   _opcode;      L_Type
        rom[3] = 32'b0000000_01000_00000_010_00110_0000011; //  lw  x2, 8(ram0);
        //          _imm    _imm  _rs1  _f3 _rd   _opcode;      L_Type
        rom[3] = 32'b0000000_01000_00010_000_00110_0000011; //  addi  rs1 + imm;

    end
    assign data = rom[addr[31:2]];//0 4 8 16을 0,1,2,3으로 바꿔주기 위해 2비트 시프트
endmodule
