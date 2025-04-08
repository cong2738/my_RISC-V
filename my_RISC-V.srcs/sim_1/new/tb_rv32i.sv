`timescale 1ns / 1ps

module tb_rv32i ();
    logic clk;
    logic reset;
    MCU u_MCU (
        .clk  (clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    integer i;
    initial begin
        clk   = 0;
        reset = 1;
        #5 reset = 0;

    end
endmodule
