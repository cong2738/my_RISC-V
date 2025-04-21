`timescale 1ns / 1ps

module ram (
    // Global Signal                (APB_MS - APB_SL)
    input  logic        pclk, 
    // APB Interface Signal
    input  logic [11:0] PADDR, 
    input  logic        PWRITE, 
    input  logic [31:0] PWDATA, 
    input  logic        PENABLE, 
    input  logic        PSEL, 
    output logic [31:0] PRDATA, 
    output logic        PREADY 
);
    logic [31:0] mem[0:2**10-1];

    always_ff @(posedge pclk) begin
        PREADY <= 0;
        if (PSEL && PENABLE) begin
            PREADY <= 1;
            if (PWRITE) mem[PADDR[11:2]] <= PWDATA;
            else PRDATA <= mem[PADDR[11:2]];
        end
    end
endmodule
