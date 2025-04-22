`timescale 1ns / 1ps

interface APB_Slave_interface;
    logic        pclk;
    logic        preset;
    // APB Interface Signal
    logic [ 3:0] PADDR;
    logic        PWRITE;
    logic [31:0] PWDATA;
    logic        PENABLE;
    logic        PSEL;
    logic [31:0] PRDATA;  //dut out
    logic        PREADY;  //dut out
    // inport signal
    logic [ 3:0] commOut;  //dut out
    logic [ 7:0] segOut;  //dut out
endinterface  //APB_Slave_interface

class transection;
    // APB Interface Signal
    rand logic [ 3:0] PADDR;
    rand logic        PWRITE;
    rand logic [31:0] PWDATA;
    rand logic        PENABLE;
    rand logic        PSEL;
    logic      [31:0] PRDATA;  //dut out
    logic             PREADY;  //dut out
    // inport signal
    logic      [ 3:0] commOut;  //dut out
    logic      [ 7:0] segOut;  //dut out

    constraint c_paddr {PADDR inside {4'h0, 4'h4, 4'h8};}  // RAND 제약사항
    constraint c_wdata {PWDATA < 10;}  // RAND 제약사항

    task display(string name);
        $display(
            "[%s] PADDR=%h, PWDATA=%h, PWRITE=%h, PENBLE=%h, PSEL=%h, PRDATA=%h, PREADY=%h,commOut=%h, segOut=%h",
            name, PADDR, PWDATA, PWRITE, PENABLE, PSEL, PRDATA, PREADY,
            commOut, segOut);
    endtask
endclass  //transection

class generator;
    mailbox #(transection) gen2Drv_mbox;
    event gen_next_event;

    function new(mailbox#(transection) gen2Drv_mbox, event gen_next_event);
        this.gen2Drv_mbox   = gen2Drv_mbox;
        this.gen_next_event = gen_next_event;
    endfunction  //new()

    task run(int repeat_counter);
        transection fnd_tr;
        repeat (repeat_counter) begin
            fnd_tr = new();
            if (!fnd_tr.randomize()) $error("Randomization Failed!!!");
            fnd_tr.display("GEN");
            gen2Drv_mbox.put(fnd_tr);
            @(gen_next_event);  //wait ecent from driver
        end
    endtask
endclass  //generator

class driver;
    virtual APB_Slave_interface fnd_interf;
    mailbox #(transection) gen2Drv_mbox;
    transection fnd_tr;
    event gen_next_event;

    function new(virtual APB_Slave_interface fnd_interf,
                 mailbox#(transection) gen2Drv_mbox, event gen_next_event);
        this.fnd_interf = fnd_interf;
        this.gen2Drv_mbox = gen2Drv_mbox;
        this.gen_next_event = gen_next_event;
    endfunction  //new()

    task run();
        forever begin
            gen2Drv_mbox.get(fnd_tr);
            fnd_tr.display("DRV");

            @(posedge fnd_interf.pclk);
            fnd_interf.PADDR   <= fnd_tr.PADDR;
            fnd_interf.PWDATA  <= fnd_tr.PWDATA;
            fnd_interf.PWRITE  <= 1'b1;
            fnd_interf.PENABLE <= 1'b0;
            fnd_interf.PSEL    <= 1'b1;

            @(posedge fnd_interf.pclk);
            fnd_interf.PADDR   <= fnd_tr.PADDR;
            fnd_interf.PWDATA  <= fnd_tr.PWDATA;
            fnd_interf.PWRITE  <= 1'b1;
            fnd_interf.PENABLE <= 1'b1;
            fnd_interf.PSEL    <= 1'b1;

            wait (fnd_interf.PREADY == 1'b1);
            @(posedge fnd_interf.pclk);
            @(posedge fnd_interf.pclk);
            @(posedge fnd_interf.pclk);

            ->gen_next_event;  //event trigger
        end
    endtask
endclass  //driver

class envirionment;
    mailbox #(transection) gen2Drv_mbox;
    generator fnd_gen;
    driver fnd_drv;
    event gen_next_event;

    function new(virtual APB_Slave_interface fnd_interf);
        this.gen2Drv_mbox = new();
        this.fnd_gen = new(gen2Drv_mbox, gen_next_event);
        this.fnd_drv = new(fnd_interf, gen2Drv_mbox, gen_next_event);
    endfunction  //new()

    task run(int count);
        fork
            fnd_gen.run(count);
            fnd_drv.run();
        join_any
    endtask  //
endclass  //envirionment

module tb_fndControlloer_APB_Periph ();
    envirionment fnd_env;
    APB_Slave_interface fnd_interf ();
    GP_FND dut (
        .pclk   (fnd_interf.pclk),
        .preset (fnd_interf.preset),
        .PADDR  (fnd_interf.PADDR),
        .PWRITE (fnd_interf.PWRITE),
        .PWDATA (fnd_interf.PWDATA),
        .PENABLE(fnd_interf.PENABLE),
        .PSEL   (fnd_interf.PSEL),
        .PRDATA (fnd_interf.PRDATA),
        .PREADY (fnd_interf.PREADY),
        .commOut(fnd_interf.commOut),
        .segOut (fnd_interf.segOut)
    );

    always #5 fnd_interf.pclk = ~fnd_interf.pclk;

    initial begin
        fnd_interf.pclk   = 0;
        fnd_interf.preset = 1;
        #10;
        fnd_interf.preset = 0;
        fnd_env = new(fnd_interf);
        fnd_env.run(10);
        #30 $finish;
    end
endmodule
