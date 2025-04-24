`timescale 1ns / 1ps

interface fnd_bdc_interface;
    // Global Signal                (APB_MS - APB_SL)
    logic        pclk;
    logic        preset;
    // APB Interface Signal
    logic [ 3:0] PADDR;
    logic        PWRITE;
    logic [31:0] PWDATA;
    logic        PENABLE;
    logic        PSEL;
    logic [31:0] PRDATA;
    logic        PREADY;
    // inport signals
    logic [ 3:0] commOut;
    logic [ 7:0] segOut;
endinterface  //fnd_bdc_interface

class transaction;
    // APB Interface Signal
    logic [ 3:0] PADDR;
    logic        PWRITE;
    logic [31:0] PWDATA;
    logic        PENABLE;
    logic        PSEL;
    logic [31:0] PRDATA;
    logic        PREADY;
    // inport signals
    logic [ 3:0] commOut;
    logic [ 7:0] segOut;
endclass  //transaction

class driver;
    mailbox #(transaction) d2g_mbox;
    virtual fnd_bdc_interface inf;
    transaction tr;
    function new(mailbox #(transaction) d2g_mbox,virtual fnd_bdc_interface inf);
        this.d2g_mbox = d2g_mbox;
        this.inf = inf;
    endfunction  //new()

    task  run();
        
    endtask //        
endclass  //driver

class gnerator;
    mailbox #(transaction) d2g_mbox;
    event gen_start_e;
    transaction tr;

    function new(mailbox #(transaction) d2g_mbox, event gen_start_e);
        this.d2g_mbox = d2g_mbox;
        this.gen_start_e = gen_start_e;
    endfunction  //new()

    task  run();
        
    endtask //  
endclass  //gnerator

module tb_20250424_fnd ();

endmodule
