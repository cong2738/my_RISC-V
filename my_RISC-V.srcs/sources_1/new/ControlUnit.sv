`timescale 1ns / 1ps

module ControlUnit (
    input logic [31:0] instrCode,
    output logic regFileWe,
    output logic [1:0] alu_Control
);
    wire [6:0] opcode = instrCode[6:0];
    wire [3:0] operator = {
        instrCode[30], instrCode[14:12]
    };  // {func7[5] funct3}

    always_comb begin : we
        regFileWe = 0;
        case (opcode)
            7'b0110011: regFileWe = 1'b1;
        endcase
    end

    always_comb begin : opsel
        alu_Control = 2'bx;
        case (opcode)
            7'b0110011: begin  // R_Type
                case (operator)
                    4'b0000: alu_Control = 2'b00;  //add
                    4'b0001: alu_Control = 2'b01;  //sub
                    4'b1000: alu_Control = 2'b10;  //and
                    4'b1110: alu_Control = 2'b11;  //or
                endcase
            end
        endcase
    end
endmodule
