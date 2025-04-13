`timescale 1ns / 1ps

`include "../../sources_1/new/defines.sv"

module tb_rv32i ();
    logic clk;
    logic reset;
    MCU u_MCU (.*);

    task automatic mon_type();
        logic [6:0] t = u_MCU.u_Core.u_ControlUnit.instrCode[6:0];
        logic [6:0] op = u_MCU.u_Core.u_ControlUnit.alu_Control;
        logic [31:0] alu1 = u_MCU.u_Core.u_DataPath.rData1;
        logic [31:0] alu2 = u_MCU.u_Core.u_DataPath.aluSrcMuxOut;
        logic [31:0] alu_cal = u_MCU.u_Core.u_DataPath.calculator_result;
        logic [31:0] wdata = u_MCU.u_Core.u_DataPath.wDataSrcMuxOut;
        logic [31:0] rs2 = u_MCU.u_Core.u_DataPath.rData2;
        logic [31:0] imm = u_MCU.u_Core.u_DataPath.immExt;
        logic [31:0] pc = u_MCU.u_Core.u_DataPath.PCOutData;
        logic [31:0] pc4 = u_MCU.u_Core.u_DataPath.PC_4_AdderResult;
        logic [31:0] pcImm = u_MCU.u_Core.u_DataPath.PC_Imm_AdderResult;
        logic [31:0] romAddr = u_MCU.u_rom.addr;
        logic [31:0] pcR1 = u_MCU.u_Core.u_DataPath.PC_R1_AdderResult;

        string tp;
        case (t)
            `R_Type: begin
                tp = "R_Type";
                case (op)
                    `ADD: $display("%s - %d + %d = %d", tp, alu1, alu2, wdata);
                    `SUB: $display("%s - %d - %d = %d", tp, alu1, alu2, wdata);
                    `SLL: $display("%s - %d << %d = %d", tp, alu1, alu2, wdata);
                    `SRL: $display("%s - %d >> %d = %d", tp, alu1, alu2, wdata);
                    `SRA:
                    $display("%s - %d >>> %d = %d", tp, alu1, alu2, wdata);
                    `SLT: $display("%s - %d < %d = %d", tp, alu1, alu2, wdata);
                    `SLTU:
                    $display("%s - %d < %d = %d (U)", tp, alu1, alu2, wdata);
                    `XOR: $display("%s - %d ^ %d = %d", tp, alu1, alu2, wdata);
                    `OR: $display("%s - %d | %d = %d", tp, alu1, alu2, wdata);
                    `AND: $display("%s - %d & %d = %d", tp, alu1, alu2, wdata);
                    default: $display("None_func_Error", t);
                endcase
            end
            `L_Type: begin
                $display("L_Type - %d, %d", wdata,
                         u_MCU.u_ram.mem[alu_cal/4]);
            end
            `I_Type: begin
                tp = "I_Type";
                case (op)
                    `ADD: $display("%s - %d + %d = %d", tp, alu1, alu2, wdata);
                    `SLT: $display("%s - %d < %d = %d", tp, alu1, alu2, wdata);
                    `SLTU:
                    $display("%s - %d < %d = %d (U)", tp, alu1, alu2, wdata);
                    `XOR: $display("%s - %d ^ %d = %d", tp, alu1, alu2, wdata);
                    `OR: $display("%s - %d | %d = %d", tp, alu1, alu2, wdata);
                    `AND: $display("%s - %d & %d = %d", tp, alu1, alu2, wdata);
                    `SLL: $display("%s - %d << %d = %d", tp, alu1, alu2, wdata);
                    `SRL: $display("%s - %d >> %d = %d", tp, alu1, alu2, wdata);
                    `SRA:
                    $display("%s - %d >>> %d = %d", tp, alu1, alu2, wdata);
                    default: $display("None_func_Error", t);
                endcase
            end
            `S_Type:
            $display("S_Type - %d, %d", alu_cal, rs2);
            `B_Type: $display("B_Type - %d, %d, %d", pc, pcImm, romAddr>>2);
            `LU_Type: $display("LU_Type - %d, %d", wdata, imm);
            `AU_Type: $display("AU_Type - %d, %d", wdata, pcImm);
            `J_Type: $display("J_Type - %d, %d, %d", wdata, pc4, pcImm);
            `JL_Type: $display("JL_Type - %d, %d, %d", wdata, pc4, pcR1);
            default: $display("None_Type_Error");
        endcase
    endtask  //automatic

    always #5 clk = ~clk;

    always @(posedge clk) begin
        mon_type();
    end

    initial begin
        clk   = 0;
        reset = 1;
        #1 reset = 0;
        #170 $finish;
    end
endmodule
