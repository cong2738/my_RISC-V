`timescale 1ns / 1ps
`include "defines.sv"

module ControlUnit (
    input  logic [31:0] instrCode,
    output logic        regFileWe,
    output logic [ 3:0] alu_Control,
    output logic        aluSrcMuxSel,
    output logic        dataWe
);
    wire [6:0] opcode = instrCode[6:0];
    wire [3:0] operators = {
        instrCode[30], instrCode[14:12]
    };  // {func7[5] funct3}

    logic [2:0] signals;
    assign {regFileWe, aluSrcMuxSel, dataWe} = signals;

    always_comb begin : we
        signals = 3'b0;
        case (opcode)   //        F_A_D
            `R_Type: signals = 3'b1_0_0;
            `S_Type: signals = 3'b0_1_1;
        endcase
    end

    always_comb begin : opsel
        alu_Control = 2'bx;
        case (opcode)
            `R_Type: alu_Control = operators;  //   {func7[5],func3}
            `S_Type: alu_Control = `ADD;  //        {3'b000}
        endcase
    end
endmodule
