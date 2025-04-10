`timescale 1ns / 1ps

module tb_rv32i ();
    logic clk; 
    logic reset;
    MCU u_MCU (.*);

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        #5 reset = 0;
        #100 $finish;
    end
endmodule
