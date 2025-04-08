`timescale 1ns / 1ps

module RV32I_Core (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instrCode,
    output logic [31:0] instrMemAddr
);
    logic regFileWe;
    logic [3:0] alu_Control;
    DataPath u_DataPath (.*);
    ControlUnit u_ControlUnit (.*);

endmodule
