# 5-stage-RISC-V-pipeline.

## Problem statement

## Introduction to RISC-V architecture:
RISC-V is an open-source instruction set architecture (ISA) designed for computer processors. It stands for "Reduced Instruction Set Computer - Five." The RISC-V architecture is based on the concept of reduced instruction set computing, which emphasizes simplicity and efficiency by using a smaller set of instructions.
More specifically, RISC-V has been used in cloud computing, servers, and embedded applications.

### Guiding Design principles in RISC-V ISA:
1) Simplicity favours regularity.
2) Smaller is faster.
3) Good design demands good compromises.

## Pipelining:

### What is pipelining?
Pipelining is a technique where multiple sub-tasks of instructions are implemented at the same time. Pipelining allows mutiple sub‐tasks to be carried out simultaneously using independent resources(Instruction level parallelism) <br/>

Let us consider a real life example of manufacturing a car, let the steps require to build a car be: <br/>
![pic5](https://github.com/112101011/5-stage-RISC-V-pipeline./assets/111628378/24763001-d402-4bed-8255-db61b8a09475)
let each sub-task takes 20 minutes. <br/>

Suppose at each time unit, only one sub-task can be performed then: <br/>
![pic3](https://github.com/112101011/5-stage-RISC-V-pipeline./assets/111628378/cda13893-9402-4668-bc74-d8107a5354fa)
Suppose pipelining is allowed then: <br/>
![pic4](https://github.com/112101011/5-stage-RISC-V-pipeline./assets/111628378/a99cff10-592f-4896-a902-e6e63fb4d924)

From the above pictures we can clearly see the advantage of pipelining in using the resources effeciently and thereby consuming less time. <br/>

###  5-stages for implementing instruction(in general):
Similar to MIPS architecture there are 5 stages in RISC-V ISA(Instruction Set Architecture) :
1) IF : Instruction fetch from Instruction cache.
2) ID : Instruction Decode and Register read.
3) EX: Execute Operations[eg: add, sub] (or) Calculate address[ld, sd].
4) MEM: Access memory operands from data cache.
5) WB: Write result back to the register in register file.

### Why pipelining in computer architecture?

Execution time = IC * CPI * T <br/>
IC – Instruction count
CPI – Cycles Per Instruction
T – Clock Period.

In a single cycle processing unit the instructions are going to be executed sequentially one by one. Here CPI (Cycles Per Instruction) is low [for one instruction – one cycle] but here we are going to have a long clock period [the clock period corresponds to slowest instruction]. As a result the execution time is going to increase significantly due to long clock period, which results in less performance. This single cycle processing unit doesn’t have any benefit except its simplicity.

Picture title: Diagram representing single cycle processing unit: <br/>
![pic1](https://github.com/112101011/5-stage-RISC-V-pipeline./assets/111628378/39e8201e-d7c7-4a26-a98d-416471c1e3ad)


CPI (Cycles Per Instruction): 1 <br/>
Clock period: IF_time + ID_time + EX_time + MEM_time + WB_time
		    (long clock period, critical path: ld instruction) 

In a multi-cycle processing unit each stage is executed in one cycle without pipelining. This results high CPI[one instruction 5 stages – 5 cycles] and short clock period [clock period corresponding to the longest time taken among 5 stages]. As a result execution time is going to increase and due to which performance decreases. Here one important thing to note that at each cycle, all hardware except the hardware corresponding to the stage executed in that cycle remains idle (unused). <br/>
Figure : Multicycle processing unit without pipelining. <br/>
![pic2](https://github.com/112101011/5-stage-RISC-V-pipeline./assets/111628378/4977cf46-0dad-4bd1-bfa4-cd340d9b8903)


CPI : 5 <br/>
Clock period:  max{IF_time, ID_time, EX_time, MEM_time,  WB_time}

### Challenges for pipelining

## Datapath:

## Pictorial view of pipelined datapath:
![pic6](https://github.com/112101011/5-stage-RISC-V-pipeline./assets/111628378/8961486e-6f1c-4cd8-9818-44850725064e)


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
