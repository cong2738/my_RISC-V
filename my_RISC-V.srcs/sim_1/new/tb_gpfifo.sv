`timescale 1ns / 1ps

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
