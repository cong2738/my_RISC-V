`timescale 1ns / 1ps

module MCU (
    input  logic       clk,
    input  logic       reset,
    output logic [3:0] commOut,
    output logic [7:0] segOut
);
    logic [31:0] instrCode;
    logic [31:0] instrMemAddr;
    logic        dataWe;
    logic [31:0] dataAddr;
    logic [31:0] dataWData;
    logic [31:0] dataRData;

    // Global Signal              
    logic        pclk;
    logic        preset;
    // APB Interface Signal
    logic [31:0] PADDR;
    logic        PWRITE;
    logic [31:0] PWDATA;
    logic        PENABLE;
    logic        PSEL_RAM;
    logic        PSEL_P1;
    logic        PSEL_P2;
    logic        PSEL_P3;
    logic        PSEL_P4;
    logic        PSEL_P5;
    logic [31:0] PRDATA_RAM;
    logic [31:0] PRDATA_P1;
    logic [31:0] PRDATA_P2;
    logic [31:0] PRDATA_P3;
    logic [31:0] PRDATA_P4;
    logic [31:0] PRDATA_P5;
    logic        PREADY_RAM;
    logic        PREADY_P1;
    logic        PREADY_P2;
    logic        PREADY_P3;
    logic        PREADY_P4;
    logic        PREADY_P5;
    // CPU - APB_MASTER Signals    (CPU - APB_MS)
    logic        transfer;  //trigger signal
    logic        ready;
    logic        write;  //1:write, 2:read
    logic [31:0] addr;
    logic [31:0] wdata;
    logic [31:0] rdata;


    assign pclk = clk;
    assign preset = reset;
    assign write = dataWe;
    assign addr = dataAddr;
    assign wdata = dataWData;
    assign dataRData = rdata;

    RV32I_Core U_Core (.*);

    rom U_ROM (
        .addr(instrMemAddr),
        .data(instrCode)
    );

    APB_Master u_APB_Master (
        .*,
        .PSEL0  (PSEL_RAM),
        .PSEL1  (PSEL_P1),
        .PSEL2  (PSEL_P2),
        .PSEL3  (PSEL_P3),
        .PSEL4  (PSEL_P4),
        .PSEL5  (PSEL_P5),
        .PRDATA0(PRDATA_RAM),
        .PRDATA1(PRDATA_P1),
        .PRDATA2(PRDATA_P2),
        .PRDATA3(PRDATA_P3),
        .PRDATA4(PRDATA_P4),
        .PRDATA5(PRDATA_P5),
        .PREADY0(PREADY_RAM),
        .PREADY1(PREADY_P1),
        .PREADY2(PREADY_P2),
        .PREADY3(PREADY_P3),
        .PREADY4(PREADY_P4),
        .PREADY5(PREADY_P5)
    );

    GP_FND u_FND_CTRL (
        .*,
        .PSEL   (PSEL_P1),
        .PRDATA (PRDATA_P1),
        .PREADY (PREADY_P1)
    );


    ram u_ram (
        .*,
        .PSEL  (PSEL_RAM),
        .PRDATA(PRDATA_RAM),
        .PREADY(PREADY_RAM)
    );

endmodule
