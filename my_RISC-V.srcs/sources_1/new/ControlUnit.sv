`timescale 1ns / 1ps

module ControlUnit (
    input logic [31:0] instrCode,
    output logic regFileWe,
    output logic [3:0] alu_Control
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

    localparam 
        ADD  = 4'b0_000,
        SUB  = 4'b1_000,
        SLL  = 4'b0_001,
        SRL  = 4'b0_101,
        SRA  = 4'b1_101,
        SLT  = 4'b0_010,
        SLTU = 4'b0_011,
        XOR  = 4'b0_100,
        OR   = 4'b0_110,
        AND  = 4'b0_111;

    always_comb begin : opsel
        alu_Control = 2'bx;
        case (opcode)
            7'b0110011: begin  // R_Type
                case (operator)
                    ADD:  alu_Control = 4'b0000;
                    SUB:  alu_Control = 4'b0001;
                    SLL:  alu_Control = 4'b0010;
                    SRL:  alu_Control = 4'b0011;
                    SRA:  alu_Control = 4'b0100;
                    SLT:  alu_Control = 4'b0101;
                    SLTU: alu_Control = 4'b0110;
                    XOR:  alu_Control = 4'b0111;
                    OR:   alu_Control = 4'b1000;
                    AND:  alu_Control = 4'b1001;
                endcase
            end
        endcase
    end
endmodule
