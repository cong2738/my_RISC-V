`timescale 1ns / 1ps

module RV32I_Core (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instrCode,
    output logic [31:0] instrMemAddr,
    output logic        ramWe,
    output logic [31:0] dataAddr,
    output logic [31:0] dataWData,
    output logic [31:0] ramData
);
    logic       regFileWe;
    logic [3:0] alu_Control;
    logic       aluSrcMuxSel;
    logic [2:0] wDataSrcMuxSel;
    logic       shamtSel;
    logic       branch;
    logic       jump;
    logic       jalr;

    DataPath u_DataPath (.*);
    ControlUnit u_ControlUnit (.*);

endmodule
