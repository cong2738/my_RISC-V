`timescale 1ns / 1ps

module MCU (
    input logic clk,
    input logic reset
);
    logic [31:0] instrMemAddr;
    logic [31:0] instrCode;
    logic        regFileWe;
    logic [ 3:0] alu_Control;
    logic        ramWe;
    logic [31:0] dataAddr;
    logic [31:0] dataWData;
    logic [31:0] ramData;

    RV32I_Core u_Core (.*);

    ram u_ram (
        .clk  (clk),
        .we   (ramWe),
        .addr (dataAddr),
        .wData(dataWData),
        .rData(ramData)
    );

    rom u_rom (
        .addr(instrMemAddr),
        .data(instrCode)
    );

endmodule
