`timescale 1ns / 1ps

`include "../../sources_1/new/defines.sv"

module tb_rv32i ();
    logic clk;
    logic reset;
    MCU u_MCU (.*);

    task automatic mon_type();
        logic [6:0] t = u_MCU.u_Core.u_ControlUnit.instrCode[6:0];
        case (t)
            `R_Type:  $display("R_Type - %b", t);
            `L_Type:  $display("L_Type - %b", t);
            `I_Type:  $display("I_Type - %b", t);
            `S_Type:  $display("S_Type - %b", t);
            `B_Type:  $display("B_Type - %b", t);
            `LU_Type: $display("LU_Type - %b", t);
            `AU_Type: $display("AU_Type - %b", t);
            `J_Type:  $display("J_Type - %b", t);
            `JL_Type: $display("JL_Type - %b", t);
            default:  $display("NoneType - %b", t);
        endcase
    endtask  //automatic

    always #5 clk = ~clk;

    always @(posedge clk) begin
        mon_type();
    end

    initial begin
        clk   = 0;
        reset = 1;
        #1 reset = 0;
        #100 $finish;
    end
endmodule
