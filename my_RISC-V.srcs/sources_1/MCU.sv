`timescale 1ns / 1ps

module MCU (
    input  logic       clk,
    input  logic       reset,
    output logic [7:0] GPOA,
    input  logic [7:0] GPIB,
    inout  logic [7:0] GPIOC,
    inout  logic [7:0] GPIOD,
    output logic [3:0] fndCom,
    output logic [7:0] fndFont,
    output logic [7:0] fifoReadData
);
    // global signals
    logic        PCLK;
    logic        PRESET;
    // APB Interface Signals
    logic [31:0] PADDR;
    logic [31:0] PWDATA;
    logic        PWRITE;
    logic        PENABLE;
    logic        PSEL0;
    logic        PSEL1;
    logic        PSEL2;
    logic        PSEL3;
    logic        PSEL4;
    logic        PSEL5;
    logic        PSEL6;
    logic        PSEL7;
    logic [31:0] PRDATA0;
    logic [31:0] PRDATA1;
    logic [31:0] PRDATA2;
    logic [31:0] PRDATA3;
    logic [31:0] PRDATA4;
    logic [31:0] PRDATA5;
    logic [31:0] PRDATA6;
    logic [31:0] PRDATA7;
    logic        PREADY0;
    logic        PREADY1;
    logic        PREADY2;
    logic        PREADY3;
    logic        PREADY4;
    logic        PREADY5;
    logic        PREADY6;
    logic        PREADY7;
    // CPU - APB_Master Signals
    // Internal Interface Signals
    logic        transfer;  // trigger signal
    logic        ready;
    logic [31:0] addr;
    logic [31:0] wdata;
    logic [31:0] rdata;
    logic        write;  // 1:write, 0:read
    logic        dataWe;
    logic [31:0] dataAddr;
    logic [31:0] dataWData;
    logic [31:0] dataRData;
    // ROM Signals
    logic [31:0] instrCode;
    logic [31:0] instrMemAddr;

    assign PCLK = clk;
    assign PRESET = reset;
    assign addr = dataAddr;
    assign wdata = dataWData;
    assign dataRData = rdata;
    assign write = dataWe;

    rom U_ROM (
        .addr(instrMemAddr),
        .data(instrCode)
    );

    RV32I_Core U_Core (.*);

    APB_Master U_APB_Master (.*);

    ram U_RAM (
        .*,
        .PSEL  (PSEL0),
        .PRDATA(PRDATA0),
        .PREADY(PREADY0)
    );

    GPO_Periph U_GPOA (
        .*,
        .PSEL(PSEL1),
        .PRDATA(PRDATA1),
        .PREADY(PREADY1),
        // export signals
        .outPort(GPOA)
    );

    GPI_Periph U_GPIB (
        .*,
        .PSEL  (PSEL2),
        .PRDATA(PRDATA2),
        .PREADY(PREADY2),
        // inport signals
        .inPort(GPIB)
    );

    GPIO_Periph U_GPIOC (
        .*,
        .PSEL(PSEL3),
        .PRDATA(PRDATA3),
        .PREADY(PREADY3),
        // inoutport signals
        .inoutPort(GPIOC)
    );

    GPIO_Periph U_GPIOD (
        .*,
        .PSEL(PSEL4),
        .PRDATA(PRDATA4),
        .PREADY(PREADY4),
        // inoutport signals
        .inoutPort(GPIOD)
    );

    fnd_Periph u_fnd_pp (
        .*,
        .PSEL   (PSEL5),
        .PRDATA (PRDATA5),
        .PREADY (PREADY5),
        .fndFont(fndFont),
        .fndCom (fndCom),
        .sim_dp (),
        .sim_bcd()
    );

    GP_FIFO u_GP_FIFO (
        .*,
        .PSEL        (PSEL6),
        .PRDATA      (PRDATA6),
        .PREADY      (PREADY6),
        .fifoReadData(fifoReadData)
    );

endmodule