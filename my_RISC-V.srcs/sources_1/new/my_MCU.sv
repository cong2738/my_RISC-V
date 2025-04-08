`timescale 1ns / 1ps

module MCU (
    input logic clk,
    input logic reset

);
    logic [31:0] instrMemAddr;
    logic [31:0] instrCode;
    logic        regFileWe;
    logic [ 1:0] alu_Control;
    
    RV32I_Core u_Core (.*);

    rom u_rom (
        .addr(instrMemAddr),
        .data(instrCode)
    );

endmodule
