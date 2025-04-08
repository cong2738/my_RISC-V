`timescale 1ns / 1ps

module rom (
    input  logic [31:0] addr,
    output logic [31:0] data
);
    logic [31:0] rom[0:15];
    initial begin
        //          _funcn7 _rs2  _rs1  _f3 _rd   _opcode;
        rom[0] = 32'b0000000_00001_00010_000_00100_0110011;  //add x4, x2, x1
        rom[1] = 32'b0100000_00001_00010_000_00101_0110011;  //add x4, x2, x1
    end
    assign data = rom[addr[31:2]];//0 4 8 16을 0,1,2,3으로 바꿔주기 위해 2비트 시프트


endmodule
