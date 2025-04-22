`timescale 1ns / 1ps

module APB_Master (
    // Global Signal                (APB_MS - APB_SL)
    input  logic        pclk,
    input  logic        preset,
    // APB Interface Signal
    output logic [31:0] PADDR,
    output logic        PWRITE,
    output logic [31:0] PWDATA,
    output logic        PENABLE,
    output logic        PSEL0,
    output logic        PSEL1,
    output logic        PSEL2,
    output logic        PSEL3,
    output logic        PSEL4,
    input  logic [31:0] PRDATA0,
    input  logic [31:0] PRDATA1,
    input  logic [31:0] PRDATA2,
    input  logic [31:0] PRDATA3,
    input  logic [31:0] PRDATA4,
    input  logic        PREADY0,
    input  logic        PREADY1,
    input  logic        PREADY2,
    input  logic        PREADY3,
    input  logic        PREADY4,
    // Internal Interface Signal    (CPU - APB_MS)
    input  logic        transfer,  //trigger signal
    output logic        ready,
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata,
    input  logic        write      //1:write, 2:read
);
    typedef enum bit [1:0] {
        IDLE,
        SETUP,
        ACCESS
    } type_e;
    type_e state, next;
    logic [31:0] temp_addr, temp_addr_next;
    logic [31:0] temp_wdata, temp_wdata_next;
    logic temp_write, temp_write_next;
    logic decoder_en;
    logic [4:0] pselx;

    assign PSEL0 = pselx[0],
        PSEL1 = pselx[1],
        PSEL2 = pselx[2],
        PSEL3 = pselx[3],
        PSEL4 = pselx[4];
    assign PADDR = temp_addr;
    assign PWDATA = temp_wdata;

    always_ff @(posedge pclk, posedge preset) begin : state_logic
        if (preset) begin
            state      <= IDLE;
            temp_addr  <= 0;
            temp_wdata <= 0;
            temp_write <= 0;
        end else begin
            state      <= next;
            temp_addr  <= temp_addr_next;
            temp_wdata <= temp_wdata_next;
            temp_write <= temp_write_next;
        end
    end

    always_comb begin : next_logic
        next            = state;
        temp_addr_next  = temp_addr;
        temp_wdata_next = temp_wdata;
        temp_write_next = temp_write;
        PWDATA          = temp_wdata;
        PWRITE          = 1'b0;
        PENABLE         = 1'b0;
        decoder_en      = 1'b0;
        case (state)
            IDLE: begin
                decoder_en = 1'b0;
                if (transfer) begin
                    next            = SETUP;
                    // latching
                    temp_addr_next  = addr;
                    temp_wdata_next = wdata;
                    temp_write_next = write;
                end
            end
            SETUP: begin
                decoder_en = 1'b1;
                PENABLE = 1'b0;
                if (temp_write) begin
                    PWRITE = 1'b1;
                    PWDATA = temp_wdata;
                end else begin
                    PWRITE = 1'b0;
                end
                next = ACCESS;
            end
            ACCESS: begin
                decoder_en = 1'b1;
                PENABLE = 1'b1;
                if (temp_write) begin
                    PWRITE = 1'b1;
                    PWDATA = temp_wdata;
                end else begin
                    PWRITE = 1'b0;
                end

                if (ready) begin
                    next = IDLE;
                end
            end
        endcase
    end

    APB_Decoder u_APB_Decoder (
        .en (decoder_en),
        .sel(temp_addr),
        .y  (pselx)
    );

    APB_Mux u_APB_Mux (
        .sel  (temp_addr),
        .d0   (PRDATA0),
        .d1   (PRDATA1),
        .d2   (PRDATA2),
        .d3   (PRDATA3),
        .d4   (PRDATA4),
        .r0   (PREADY0),
        .r1   (PREADY1),
        .r2   (PREADY2),
        .r3   (PREADY3),
        .r4   (PREADY4),
        .rdata(rdata),
        .ready(ready)
    );

endmodule

//어떤 주변기기(패리패럴, 램메모리)를 고르는 상황인지 en신호를 디코드
module APB_Decoder (
    input  logic        en,
    input  logic [31:0] sel,
    output logic [ 4:0] y
);
    always_comb begin : decode
        y = 0;
        if (en) begin
            casex (sel) // x는 진짜로 don't care 함 나머지만 맞으면 케이스 동작
                32'h1000_0xxx: y = 5'b00001;
                32'h1000_1xxx: y = 5'b00010;
                32'h1000_2xxx: y = 5'b00100;
                32'h1000_3xxx: y = 5'b01000;
                32'h1000_4xxx: y = 5'b10000;
            endcase
        end
    end
endmodule

// 많은 주변기기(패리패럴, 램메모리)중에 하나의 신호만 걸러주는 먹스
module APB_Mux (
    input  logic [31:0] sel,
    input  logic [31:0] d0,
    input  logic [31:0] d1,
    input  logic [31:0] d2,
    input  logic [31:0] d3,
    input  logic [31:0] d4,
    input  logic        r0,
    input  logic        r1,
    input  logic        r2,
    input  logic        r3,
    input  logic        r4,
    output logic [31:0] rdata,
    output logic        ready
);
    always_comb begin : rdata_sel
        rdata = 32'bx;
        casex (sel)
            32'h1000_0xxx: rdata = d0;
            32'h1000_1xxx: rdata = d1;
            32'h1000_2xxx: rdata = d2;
            32'h1000_3xxx: rdata = d3;
            32'h1000_4xxx: rdata = d4;
        endcase
    end

    always_comb begin : ready_sel
        ready = 1'bx;
        casex (sel)
            32'h1000_0xxx: ready = r0;
            32'h1000_1xxx: ready = r1;
            32'h1000_2xxx: ready = r2;
            32'h1000_3xxx: ready = r3;
            32'h1000_4xxx: ready = r4;
        endcase
    end

endmodule
