`timescale 1ns / 1ps

module DataPath (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instrCode,
    output logic [31:0] instrMemAddr,
    input  logic        regFileWe,
    input  logic [ 1:0] alu_Control
);
    logic [31:0] result, rData1, rData2;
    logic [31:0] PCSrcData, PCOutData;

    assign instrMemAddr = PCOutData;

    RegisterFile u_RegisterFile (
        .clk   (clk),
        .we    (regFileWe),
        .rAddr1(instrCode[19:15]),
        .rAddr2(instrCode[24:20]),
        .wAddr (instrCode[11:7]),
        .wData (result),
        .rData1(rData1),
        .rData2(rData2)
    );

    alu u_alu (
        .alu_Control(alu_Control),
        .a          (rData1),
        .b          (rData2),
        .result     (result)
    );

    register u_ProgramCounter (
        .clk  (clk),
        .reset(reset),
        .d    (PCSrcData),
        .q    (PCOutData)
    );

    adder u_adder (
        .a(32'd4),
        .b(PCOutData),
        .y(PCSrcData)
    );

endmodule

module alu (
    input  logic [ 1:0] alu_Control,
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] result
);
    typedef enum int {
        ADD = 2'b00,
        SUB = 2'b01,
        OR  = 2'b10,
        AND = 2'b11
    } name;
    always_comb begin : alu
        case (alu_Control)
            ADD: result = a + b;
            SUB: result = a - b;
            OR: result = a | b;
            AND: result = a & b;
            default: result = 32'bx;
        endcase
    end
endmodule

module register (
    input logic clk,
    input logic reset,
    input logic [31:0] d,
    output logic [31:0] q
);
    always_ff @(posedge clk, posedge reset) begin : blockName
        if (reset) q <= 0;
        else q <= d;
    end
endmodule

module adder (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] y
);
    assign y = a + b;
endmodule

module RegisterFile (
    input logic clk,
    input logic we,
    input logic [4:0] rAddr1,
    input logic [4:0] rAddr2,
    input logic [4:0] wAddr,
    input logic [31:0] wData,
    output logic [31:0] rData1,
    output logic [31:0] rData2
);
    logic [31:0] RegFile[0:2**5-1];

    always_ff @(posedge clk) begin : write
        if (we) RegFile[wAddr] = wData;
    end

    always_comb begin : read
        rData1 = (rAddr1) ? RegFile[rAddr1] : 0;
        rData2 = (rAddr2) ? RegFile[rAddr2] : 0;
    end

    initial begin
        for (int i = 0; i < 32; i++) begin
            RegFile[i] = 10 + i;
        end
    end
endmodule
