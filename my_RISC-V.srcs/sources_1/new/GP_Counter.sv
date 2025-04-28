`timescale 1ns / 1ps `timescale 1ns / 1ps `timescale 1ns / 1ps

module GP_Counter (
    // global signal
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [ 3:0] PADDR,
    input  logic [31:0] PWDATA,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic        PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    // inport signals
    output logic [31:0] count_num
);
    logic [7:0] TCR;
    logic [7:0] TCNT;
    logic en, clear;
    assign {en, clear} = TCR;
    APB_GP_CounterIntf U_APB_GP_CounterIntf (.*);
    IP_counter u_IP_counter ();
endmodule

module APB_GP_CounterIntf (
    // global signal
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [ 3:0] PADDR,
    input  logic [31:0] PWDATA,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic        PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    // internal signals
    output logic [ 7:0] TCR,
    input  logic [ 7:0] TCNT
);
    logic [31:0] slv_reg[0:1];

    assign TCR             = slv_reg[0][7:0];
    assign slv_reg[1][7:0] = TCNT;

    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            slv_reg[0] <= 0;
            //slv_reg[1] <= 0;
        end else begin
            if (PSEL && PENABLE) begin
                PREADY <= 1'b1;
                if (PWRITE) begin
                    case (PADDR[3:2])
                        2'd0: slv_reg[0] <= PWDATA;
                        2'd1: ;
                    endcase
                end else begin
                    PRDATA <= 32'bx;
                    case (PADDR[3:2])
                        2'd0: PRDATA <= slv_reg[0];
                        2'd1: PRDATA <= slv_reg[1];
                    endcase
                end
            end else begin
                PREADY <= 1'b0;
            end
        end
    end

endmodule

module IP_counter (
    input logic PCLK,
    input logic PRESET,
    input logic clear,
    input logic [7:0] TCR,
    output logic [7:0] TCNT,
    output logic [7:0] count_num
);
    logic tick;
    clk_div #(.COUNTMAX(1000)) u_clk_div (.*);
    counter u_counter (.*);
endmodule

module clk_div #(
    parameter COUNTMAX = 1000
) (
    input  logic PCLK,
    input  logic PRESET,
    input  logic clear,
    output logic tick
);
    logic [0:$clog2(1000)-1] count_num;
    always_ff @(posedge COUNTMAX) begin : blockName
        if (PRESET | clear | (count_num == COUNTMAX)) begin
            count_num <= 0;
        end else if (PCLK) begin
            count_num <= count_num + 1;
        end
    end
endmodule

module counter (
    input  logic PCLK,
    input  logic PRESET,
    input  logic tick,
    input  logic clear,
    output logic count_num
);
    always_ff @(posedge PCLK) begin : COUNTER
        if (PRESET | clear) begin
            count_num <= 0;
        end else begin
            if (tick) begin
                count_num <= count_num + 1;
            end
        end
    end
endmodule
