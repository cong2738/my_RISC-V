`timescale 1ns / 1ps

module RV32I_Core (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instrCode,
    output logic [31:0] instrMemAddr,
    output logic        dataWe,
    output logic [31:0] dataAddr,
    output logic [31:0] dataWData,
    output logic [31:0] ramData
);
    logic       regFileWe;
    logic [3:0] alu_Control;
    logic       aluSrcMuxSel;
    logic       wDataSrcMuxSel;
    logic       shamtSel;
    logic       Branch;

    DataPath u_DataPath (.*);
    ControlUnit u_ControlUnit (.*);

endmodule