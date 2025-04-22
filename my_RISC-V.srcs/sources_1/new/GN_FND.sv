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
    logic       FCR;
    logic [3:0] FMR;
    logic [3:0] FDR;

    APB_SlaveIntf_FND u_APB_SlaveIntf_FND (.*);
    IP_FND u_FND (.*);
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
    output logic [ 3:0] FMR,
    output logic [ 3:0] FDR
);
    logic [31:0] slv_reg0, slv_reg1, slv_reg2;  //, slv_reg3;

    assign FCR = slv_reg0[0];
    assign FMR = slv_reg1[3:0];
    assign FDR = slv_reg2[3:0];

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
    input  logic       FCR,
    input  logic [3:0] FMR,
    input  logic [3:0] FDR,
    output logic [3:0] commOut,
    output logic [7:0] segOut
);
    logic [3:0] temp_cmm = (FCR) ? FMR : 4'bz;  //OUTPUT    
    logic [3:0] temp_bcd = (FCR) ? FDR : 4'bz;  //OUTPUT    

    assign commOut = ~temp_cmm;  //OUTPUT    
    BCDtoSEG_decoder u_BCDtoSEG_decoder (
        .bcd(temp_bcd),
        .seg(segOut)
    );
endmodule
