`timescale 1ns / 1ps

interface GPFIFO_Interface ();
    logic        PCLK;
    logic        PRESET;
    // APB Interface Signals
    logic [ 3:0] PADDR;
    logic [31:0] PWDATA;
    logic        PWRITE;
    logic        PENABLE;
    logic        PSEL;
    logic [31:0] PRDATA;  // dut out data
    logic        PREADY;  // dut out data
    // outport signals
    logic        sim_full;
    logic        sim_empty;
    
endinterface  //GPFIFO_Interface

class GPFIFO_transaction;
    // APB Interface Signals
    rand logic [ 3:0] PADDR;
    rand logic [31:0] PWDATA;
    rand logic        PWRITE;
    rand logic        PENABLE;
    rand logic        PSEL;
    logic      [31:0] PRDATA;  // dut out data
    logic             PREADY;  // dut out data
    // outport signals
    logic             sim_full;
    logic             sim_empty;
    
    rand logic op;
    constraint oper_ctrl { op dist { 1 :/ 80, 0 :/ 20};}

    task display(string name);
        $display(
            "[%s] PADDR=%h, PWDATA=%h, PWRITE=%h, PENABLE=%h, PSEL=%h, PRDATA=%h, PREADY=%h",
            name, PADDR, PWDATA, PWRITE, PENABLE, PSEL, PRDATA, PREADY,);
    endtask

endclass  //GPFIFO_transaction

class GPFIFO_generator;
    mailbox #(GPFIFO_transaction) Gen2Drv_mbox;
    event gen_next_event;

    function new(mailbox#(GPFIFO_transaction) Gen2Drv_mbox, event gen_next_event);
        this.Gen2Drv_mbox   = Gen2Drv_mbox;
        this.gen_next_event = gen_next_event;
    endfunction  //new()

    task run(int repeat_counter);
        GPFIFO_transaction fifo_tr;
        repeat (repeat_counter) begin
            fifo_tr = new();  // make instance
            if (!fifo_tr.randomize()) $error("Randomization fail!");
            fifo_tr.display("GEN");
            Gen2Drv_mbox.put(fifo_tr);
            @(gen_next_event);  // wait a event from GPFIFO_driver
        end
    endtask
endclass  //GPFIFO_generator


class GPFIFO_driver;
    virtual GPFIFO_Interface fifo_intf;
    mailbox #(GPFIFO_transaction) Gen2Drv_mbox;
    GPFIFO_transaction fifo_tr;

    function new(virtual GPFIFO_Interface fifo_intf,
                 mailbox#(GPFIFO_transaction) Gen2Drv_mbox);
        this.fifo_intf = fifo_intf;
        this.Gen2Drv_mbox = Gen2Drv_mbox;
    endfunction  //new()

    task gp_fifo_run(logic write, logic [31:0] WDATA);
        @(posedge fifo_intf.PCLK) #1;
        fifo_intf.PADDR   <= (write) ? 0: 4;
        fifo_intf.PWDATA  <= WDATA;
        fifo_intf.PWRITE  <= write;
        fifo_intf.PENABLE <= 1'b0;
        fifo_intf.PSEL    <= 1'b1;

        @(posedge fifo_intf.PCLK) #1;
        fifo_intf.PENABLE   <= 1'b1;
        fifo_intf.PSEL      <= 1'b1;

        wait (fifo_intf.PREADY) #1;
        fifo_intf.PENABLE <= 1'b0;
        fifo_intf.PSEL    <= 1'b0;
    endtask  //

    task run();
        forever begin
            Gen2Drv_mbox.get(fifo_tr);
            fifo_tr.display("DRV");
            gp_fifo_run(fifo_tr.op, fifo_tr.PWDATA);
        end
    endtask  //run

endclass  // GPFIFO_driver


class GPFIFO_monitor;
    mailbox #(GPFIFO_transaction) Mon2SCB_mbox;
    virtual GPFIFO_Interface fifo_intf;
    GPFIFO_transaction fifo_tr;

    function new(virtual GPFIFO_Interface fifo_intf,
                 mailbox#(GPFIFO_transaction) Mon2SCB_mbox);
        this.fifo_intf = fifo_intf;
        this.Mon2SCB_mbox = Mon2SCB_mbox;
    endfunction  //new()

    task run();
        forever begin
            fifo_tr = new();
            @(posedge fifo_intf.PCLK) #1;
            @(posedge fifo_intf.PCLK) #1;
            @(posedge fifo_intf.PREADY) #1;
            fifo_tr.PADDR       = fifo_intf.PADDR;
            fifo_tr.PWDATA      = fifo_intf.PWDATA;
            fifo_tr.PWRITE      = fifo_intf.PWRITE;
            fifo_tr.PENABLE     = fifo_intf.PENABLE;
            fifo_tr.PSEL        = fifo_intf.PSEL;
            fifo_tr.PRDATA      = fifo_intf.PRDATA;
            fifo_tr.PREADY      = fifo_intf.PREADY;
            fifo_tr.sim_full    = fifo_intf.sim_full;
            fifo_tr.sim_empty   = fifo_intf.sim_empty;
            Mon2SCB_mbox.put(fifo_tr);
            fifo_tr.display("MON");
        end
    endtask
endclass  //GPFIFO_monitor


class GPFIFO_scoreboard;
    mailbox #(GPFIFO_transaction) Mon2SCB_mbox;
    GPFIFO_transaction fifo_tr;
    event gen_next_event;

    // reference model
    logic [31:0] refFndReg[0:1];  // = slv_reg0, slv_reg1
    logic [7:0] scb_fifo[$];
    logic [7:0] pop_data;

    int write_cnt;
    int read_cnt;
    int read_pass_cnt;
    int read_fail_cnt;
    int total_cnt;

    function new(mailbox#(GPFIFO_transaction) Mon2SCB_mbox, event gen_next_event);
        this.Mon2SCB_mbox = Mon2SCB_mbox;
        this.gen_next_event = gen_next_event;

        write_cnt = 0;
        read_cnt = 0;
        read_pass_cnt = 0;
        read_fail_cnt = 0;
        total_cnt = 0;

        for (int i = 0; i < 3; i++) begin
            refFndReg[i] = 0;
        end
    endfunction  //new()

    task run();
        forever begin
            Mon2SCB_mbox.get(fifo_tr);
            fifo_tr.display("SCB");

            if (fifo_tr.PWRITE) begin  // write mode
                write_cnt++;
                if (!fifo_tr.sim_full) begin
                    scb_fifo.push_back(fifo_tr.PWDATA);
                    $display("[SCB] : DATA Stored in queue : %d, %p",
                             fifo_tr.PWDATA, scb_fifo);
                end else $display("[SCB] : FIFO is full, %p", scb_fifo);
            end else begin  // read mode 
                read_cnt++;
                if (!fifo_tr.sim_empty) begin
                    pop_data = scb_fifo.pop_front();
                    if (fifo_tr.PRDATA == pop_data) begin
                        read_pass_cnt++;
                        $display("[SCB] : DATA Matched %h == %h",
                                 fifo_tr.PRDATA, pop_data);
                    end else begin
                        read_fail_cnt++;
                        $display(
                            "[SCB] : DATA Mismatched %h != %h",
                            fifo_tr.PRDATA,
                            pop_data
                        );
                    end
                end
            end
            total_cnt++;
            ->gen_next_event;
        end
    endtask


endclass  //GPFIFO_scoreboard


class GPFIFO_envirnment;
    mailbox #(GPFIFO_transaction) Gen2Drv_mbox;
    mailbox #(GPFIFO_transaction) Mon2SCB_mbox;

    GPFIFO_generator       fifo_gen;
    GPFIFO_driver          fifo_drv;
    GPFIFO_monitor         fifo_mon;
    GPFIFO_scoreboard      fifo_scb;

    task show_report();
        $display("==================================");
        $display("==        Final Report          ==");
        $display("==================================");
        $display("Write_cnt Test  : %0d", this.fifo_scb.write_cnt);
        $display("Read_cnt  Test  : %0d", this.fifo_scb.read_cnt);
        $display("Read_pass_cnt  Test  : %0d", this.fifo_scb.read_pass_cnt);
        $display("Read_fail_cnt  Test  : %0d", this.fifo_scb.read_fail_cnt);
        $display("Total Test  : %0d", this.fifo_scb.total_cnt);
        $display("==================================");
        $display("==    test bench is finished!   ==");
    endtask

    event gen_next_event;

    function new(virtual GPFIFO_Interface fifo_intf);
        this.Gen2Drv_mbox = new();
        this.Mon2SCB_mbox = new();
        this.fifo_gen = new(Gen2Drv_mbox, gen_next_event);
        this.fifo_drv = new(fifo_intf, Gen2Drv_mbox);
        this.fifo_mon = new(fifo_intf, Mon2SCB_mbox);
        this.fifo_scb = new(Mon2SCB_mbox, gen_next_event);
    endfunction  //new()

    task run(int count);
        fork
            fifo_gen.run(count);
            fifo_drv.run();
            fifo_mon.run();
            fifo_scb.run();
        join_any
    endtask  //

endclass  // GPFIFO_envirnment

module tb_gpfifo_uvm_style ();
    logic clk, reset;

    GPFIFO_envirnment env;
    GPFIFO_Interface gnfifo_if ();

    GP_FIFO dut_uvm (
        .PCLK        (gnfifo_if.PCLK),
        .PRESET      (gnfifo_if.PRESET),
        .PADDR       (gnfifo_if.PADDR),
        .PWDATA      (gnfifo_if.PWDATA),
        .PWRITE      (gnfifo_if.PWRITE),
        .PENABLE     (gnfifo_if.PENABLE),
        .PSEL        (gnfifo_if.PSEL),
        .PRDATA      (gnfifo_if.PRDATA),
        .PREADY      (gnfifo_if.PREADY)
    );

    assign gnfifo_if.sim_full = dut_uvm.full;
    assign gnfifo_if.sim_empty = dut_uvm.empty;

    always #5 gnfifo_if.PCLK = ~gnfifo_if.PCLK;

    initial begin
        gnfifo_if.PCLK   = 0;
        gnfifo_if.PRESET = 1;
        @(posedge gnfifo_if.PCLK);
        gnfifo_if.PRESET = 0;
        @(posedge gnfifo_if.PCLK);
        env = new(gnfifo_if);
        env.run(100);
        #10 env.show_report();
        #50 $finish;
    end
endmodule

module tb_gpfifo ();
    logic        PCLK;
    logic        PRESET;
    logic [ 3:0] PADDR;
    logic [31:0] PWDATA;
    logic        PWRITE;
    logic        PENABLE;
    logic        PSEL;
    logic [31:0] PRDATA;
    logic        PREADY;

    GP_FIFO dut (
        .PCLK   (PCLK),
        .PRESET (PRESET),
        .PADDR  (PADDR),
        .PWDATA (PWDATA),
        .PWRITE (PWRITE),
        .PENABLE(PENABLE),
        .PSEL   (PSEL),
        .PRDATA (PRDATA),
        .PREADY (PREADY)
    );

    logic [7:0] mem[0:2**2-1];

    assign mem = dut.u_fifo.u_fifo_ram.mem;

    task gp_fifo_ruN(logic write, logic [31:0] WDATA);
        @(posedge PCLK) #1;
        PADDR   <= (write) ? 0: 4;
        PWDATA  <= WDATA;
        PWRITE  <= write;
        PENABLE <= 1'b0;
        PSEL    <= 1'b1;

        @(posedge PCLK) #1;
        PENABLE <= 1'b1;
        PSEL    <= 1'b1;

        wait (PREADY) #1;
        PENABLE <= 1'b0;
        PSEL    <= 1'b0;
    endtask  //

    always #5 PCLK = ~PCLK;

    initial begin
        PCLK   = 0;
        PRESET = 1;
        PWRITE  = 1'b1;
        PENABLE = 1'b0;
        PSEL    = 1'b0;
        @(posedge PCLK) #1;
        PRESET = 0;
        @(posedge PCLK) #1;
        gp_fifo_ruN(1, 10);
        gp_fifo_ruN(1, 11);
        gp_fifo_ruN(1, 12);
        gp_fifo_ruN(1, 14);
        gp_fifo_ruN(1, 15);
        gp_fifo_ruN(0, 0);
        gp_fifo_ruN(0, 0);
        gp_fifo_ruN(0, 0);
        gp_fifo_ruN(0, 0);
        gp_fifo_ruN(0, 0);
        gp_fifo_ruN(1, 15);

        #50 $finish;
    end
endmodule
