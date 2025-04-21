`timescale 1ns / 1ps

module GPI_Periph (
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
    input  logic [ 7:0] inPort
);
    logic [7:0] moder;
    logic [7:0] idr;

    APB_SlaveIntf_GPI u_APB_SlaveIntf_GPI (.*);
    GPI u_GPI (.*);
endmodule

module APB_SlaveIntf_GPI (
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
    output logic [ 7:0] moder,
    input  logic [ 7:0] idr
);
    logic [31:0] slv_reg0, slv_reg1, slv_reg2, slv_reg3;

    assign moder         = slv_reg0[7:0];
    assign slv_reg1[7:0] = idr;

    always_ff @(posedge pclk, posedge preset) begin : slv_sel
        if (preset) begin
            slv_reg0 <= 0;
            // slv_reg1 <= 0;
            // slv_reg2 <= 0;
            // slv_reg3 <= 0;
        end else begin
            PREADY <= 0;
            if (PSEL && PENABLE) begin
                PREADY <= 1;
                if (PWRITE) begin
                    case (PADDR[3:2])
                        2'd0: slv_reg0 <= PWDATA;
                        2'd1: ;
                        // 2'd1: slv_reg1 <= PWDATA;
                        // 2'd2: slv_reg2 <= PWDATA;
                        // 2'd3: slv_reg3 <= PWDATA;
                    endcase
                end else begin
                    PRDATA <= 32'bx;
                    case (PADDR[3:2])
                        2'd0: PRDATA <= slv_reg0;
                        2'd1: PRDATA <= slv_reg1;
                        // 2'd2: PRDATA <= slv_reg2;
                        // 2'd3: PRDATA <= slv_reg3;
                    endcase
                end
            end
        end
    end
endmodule


module GPI (  // my_IP
    input  logic [7:0] moder,
    output logic [7:0] idr,
    input  logic [7:0] inPort
);
    generate
        for (genvar i = 0; i < 8; i = i + 1) begin
            assign idr[i] = ~moder[i] ? inPort[i] : 1'bz;
        end
    endgenerate
endmodule
