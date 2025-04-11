`timescale 1ns / 1ps
`include "defines.sv"

module ControlUnit (
    input  logic [31:0] instrCode,
    output logic        regFileWe,
    output logic [ 3:0] alu_Control,
    output logic        aluSrcMuxSel,
    output logic        ramWe,
    output logic [ 2:0] wDataSrcMuxSel,
    output logic        branch,
    output logic        jump,
    input  logic        jalr
);

    wire [6:0] opcode = instrCode[6:0];
    wire [2:0] func3 = instrCode[14:12];
    wire [2:0] func7 = instrCode[31:25];
    wire [3:0] operators = {instrCode[30], func3};  // {func7[5] funct3}

    logic [8:0] signals;
    //      E         _A            _R     _wDs            _B      _J    _JR
    assign {regFileWe, aluSrcMuxSel, ramWe, wDataSrcMuxSel, branch, jump, jalr} = signals; 

    always_comb begin : reg_we_sel
        signals = 9'b0;
        case (opcode)  //          E_A_R_wDs_B_J_JR
            `R_Type:  signals = 9'b1_0_0_000_0_0_0;
            `S_Type:  signals = 9'b0_1_1_000_0_0_0;
            `L_Type:  signals = 9'b1_1_0_001_0_0_0;
            `I_Type:  signals = 9'b1_1_0_000_0_0_0;
            `B_Type:  signals = 9'b0_0_0_000_1_0_0;
            `LU_Type: signals = 9'b1_0_0_010_0_0_0;
            `AU_Type: signals = 9'b1_0_0_011_0_0_0;
            `J_Type:  signals = 9'b1_0_0_100_0_1_0;
            `JL_Type: signals = 9'b1_1_0_100_0_1_1; // ALU를 쓸 수 있을지도? 나중에 해보자.
        endcase
    end

    always_comb begin : alu_Control_sel
        alu_Control = 2'bx;
        case (opcode)
            `S_Type: alu_Control = `ADD;  //        {3'b000}
            `L_Type: alu_Control = `ADD;  //        {3'b000}
            `I_Type: begin
                if (operators == 4'b1101) alu_Control = operators;
                else alu_Control = {1'b0, operators[2:0]};
            end
            default: alu_Control = operators;
            // `R_Type:  alu_Control = operators;  //   {func7[5],func3}
            // `B_Type:  alu_Control = operators;
            // `LU_Type: alu_Control = operators;
            // `AU_Type: alu_Control = operators;
            // `J_Type:  alu_Control = operators;
            `JL_Type: alu_Control = `ADD;

        endcase
    end

endmodule
