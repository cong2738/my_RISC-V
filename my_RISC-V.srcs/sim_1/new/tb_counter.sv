`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/28 10:56:46
// Design Name: 
// Module Name: tb_counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_counter ();
    logic PCLK;
    logic PRESET;
    logic [1:0] TCR = 2'b01;
    logic [31:0] TCNT;
    logic [31:0] PSC = 1;
    logic [31:0] ARR = 10;
    IP_counter u_IP_counter (
        .PCLK  (PCLK),
        .PRESET(PRESET),
        .TCR   (TCR),
        .TCNT  (TCNT),
        .PSC   (PSC),
        .ARR   (ARR)
    );

    always #5 PCLK = ~PCLK;

    initial begin
        PCLK   = 0;
        PRESET = 1;
        TCNT   = 0;
        #10 PRESET = 0;

    end

endmodule
