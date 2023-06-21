/*
R-type instructions
add                 1000000_rs2_rs1_000_rd_0110011
sub                 0100000_rs2_rs1_000_rd_0110011
mul                 0000001_rs2_rs1_000_rd_0110011

I-type instructions
addi                imm(12bits)_rs1_000_rd_0010011 
ld                  imm(12bits)_rs1_011_rs_0000011

S-type instructions
sd                  imm[11:5]_rs2_rs1_011_imm[4:0]_0100011
*/
`timescale 1ns / 1ps

module test_bench;
    reg clk;
    reg [31:0]instruction; 
    reg instruction_memory_cycle; 
    reg data_memory_cycle;
    reg [64:0]data;
    reg [3:0]data_location;
    
    wire [63:0]PC;
    wire [95:0]pipeline_IF_ID;
    wire [289:0]pipeline_ID_EX;
    wire [202:0]pipeline_EX_MEM;
    wire [134:0]pipeline_MEM_WB;
    wire [63:0]data_written_in_regfile;
    wire [63:0]data_written_in_data_mem;
    wire [31:0]data_written_in_ins_mem;
    wire overflow;
    
    pipelined_datapath uut(
    clk, 
    instruction, 
    instruction_memory_cycle, 
    data_memory_cycle,
    data,
    data_location,
    
    
    PC,
    pipeline_IF_ID,
    pipeline_ID_EX,
    pipeline_EX_MEM,
    pipeline_MEM_WB,
    data_written_in_regfile,
    data_written_in_data_mem,
    data_written_in_ins_mem,
    overflow
    );
    
    initial
    begin
        clk = 1'b0;

        instruction = 32'b00000000000011101000111010010011;// addi x29, x29, 0 (I - type instruction)
        instruction_memory_cycle = 1'b1;
        data_memory_cycle = 1'b0;
        data = 0;
        data_location = 0;     
        
        #2
        instruction = 32'b00000000000111110000111100010011;//  addi x30, x30, 1 (I - type instruction)
        instruction_memory_cycle = 1'b1;
        data_memory_cycle = 1'b0;
        data = 0;
        data_location = 0;
        
        #2
        instruction = 32'b00000000000011101011111000000011;// ld x28, 0(x29)
        instruction_memory_cycle = 1'b1;
        data_memory_cycle = 1'b0;
        data = 0;
        data_location = 0;
         
         #2
        instruction = 32'b00000000000011110011110110000011; // ld x27 0(x30)
        instruction_memory_cycle = 1'b1;
        data_memory_cycle = 1'b0;
        data = 0;
        data_location = 0;
        
        #2 
        instruction = 32'b10000001110111100000010100110011; // add x10, x28, x29
        instruction_memory_cycle = 1'b1;
        data_memory_cycle = 1'b0;
        data = 0;
        data_location = 0;
                
        #2 
        instruction = 32'b00000000101011101011000000100011;// sd x10, 0(x29)
        instruction_memory_cycle = 1'b1;
        data_memory_cycle = 1'b0;
        data = 0;
        data_location = 0;
        
        #2
        instruction = 32'b00000000000011101011010110000011; // ld x11 0(x29)
        instruction_memory_cycle = 1'b1;
        data_memory_cycle = 1'b0;
        data = 0;
        data_location = 0;
        
        #2
        instruction = 32'b10000000000000000000000000110011; // add x0, x0, x0 (R-type instruction) STALL
        instruction_memory_cycle = 1'b1;
        data_memory_cycle = 1'b0;
        data = 0;
        data_location = 0;
        
        #2
        instruction = 32'b00000010101111110000001100110011; // mul x6, x11, x31 (R-type instruction)
        instruction_memory_cycle = 1'b1;
        data_memory_cycle = 1'b0;
        data = 0;
        data_location = 0;
        
        // Putting -20 from data to register x18
        #2
        instruction = 32'b00000000000111110011100100000011; // ld x18 1(x30)
        instruction_memory_cycle = 1'b1;
        data_memory_cycle = 1'b0;
        data = 0;
        data_location = 0;
        
        #2
        instruction = 32'b10000000000000000000000000110011; // add x0, x0, x0 (R-type instruction) STALL
        instruction_memory_cycle = 1'b1;
        data_memory_cycle = 1'b0;
        data = 0;
        data_location = 0;
        
        #2
        instruction = 32'b01000001001011011000110110110011;//  sub x19, x27, x18 (R - type instruction)
        instruction_memory_cycle = 1'b1;
        data_memory_cycle = 1'b0;
        data = 0;
        data_location = 0;
        
        
        // Data 45 at data_cache[0]
        #2
        instruction = 0;
        instruction_memory_cycle = 1'b0; 
        data_memory_cycle = 1'b1;
        data = 45;
        data_location = 0;
        
        // Data -20 at data_cache[1]
         #2
        instruction = 0;
        instruction_memory_cycle = 1'b0;
        data_memory_cycle = 1'b1;
        data = 20;
        data_location = 1;
        
        // Data 20 at data_cache[2]
        #2
        instruction = 0;
        instruction_memory_cycle = 1'b0;
        data_memory_cycle = 1'b1;
        data = -20;
        data_location = 2;
        
        #2
        instruction = 0;
        instruction_memory_cycle = 1'b0;
        data_memory_cycle = 1'b0;
        data = 0;
        data_location = 0;
    end   
    
    always #1 clk = ~clk;
    
    initial #75 $finish;
endmodule
