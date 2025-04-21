`timescale 1ns / 1ps

module MCU (
    input  logic       clk,
    input  logic       reset,
    output logic [7:0] GPOA,
    input  logic [7:0] GPIB
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
    logic        PSEL3;
    logic [31:0] PRDATA_RAM;
    logic [31:0] PRDATA_P1;
    logic [31:0] PRDATA_P2;
    logic [31:0] PRDATA3;
    logic        PREADY_RAM;
    logic        PREADY_P1;
    logic        PREADY_P2;
    logic        PREADY3;
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
        .PSEL3  (),
        .PRDATA0(PRDATA_RAM),
        .PRDATA1(PRDATA_P1),
        .PRDATA2(PRDATA_P2),
        .PRDATA3(),
        .PREADY0(PREADY0),
        .PREADY1(PREADY_P1),
        .PREADY2(PREADY_P2),
        .PREADY3()
    );

    GPO_Periph u_GPOA (
        .*,
        .PSEL   (PSEL_P1),
        .PRDATA (PRDATA_P1),
        .PREADY (PREADY_P1),
        .outPort(GPOA)
    );

    GPI_Periph u_GPIB (
        .*,
        .PSEL  (PSEL_P2),
        .PRDATA(PRDATA_P2),
        .PREADY(PREADY_P2),
        .inPort(GPIB)
    );

    ram u_ram (
        .*,
        .PSEL  (PSEL_RAM),
        .PRDATA(PRDATA_RAM),
        .PREADY(PREADY0)
    );

endmodule
