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

## Instruction formats in RISC-V:

R-format: <br/>
![pic 9](https://github.com/112101011/5-stage-RISC-V-pipeline./assets/111628378/7c63a033-1766-4809-b040-a53d1f9574e1)

I-format: <br/>
![pic 10](https://github.com/112101011/5-stage-RISC-V-pipeline./assets/111628378/4c37530b-f82d-4cc4-9665-83eac1c5c18b)

S-format: <br/>
![pic11](https://github.com/112101011/5-stage-RISC-V-pipeline./assets/111628378/82e9c3bd-70d8-4a8a-8719-580318a9378e)

## Datapath:

![pic6](https://github.com/112101011/5-stage-RISC-V-pipeline./assets/111628378/8961486e-6f1c-4cd8-9818-44850725064e)
Note: Red wires depict the input and output of forwarding logic. The number in orange color boxes depict the number of bits. 

### Instruction cache and data cache:

### Register file:
There are 32 64-bit registes in register file of RISC-V architecture.

|registers| purpose |
|---------|---------|
X0|The constant value 0
X1 | return address
X2 | stack pointer
X3 | global pointer
X4 | thread pointer
X5 - X7, X28 - X31 | temporaries
X8 | frame pointer
X9, X18 - X27 | saved registers
X10 - X11 | function arguments/results
X12 - X17 | function arguments

### Role of immediate generator:
![pic8](https://github.com/112101011/5-stage-RISC-V-pipeline./assets/111628378/b7e53f0f-bb85-441d-a6b5-cac13caf92f4)
This imm generator performs sign extension of 12-bit immediate to 64-bit immediate. The reason for extension is that other registers in register file are 64-bit and the ALU is designed for 64-bits. 

### Role of 64-bit ALU:
In the data path designed here the ALU is designed for 64-bits and it performs addition and subtraction by carry look ahead adder logic and multiplication by booth’s algorithm. It gives one output of 64-bits size. <br/>
![pic7](https://github.com/112101011/5-stage-RISC-V-pipeline./assets/111628378/c68262dc-7ae2-431e-9220-76ceca6e3cb4)

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

Initially 12 instructions are written in ins-cache including two stalls. Data values 45, 20, -20 are written at the locations 0, 1, 2 of data cache. We can observe that in total 5 clock cycles are taken to completely run a instruction, ld – the critical instruction requires all the 5-stages completely. <br/>

The forwarding lines are indicated in red. As there is full forwarding there is no requirement of STALLs in first 6 instructions. In the below picture instructions and its computation is shown along with full forwarding:
![pic 13](https://github.com/112101011/5-stage-RISC-V-pipeline./assets/111628378/44b65d70-a9f3-4711-8de7-29edd18201b5) <br/>

Including 2 stalls and 10 instructions on total we can say that 12 instructions are executed. Here stalls are implemented by add x0, x0, x0. <br/>
Total Number of cycles for this 10 instructions(2-stalls) = 16 <br/>
Actual Number of instructions = 10 <br/>
Stalls = 2 <br/>
[average CPI]: CPI = (16) / (10) = 1.6 (2-stalls are not considered as instructions) <br/>
The CPI is not 1(ideal) because some time  is required to get full pipelining. <br/>
Analysis of timing diagram with the help of test bench written:

After writing the instructions in the instruction cache and data values in data cache the scenario is: <br/>
Instruction Cache: <br/>
![Picture1](https://github.com/112101011/5-stage-RISC-V-pipeline./assets/111628378/35b7198a-5ca6-45ce-abf3-a2b1a5201259) <br/>
Data-cache: <br/>
![Picture2](https://github.com/112101011/5-stage-RISC-V-pipeline./assets/111628378/9f76abe9-ceb7-4125-b0c6-2356166933a8) <br/>


## Timing diagram:
![pic19](https://github.com/112101011/5-stage-RISC-V-pipeline./assets/111628378/388b7eb7-e92c-45b0-a33a-7ac61d258f18) <br/>
The register  values in each cycle can be observed from the above timing diagram. pipeline_IF_ID, pipeline_ID_EX, pipeline_EX_MEM, pipeline_MEM_WB, represents the pipeline register values. data_written_in_regfile represents the data written back in the register file. data_written_in_data_mem represents the data written in the data cache. data_written_in_ins_mem represents the data written in the ins cache. <br/>


## Power consumption and time delay reports by vivado

## Further scope
1) Adding additional hardware at ID stage for branch instructions to reduce the number of stalls for control Hazards (or) maintaining a branch predictor static or dynamic branch predictor.
2) Increasing the number of stages so that on an average for many instructions the average performance can be increased significantly.
