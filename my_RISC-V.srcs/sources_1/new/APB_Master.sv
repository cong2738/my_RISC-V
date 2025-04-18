`timescale 1ns / 1ps

module APB_Master (
    // Global Signal                (APB_MS - APB_SL)
    input  logic        pclk,
    input  logic        reset,
    // APB Interface Signal
    output logic [31:0] PADDR,
    output logic        PWRITE,
    output logic [31:0] PWDATA,
    output logic        PENABLE,
    output logic        PSEL1,
    input  logic [31:0] PRDATA1,
    input  logic        PREADY1,
    // Internal Interface Signal    (CPU - APB_MS)
    input  logic        transfer,  //trigger signal
    output logic        ready,
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata,
    input  logic        write      //1:write, 2:read
);
    typedef enum data_type {
        IDLE,
        SETUP,
        ACCESS
    } type_e;
    type_e state, next;
    logic [31:0] temp_addr, temp_addr_next;
    logic [31:0] temp_wdata, temp_wdata_next;
    logic temp_write, temp_write_next;

    always @(posedge pclk, posedge reset) begin
        if (reset) begin
            state <= IDLE;
            temp_addr <= 0;
            temp_wdata <= 0;
            temp_write <= 0;
        end else begin
            state <= next;
            temp_addr <= temp_addr_next;
            temp_wdata <= temp_wdata_next;
            temp_write <= temp_write_next;
        end
    end

    always_comb begin : next_logic
        next = state;
        temp_addr_next = temp_addr;
        temp_wdata_next = temp_wdata;
        temp_write_next = temp_write;
        case (state)
            IDLE: begin
                PSEL1 = -0;
                if (transfer) begin
                    next            = SETUP;
                    // latching
                    temp_addr_next  = addr;
                    temp_wdata_next = wdata;
                    temp_write_next = write;
                end
            end
            SETUP: begin
                PADDR   = temp_addr_next;
                PENABLE = 0;
                if (temp_write_next) begin
                    PWRITE = 1'b1;
                    PWDATA = temp_wdata_next;
                end else begin
                    PWRITE = 1'b0;
                end
                next = ACCESS;
            end
            ACCESS: begin
                PADDR   = temp_addr_next;
                PENABLE = 1;
                 if (temp_write_next) begin
                    PWRITE = 1'b1;
                    PWDATA = temp_wdata_next;
                end else begin
                    PWRITE = 1'b0;
                end
                if (!PREADY1) begin
                    next = ACCESS;
                end else begin
                    next = IDLE;
                end
            end
        endcase
    end
endmodule

module Decoder ();

endmodule

module Manager ();

endmodule

