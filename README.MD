# RISC-V Project

## RV32I
### instruction set
![InstructuonSet](./RV32I-1.png) 

### SingleCycleRISC-V

#### 2025 04 08
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


#### 2025 04 09  
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

#### 2025 04 10
- I_Type Error Fix 
  - operation selection 매커니즘 이슈: 
    - issue:  
      비트코드의 최상위2번째 비트를 항상 operation에 사용하여 ADDI동작에 SUB연산이 동작 
    - fix:  
      I-TYPE을 연산에 따라 case문으로 나눔 
- B_Type 
  - BEQ 
  - BNE 
  - BLT 
  - BGE 
  - BLTU 
  - BGEU 

#### 2025 04 10
- LU_Type
- AU_Type
- J_Type
- JR_Type

#### 2025 04 14
- Single Cycle RISC-V 완성 

#### 2025 04 15
- Single Cycle RISC-V 발표 

#### 2025 04 16
- B_Type Error Fix 
  - immExt 매커니즘 이슈: 
    - issue:  
    B_Type immExt에 Unsigned Integer Extend 매커니즘이 동작하고있었음. 
    - fix:  
    B_Type immExt 매커니즘을 Signed Integer 매커니즘으로 변경

### MultiCtcleRISC-V 

#### 2025 04 17
 - Fethc/Decode/Execute/MemAcc/WriteBack 스테이지에 대한 공부 
 - MultiCtcleProccesing 매커니즘 완성

### AMBA APB Protocol
  #### study
----------
  - rom, ram, z/0 의 CS(Chip Select) 신호는 LOW ACTIVE이다:    
    ![alt text](addr_map.png)  
  LOW ACTIVE의 경우 비교적 노이즈에 강하다. High Active의 경우 전압이 높아야 활성화되므로 노이즈에 취약하다.  
  ![alt text](image-2.png)  
  GPT는 똑똑하다  
----------
  -  cpu는 주변기기를 RAM과 구분하지 않고 같은 신호를 공통선에 보내버린다. DECODER로 ENsig를 제어해줘서 주변기기를 제어해야한다.  
    <img src="image.png" alt="alt text" style="width:70%;">  
    ![alt text](image-1.png)  
    