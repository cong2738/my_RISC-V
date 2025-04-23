`timescale 1ns / 1ps

module GP_FND (
    // Global Signal                (APB_MS - APB_SL)
    input  logic        pclk,
    input  logic        preset,
    // APB Interface Signal
    input  logic [ 3:0] PADDR,
    input  logic        PWRITE,
    input  logic [31:0] PWDATA,
    input  logic        PENABLE,
    input  logic        PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    // inport signals
    output logic [ 3:0] commOut,
    output logic [ 7:0] segOut
);
    logic        FCR;
    logic [13:0] FDR;
    logic [ 3:0] DPR;
    logic [13:0] bcd;
    logic [ 3:0] dp;

    APB_SlaveIntf_FND u_APB_SlaveIntf_FND (.*);
    IP_FND u_FND (.*);

    fndController u_fndController (
        .clk    (pclk),
        .reset  (preset),
        .fndData(bcd),
        .fndDot (dp),
        .fndCom (commOut),
        .fndFont(segOut)
    );
endmodule

module APB_SlaveIntf_FND (
    // Global Signal                (APB_MS - APB_SL)
    input  logic        pclk,
    input  logic        preset,
    // APB Interface Signal
    input  logic [ 3:0] PADDR,
    input  logic        PWRITE,
    input  logic [31:0] PWDATA,
    input  logic        PENABLE,
    input  logic        PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    // internal signal
    input  logic        FCR,
    output logic [13:0] FDR,
    output logic [ 3:0] DPR
);
    logic [31:0] slv_reg0;
    logic [31:0] slv_reg1;
    logic [31:0] slv_reg2;
    // logic [31:0] slv_reg3;

    assign FCR = slv_reg0[0];
    assign FDR = slv_reg1[13:0];
    assign DPR = slv_reg2[3:0];

    always_ff @(posedge pclk, posedge preset) begin : slv_sel
        if (preset) begin
            slv_reg0 <= 0;
            slv_reg1 <= 0;
            slv_reg2 <= 0;
            // slv_reg3 <= 0;
        end else begin
            PREADY <= 0;
            if (PSEL && PENABLE) begin
                PREADY <= 1;
                if (PWRITE) begin
                    case (PADDR[3:2])
                        2'd0: slv_reg0 <= PWDATA;
                        2'd1: slv_reg1 <= PWDATA;
                        2'd2: slv_reg2 <= PWDATA;
                        // 2'd3: slv_reg3 <= PWDATA;
                    endcase
                end else begin
                    PRDATA <= 32'bx;
                    case (PADDR[3:2])
                        2'd0: PRDATA <= slv_reg0;
                        2'd1: PRDATA <= slv_reg1;
                        2'd2: PRDATA <= slv_reg2;
                        // 2'd3: PRDATA <= slv_reg3;  
                    endcase
                end
            end
        end
    end
endmodule

module IP_FND (  // my_IP
    input  logic        FCR,
    input  logic [13:0] FDR,
    output logic [ 3:0] DPR,
    output logic [13:0] bcd,
    output logic [ 3:0] dp
);
    assign bcd = FCR ? FDR : 13'dx;
    assign dp  = FCR ? DPR : 4'b1111;
endmodule
