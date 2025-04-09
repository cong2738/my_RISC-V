`timescale 1ns / 1ps
`include "defines.sv"
 
module ControlUnit ( 
    input  logic [31:0] instrCode,
    output logic        regFileWe,
    output logic [ 3:0] alu_Control,
    output logic        aluSrcMuxSel,
    output logic        dataWe,
    output logic        wDataSrcMuxSel,
    output logic        shamtSel
);

    wire [6:0] opcode = instrCode[6:0];
    wire [2:0] func3 = instrCode[14:12];
    wire [3:0] operators = {instrCode[30], func3};  // {func7[5] funct3}

    logic [3:0] signals;
    assign {regFileWe, aluSrcMuxSel, dataWe, wDataSrcMuxSel} = signals;

    always_comb begin : we
        signals = 4'b0;
        case (opcode)  //        F_A_D_W
            `R_Type: signals = 4'b1_0_0_0;
            `S_Type: signals = 4'b0_1_1_0;
            `L_Type: signals = 4'b1_1_0_1;
            `I_Type: signals = 4'b1_1_0_0;
        endcase
    end

    always_comb begin : opsel
        alu_Control = 2'bx;
        case (opcode)
            `R_Type: alu_Control = operators;  //   {func7[5],func3}
            `S_Type: alu_Control = `ADD;  //        {3'b000}
            `L_Type: alu_Control = `ADD;  //        {3'b000}
            `I_Type: alu_Control = operators;  //        {3'b000}
        endcase
    end

    always_comb begin : shamt_sel
        shamtSel = 0;
        if (opcode == `I_Type)
            case (operators)
                `SLL: shamtSel = 1;
                `SRL: shamtSel = 1;
                `SRA: shamtSel = 1;
            endcase
    end
endmodule
