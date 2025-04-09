`timescale 1ns / 1ps

`include "defines.sv"

module DataPath (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instrCode,
    output logic [31:0] instrMemAddr,
    input  logic        regFileWe,
    input  logic [ 3:0] alu_Control,
    input  logic        aluSrcMuxSel,
    output logic [31:0] dataAddr,
    output logic [31:0] dataWData,
    input  logic        wDataSrcMuxSel,
    input  logic [31:0] ramData
);
    logic [31:0] result, rData1, rData2;
    logic [31:0] PCSrcData, PCOutData;
    logic [31:0] immExt, aluSrcMuxOut;
    logic [31:0] wDataSrcMuxOut;

    assign instrMemAddr = PCOutData;
    assign dataAddr     = result;
    assign dataWData    = rData2;

    RegisterFile u_RegisterFile (
        .clk   (clk),
        .we    (regFileWe),
        .rAddr1(instrCode[19:15]),
        .rAddr2(instrCode[24:20]),
        .wAddr (instrCode[11:7]),
        .wData (wDataSrcMuxOut),
        .rData1(rData1),
        .rData2(rData2)
    );

    mux_2x1 u_ALUSrcMux (
        .sel(aluSrcMuxSel),
        .x0 (rData2),
        .x1 (immExt),
        .y  (aluSrcMuxOut)
    );

    alu u_alu (
        .alu_Control(alu_Control),
        .a          (rData1),
        .b          (aluSrcMuxOut),
        .result     (result)
    );

    mux_2x1 u_WDataSrcMux (
        .sel(wDataSrcMuxSel),
        .x0 (result),
        .x1 (ramData),
        .y  (wDataSrcMuxOut)
    );

    extend u_ImmExtend (
        .instrCode(instrCode),
        .immExt   (immExt)
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
    input  logic [ 3:0] alu_Control,
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] result
);
    always_comb begin : alu_sel
        case (alu_Control)
            `ADD:    result = a + b;
            `SUB:    result = a - b;
            `SLL:    result = a << b;
            `SRL:    result = a >> b;
            `SRA:    result = $signed(a) >>> b[4:0];
            `SLT:    result = ($signed(a) < $signed(b)) ? 1 : 0;
            `SLTU:   result = (a < b) ? 1 : 0;
            `XOR:    result = a ^ b;
            `OR:     result = a | b;
            `AND:    result = a & b;
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

module mux_2x1 (
    input logic sel,
    input logic [31:0] x0,
    input logic [31:0] x1,
    output logic [31:0] y
);
    always_comb begin : select
        case (sel)
            0: y = x0;
            1: y = x1;
        endcase
    end
endmodule

module extend (
    input  logic [31:0] instrCode,
    output logic [31:0] immExt
);
    wire [6:0] opcode = instrCode[6:0];

    always_comb begin : extend_imm
        immExt = 32'bx;
        //{b{a}} a비트를 b만큼 반복한다. imm이 signed비트이기 때문에 최상위 부호 비트로 꽉 채워서 확장한다.
        case (opcode)
            `R_Type: immExt = 32'bx;
            `L_Type: immExt = {{20{instrCode[31]}}, instrCode[31:20]};
            `I_Type: immExt = {{20{instrCode[31]}}, instrCode[31:20]};
            `S_Type:
            immExt = {{20{instrCode[31]}}, instrCode[31:25], instrCode[11:7]};
        endcase
    end
endmodule
