# RISC-V 제작

## SingleCycleRISC-V

### 2025 04 08
- R_Type 
    - ADD 
    - SUB 
    - SLL 
    - SRL 
    - SRA 
    - SLT 
    - SLTU 
    - XOR 
    - OR 
    - AND 


### 2025 04 09  
- S_Type 
  - SW 

- L_Type
  - LW   

- I_Type 
  - ADDI 
  - SLTI 
  - SLTUI 
  - XORI 
  - ORI 
  - ANDI 
  - SLLI 
  - SRLI 
  - SRAI 

### 2025 04 10
- I_Type Error Fix 
  - operation selection 매커니즘에 문제가 있었음: 
    - 이슈내용: 비트코드의 최상위2번째 비트를 항상 operation에 사용하여 ADDI동작에 SUB연산이 동작 
    - 대처: I-TYPE을 연산에 따라 case문으로 나눔 

- B_Type 
  - BEQ 
  - BNE 
  - BLT 
  - BGE 
  - BLTU 
  - BGEU 

### 2025 04 10
- LU_Type
- AU_Type
- J_Type
- JR_Type

### 2025 04 14
- Single Cycle RISC-V 완성 

### 2025 04 15
- Single Cycle RISC-V 발표 

## MultiCtcleRISC-V 

### 2025 04 17
 - Fethc/Decode/Execute/MemAcc/WriteBack 스테이지에 대한 공부 