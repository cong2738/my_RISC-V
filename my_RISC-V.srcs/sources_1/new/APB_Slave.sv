`timescale 1ns / 1ps

module APB_Slave (
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
    output logic        PREADY
);
    logic [31:0] slv_reg0, slv_reg1, slv_reg2, slv_reg3;

    assign PREADY = PSEL && PENABLE;

    always_ff @(posedge pclk, posedge preset) begin : slv_sel
        if (preset) begin
            slv_reg0 <= 0;
            slv_reg1 <= 0;
            slv_reg2 <= 0;
            slv_reg3 <= 0;
            PRDATA   <= 32'bx;
        end else begin
            if (PREADY) begin
                if (PWRITE) begin
                    case (PADDR[3:2])
                        2'd0: slv_reg0 <= PWDATA;
                        2'd1: slv_reg1 <= PWDATA;
                        2'd2: slv_reg2 <= PWDATA;
                        2'd3: slv_reg3 <= PWDATA;
                    endcase
                end else begin
                    PRDATA <= 32'bx;
                    case (PADDR[3:2])
                        2'd0: PRDATA <= slv_reg0;
                        2'd1: PRDATA <= slv_reg1;
                        2'd2: PRDATA <= slv_reg2;
                        2'd3: PRDATA <= slv_reg3;
                    endcase
                end
            end
        end
    end
endmodule
