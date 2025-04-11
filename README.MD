# RISC-V 제작

## 2025 04 08
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


## 2025 04 09  
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

## 2025 04 10
- I_Type Error Fix
  - operation selection 매커니즘에 문제가 있었음: 
    - 이슈내용: 비트코드의 최상위2번째 비트를 항상 operation에 사용하여 ADD동작에 SUB동작이 발생
    - 대처: I-TYPE을 case문을 나눔

- B_Type
  - BEQ 
  - BNE 
  - BLT 
  - BGE 
  - BLTU 
  - BGEU 

## 2025 04 11  
- LU_Type 
- AU_Type 