# 5-stage-RISC-V-pipeline.

## Problem statement

## Introduction to RISC-V architecture, and pipelining.

### Guiding Design principles in RISC-V ISA:
1) Simplicity favours regularity.
2) Smaller is faster.
3) Good design demands good compromises.

### What is pipelining?

### Why pipelining?

Execution time = IC * CPI * T <br/>
IC – Instruction count
CPI – Cycles Per Instruction
T – Clock Period.

In a single cycle processing unit the instructions are going to be executed sequentially one by one. Here CPI (Cycles Per Instruction) is low [for one instruction – one cycle] but here we are going to have a long clock period [the clock period corresponds to slowest instruction]. As a result the execution time is going to increase significantly due to long clock period, which results in less performance. This single cycle processing unit doesn’t have any benefit except its simplicity.

Picture title: Diagram representing single cycle processing unit.
![image](https://github.com/112101011/5-stage-RISC-V-pipeline./assets/111628378/565f1baa-7f5c-470f-98d9-e202809610d0)

CPI (Cycles Per Instruction): 1 <br/>
Clock period: IF_time + ID_time + EX_time + MEM_time + WB_time
		    (long clock period, critical path: ld instruction) 

In a multi-cycle processing unit each stage is executed in one cycle without pipelining. This results high CPI[one instruction 5 stages – 5 cycles] and short clock period [clock period corresponding to the longest time taken among 5 stages]. As a result execution time is going to increase and due to which performance decreases. Here one important thing to note that at each cycle, all hardware except the hardware corresponding to the stage executed in that cycle remains idle (unused). <br/>
Figure : Multicycle processing unit without pipelining. <br/>
![image](https://github.com/112101011/5-stage-RISC-V-pipeline./assets/111628378/1092caa2-fae6-447a-b17a-404f6f59b6f6) <br/>

CPI : 5 <br/>
Clock period:  max{IF_time, ID_time, EX_time, MEM_time,  WB_time}

### Stages in RISC-V pipeline:
Similar to MIPS architecture there are 5 stages in RISC-V ISA(Instruction Set Architecture) :
1) IF : Instruction fetch from Instruction cache.
2) ID : Instruction Decode and Register read.
3) EX: Execute Operations[eg: add, sub] (or) Calculate address[ld, sd].
4) MEM: Access memory operands from data cache.
5) WB: Write result back to the register in register file.


## Challenges for pipelining

## Pictorial view of pipelined datapath:

## Forwarding unit

Forwarding unit is added in this data path to decrease the number of stalls and there by decreasing CPI and increasing performance of the processing unit.
The forwarding unit decides the operands to be sent to the ALU. The below conditions make sure that the most recent value is forwarded. The most recent value to forward will be there in EX/MEM pipeline.

1) If rs1 in ID/EX pipeline is equal to rd of EX/MEM pipeline, with write back in EX/MEM, and registers not being zero, then alu_result in EX/MEM is passed as operand A.
2) If the above condition is not satisfied and if rs1 in ID/EX is equal to rd of MEM/WB pipeline, with registers not being zero and write back is on. <br/>
   a) If write back signals in MEM/WB is indicating that the instruction in it was load then register value corresponding to the value read from data cache is passed.<br/>
   b) If not then alu_result from MEM/WB is passed.
3) If all the above conditions are not met then read_data1 from ID/EX is passed as operand A to ALU.

For operand B, the similar conditions are checked as above but additionally making sure that immediate is passed whenever instruction ID/EX is not R-type. As the conditions for passing B is complicated than A that can be verified from the Verilog code.

## Descirption of verilog code of data path

## Writing test bench

## Timing diagrams 

## Power consumption and time delay reports by vivado

## Further scope
1) Adding additional hardware at ID stage for branch instructions to reduce the number of stalls for control Hazards (or) maintaining a branch predictor static or dynamic branch predictor.
2) Increasing the number of stages so that on an average for many instructions the average performance can be increased significantly.
