`timescale 1ns / 1ps
`include "defines.sv"

module ControlUnit (
    input logic [31:0] instrCode,
    output logic regFileWe,
    output logic [1:0] alu_Control
);
    wire [6:0] opcode = instrCode[6:0];
    wire [3:0] operators = {
        instrCode[30], instrCode[14:12]
    };  // {func7[5] funct3}

    always_comb begin : we
        regFileWe = 0;
        case (opcode)
            `R_Type: regFileWe = 1'b1;
        endcase
    end

    always_comb begin : opsel
        alu_Control = 2'bx;
        case (opcode)
            `R_Type: alu_Control = operators;  // {func7[5],func3}
        endcase
    end
endmodule
