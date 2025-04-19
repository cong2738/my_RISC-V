`timescale 1ns / 1ps

module APB_tb ();
    // Global Signal                (APB_MS - APB_SL)
    logic        pclk;
    logic        preset;
    // APB Interface Signal
    logic [31:0] PADDR;
    logic        PWRITE;
    logic [31:0] PWDATA;
    logic        PENABLE;
    logic        PSEL0;
    logic        PSEL1;
    logic        PSEL2;
    logic        PSEL3;
    logic [31:0] PRDATA0;
    logic [31:0] PRDATA1;
    logic [31:0] PRDATA2;
    logic [31:0] PRDATA3;
    logic        PREADY0;
    logic        PREADY1;
    logic        PREADY2;
    logic        PREADY3;
    // Internal Interface Signal    (CPU - APB_MS)
    logic        transfer;  //trigger signal
    logic        ready;
    logic [31:0] addr;
    logic [31:0] wdata;
    logic [31:0] rdata;
    logic        write;  //1:write, 2:read

    APB_Master u_APB_Master (.*);
    APB_Slave u_Periph0 (
        .*,
        .PSEL  (PSEL0),
        .PRDATA(PRDATA0),
        .PREADY(PREADY0)
    );
    APB_Slave u_Periph1 (
        .*,
       .PSEL  (PSEL1),
       .PRDATA(PRDATA1),
        .PREADY(PREADY1)
    );
    APB_Slave u_Periph2 (
        .*,
       .PSEL  (PSEL2),
       .PRDATA(PRDATA2),
        .PREADY(PREADY2)
    );
    APB_Slave u_Periph3 (
        .*,
       .PSEL  (PSEL3),
       .PRDATA(PRDATA3),
        .PREADY(PREADY3)
    );

    task automatic PPTASK(logic [31:0] i_addr, logic i_write, logic wdata);
        @(posedge pclk);
        #1 transfer = 1;
        addr  = i_addr;
        write = i_write;
        wdata = wdata;
        @(posedge pclk);
        #1 transfer = 0;
        wait (ready == 1'b1);
    endtask  //automatic

    always #5 pclk = ~pclk;

    initial begin
        pclk   = 0;
        preset = 1;
        #10 preset = 0;

        @(posedge pclk);
        #1 transfer = 1;
        addr  = 32'h1000_2000;
        write = 1;
        wdata = 32'd10;
        @(posedge pclk);
        #1 transfer = 0;
        wait (ready == 1'b1);
        @(posedge pclk);

        @(posedge pclk);
        #1 transfer = 1;
        addr  = 32'h1000_2004;
        write = 1;
        wdata = 32'd11;
        @(posedge pclk);
        #1 transfer = 0;
        wait (ready == 1'b1);
        @(posedge pclk);

        @(posedge pclk);
        #1 transfer = 1;
        addr  = 32'h1000_2008;
        write = 1;
        wdata = 32'd12;
        @(posedge pclk);
        #1 transfer = 0;
        wait (ready == 1'b1);
        @(posedge pclk);

        @(posedge pclk);
        #1 transfer = 1;
        addr  = 32'h1000_200C;
        write = 1;
        wdata = 32'd13;
        @(posedge pclk);
        #1 transfer = 0;
        wait (ready == 1'b1);
        @(posedge pclk);

        @(posedge pclk);
        #1 transfer = 1;
        addr  = 32'h1000_2000;
        write = 0;
        wdata = 32'd13;
        @(posedge pclk);
        #1 transfer = 0;
        wait (ready == 1'b1);
        @(posedge pclk);

        @(posedge pclk);
        #1 transfer = 1;
        addr  = 32'h1000_2004;
        write = 0;
        wdata = 32'd13;
        @(posedge pclk);
        #1 transfer = 0;
        wait (ready == 1'b1);
        @(posedge pclk);

        @(posedge pclk);
        #1 transfer = 1;
        addr  = 32'h1000_2008;
        write = 0;
        wdata = 32'd13;
        @(posedge pclk);
        #1 transfer = 0;
        wait (ready == 1'b1);
        @(posedge pclk);

        @(posedge pclk);
        #1 transfer = 1;
        addr  = 32'h1000_200C;
        write = 0;
        wdata = 32'd13;
        @(posedge pclk);
        #1 transfer = 0;
        wait (ready == 1'b1);
        @(posedge pclk);

        @(posedge pclk);
        #20 $finish;
    end

endmodule
