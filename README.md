# 5-stage-RISC-V-pipeline.

## Problem statement

## Introduction to RISC-V architecture, and pipelining.

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
