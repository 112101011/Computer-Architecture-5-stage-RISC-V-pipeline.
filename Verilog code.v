module pipelined_datapath(
    input clk, 
    input [31:0]instruction, 
    input instruction_memory_cycle, 
    input data_memory_cycle,
    input [64:0]data,
    input [3:0]data_location, // 10 locations needed
    
    output [63:0]PC,
    output [95:0]pipeline_IF_ID,
    output [289:0]pipeline_ID_EX,
    output [202:0]pipeline_EX_MEM,
    output [134:0]pipeline_MEM_WB,
    output reg [63:0]data_written_in_regfile,
    output reg [63:0]data_written_in_data_mem,
    output reg [31:0]data_written_in_ins_mem,
    output reg overflow
    );
    
    /*
    20 32-bit instructions can be stored in instruction memory
    */
    reg [31:0]instruction_memory[19:0];
    
    /*
    20 64-bit data can be stored in data memory
    */
    reg [63:0]data_memory[19:0];
    
    /*
    32 64-bit register file
    */
    reg [31:0]register_file[63:0];
    
    /*
    IF/ID pipeline
    PC - 64 bits
    instruction - 32 bits
    total bits = 96 
    */
    reg [95:0]pipeline_IF_ID;
    
    /*
    ID/EX pipeline
    write back signals - 2 bits (register write signal , mem to reg signal)
    memory signals - 3 bits
                      (memory read, memory write, branch) 
    execution : opcode - 7 bits
                funct7 - 7 bits
    PC - 64 bits 
    read_data1 = 64 bits
    read_data2 = 64 bits
    rs1 = 5 bits
    rs2 = 5 bits
    immediate sign extended = 64 bits
    rd = 5 bits
    total = 2 + 3 + 7 + 7 + 64 + 64 + 64 + 5 + 5 + 64 + 5 = 290 bits
    */
    reg [289:0]pipeline_ID_EX;
    
    /* 
    EX/MEM pipeline
    write back signals - 2 bits (register write signal , mem to reg signal)
    memory signals - 3 bits
                      (memory read, memory write, branch)
    new branch = 64 bits
    alu_branch_signal = 1 bit
    alu_result = 64 bits
    read_data2 = 64 bits
    rd = 5 bits
    
    total_bits = 203 bits
    */
    reg [202:0]pipeline_EX_MEM;
    
    /*
    MEM/WB pipeline
    write back signals - 2 bits (register write signal , mem to reg signal)
    mem data = 64 bits
    alu_result = 64 bits
    rd = 5 bits
    
    total bits = 135 bits
    */
    reg [134:0]pipeline_MEM_WB;
    
    integer iterator = 0;
    integer i;
    
    reg [63:0]PC;
    
    reg [63:0]A;
    reg [63:0]B;
    reg [63:0]B1;
    reg [63:0]G;
    reg [63:0]P;
    reg [63:0]sum;
    reg [64:0]carry;
    reg [127:0]mul;
    reg [1:0]temp;
    reg E1;
    reg [63:0]alu_result;
    
    reg PC_source;

    always @ (posedge clk)
    begin
        register_file[0] <= 0;
        if (instruction_memory_cycle == 1'b1)
        begin
            // initially to put instructions in instructiojn memory
            PC <= 0;
            for(i = 0; i <= 31; i = i + 1)
            begin
                register_file[i] = 0;
            end
            
            pipeline_IF_ID <= 0;
            pipeline_ID_EX <= 0;
            pipeline_EX_MEM <= 0;
            pipeline_MEM_WB <= 0;
            alu_result <= 0;
    
            instruction_memory[iterator] <= instruction;
            iterator <= iterator + 1;
            
            data_written_in_regfile <= 0;
            data_written_in_data_mem <= 0;
            data_written_in_ins_mem <= instruction;
        end
        else if (data_memory_cycle == 1'b1)
        begin
            // initially to put some data into the data memory
            pipeline_IF_ID <= 0;
            pipeline_ID_EX <= 0;
            pipeline_EX_MEM <= 0;
            pipeline_MEM_WB <= 0;
            alu_result <= 0;
            data_memory[data_location] <= data;
            
            data_written_in_regfile <= 0;
            data_written_in_data_mem <= data;
            data_written_in_ins_mem <= 0;
        end
        else
        begin

// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
            // instrction fetch
            pipeline_IF_ID[63:0] <= PC; 
            pipeline_IF_ID[95:64] <= instruction_memory[PC >> 2];
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
           // Write back stage
           if (pipeline_MEM_WB[0] == 1'b1) // register write signal
           begin
                if(pipeline_MEM_WB[1] == 1'b1) // writing data memory result
                begin
                    register_file[pipeline_MEM_WB[134:130]] <= pipeline_MEM_WB[65:2];
                    data_written_in_regfile <= pipeline_MEM_WB[65:2];
                end
                else
                begin
                    register_file[pipeline_MEM_WB[134:130]] <= pipeline_MEM_WB[129:66];
                    data_written_in_regfile <= pipeline_MEM_WB[129:66];
                end    
           end
           else
           begin
                data_written_in_regfile <= 0;
           end
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
           // program counter calculation and memory stage 
            PC_source <= pipeline_EX_MEM[2] & pipeline_EX_MEM[69];
            
            if (PC_source == 1'b1)
            begin
                PC <= pipeline_EX_MEM[68:5];
            end
            else
            begin
                PC <= PC + 4;
            end
            
           if(pipeline_EX_MEM[4] == 1'b1) // read(ld)
           begin
                pipeline_MEM_WB[65:2] <= data_memory[pipeline_EX_MEM[133:70]];
                
                data_written_in_data_mem = 0;
           end
           else if(pipeline_EX_MEM[3] == 1'b1) // write(sd)
           begin
                pipeline_MEM_WB[65:2] <= 0;
                data_memory[pipeline_EX_MEM[133:70]] <= pipeline_EX_MEM[197:134]; // read data 2
                 
                data_written_in_data_mem <= pipeline_EX_MEM[197:134];
           end
           else
           begin
                pipeline_MEM_WB[65:2] <= 0;
                
                data_written_in_data_mem = 0;
           end

           pipeline_MEM_WB[1:0] <= pipeline_EX_MEM[1:0]; // write back signals
           pipeline_MEM_WB[129:66] <= pipeline_EX_MEM[133:70]; // alu result
           pipeline_MEM_WB[134:130] <= pipeline_EX_MEM[202:198]; // destination register
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
           // Execution stage
           
           // Forwarding Logic with multiplexers
           if((pipeline_EX_MEM[202:198] != 5'b00000) && (pipeline_EX_MEM[202:198] == pipeline_ID_EX[215:211]) && (pipeline_EX_MEM[0] == 1'b1) && (pipeline_EX_MEM[1] == 1'b0))
           begin
                A = pipeline_EX_MEM[133:70]; // alu result
           end
           else if((pipeline_MEM_WB[134:130] != 5'b00000) && (pipeline_MEM_WB[134:130] == pipeline_ID_EX[215:211]) && (pipeline_MEM_WB[0] == 1'b1))
           begin
                if(pipeline_MEM_WB[1] == 1'b1)
                begin
                    A = pipeline_MEM_WB[65:2]; // data from data_memory
                end
                else
                begin
                    A = pipeline_MEM_WB[129:66]; // alu result
                end         
           end
           else
           begin
                A = pipeline_ID_EX[146:83]; // read data 1
           end 
          
          
           if ((pipeline_EX_MEM[202:198] != 5'b00000) && (pipeline_EX_MEM[202:198] == pipeline_ID_EX[220:216]) && (pipeline_EX_MEM[0] == 1'b1) && (pipeline_EX_MEM[1] == 1'b0) )
           begin
                if (pipeline_ID_EX[11:5]  != 7'b0110011)
                begin
                    pipeline_EX_MEM[197:134] <= pipeline_EX_MEM[133:70]; // alu result
                    B = pipeline_ID_EX[284:221]; // immediate
                end
                else
                begin
                    pipeline_EX_MEM[197:134] <= pipeline_ID_EX[210:147]; // read data 2
                    B = pipeline_EX_MEM[133:70]; // alu result
                end         
           end
           else if((pipeline_MEM_WB[134:130] != 5'b00000) && (pipeline_MEM_WB[134:130] == pipeline_ID_EX[220:216]) &&  (pipeline_MEM_WB[0] == 1'b1))
           begin
                if(pipeline_MEM_WB[1] == 1'b1) // ld 
                begin
                     if (pipeline_ID_EX[11:5]  != 7'b0110011)
                    begin
                        pipeline_EX_MEM[197:134] <= pipeline_MEM_WB[65:2]; // data from data mem
                        B = pipeline_ID_EX[284:221]; // immediate
                    end
                    else
                    begin
                        pipeline_EX_MEM[197:134] <= pipeline_ID_EX[210:147]; // read data 2
                        B = pipeline_MEM_WB[65:2]; // data from data memory
                    end  
                end
                else
                begin
                     if (pipeline_ID_EX[11:5]  != 7'b0110011)
                    begin
                        pipeline_EX_MEM[197:134] <= pipeline_MEM_WB[129:66]; // data from data mem
                        B = pipeline_ID_EX[284:221]; // immediate
                    end
                    else
                    begin
                        pipeline_EX_MEM[197:134] <= pipeline_ID_EX[210:147]; // read data 2
                        B = pipeline_MEM_WB[129:66]; // data from data memory
                    end
                end
           end
           else
           begin
                if (pipeline_ID_EX[11:5] == 7'b0110011) // opcode (R-type instruction)
                begin
                    B = pipeline_ID_EX[210:147]; // read_data 2
                    pipeline_EX_MEM[197:134] = pipeline_ID_EX[210:147]; // read data 2
                end
                else // (S-type, I -type)
                begin
                    B = pipeline_ID_EX[284:221];  // immediate
                    pipeline_EX_MEM[197:134] = pipeline_ID_EX[210:147]; // read data 2
                end
           end

           // Performing operation on A and B
           if(pipeline_ID_EX[11:5] == 7'b0110011) // opcode
           begin
                // R-format
                if (pipeline_ID_EX[18:12] == 7'b1000000) // funct 7 values
                begin
                    // addition
                    carry[0] = 0;
                    for(i = 0; i <= 63; i = i + 1)
                    begin
                        G[i] = A[i] & B[i];
                        P[i] = A[i] ^ B[i];
                        sum[i] = carry[i] ^ P[i];
                        carry[i + 1] = G[i] | (carry[i] & P[i]);
                    end
                    alu_result = sum;
                    if (A[63] == 0 && B[63] == 0 && sum[63] == 1) // adding two positive numbers giving a negative number is not possible
                    begin
                         overflow = 1'b1;
                    end
                    else if (A[63] == 1 && B[63] == 1 && sum[63] == 0) // adding two negative numbers giving a positive numbers is not possible
                    begin
                          overflow = 1'b1;
                    end
                    else
                    begin
                         overflow = 1'b0;
                    end
                end
                else if(pipeline_ID_EX[18:12] == 7'b0100000)
                begin
                     // subtraction
                    B1 = ~(B) + 1;
                    carry[0] = 0;
                    for(i = 0; i <= 63; i = i + 1)
                    begin
                        G[i] = A[i] & B1[i];
                        P[i] = A[i] ^ B1[i];
                        sum[i] = carry[i] ^ P[i];
                        carry[i + 1] = G[i] | (carry[i] & P[i]);
                    end
                    alu_result = sum; 
                    if (A[63] == 0 && B1[63] == 0 && sum[63] == 1) // adding two positive numbers giving a negative number is not possible
                    begin
                         overflow = 1'b1;
                    end
                    else if (A[63] == 1 && B1[63] == 1 && sum[63] == 0) // adding two negative numbers giving a postive numbers is not possible
                    begin
                          overflow = 1'b1;
                    end
                    else
                    begin
                         overflow = 1'b0;
                    end
                end
                else if(pipeline_ID_EX[18:12] == 7'b0000001)
                begin
                    // multiplication
                    B1 = ~(B) + 1;
                    mul = 0;
                    E1 = 0;
                    for (i = 0; i <= 63; i = i + 1)
                    begin
                        temp = {A[i], E1};
                        case (temp)
                            2'd2 : mul[127:64] = mul[127:64] + B1;
                            2'd1 : mul[127:64] = mul[127:64] + B;
                        endcase
                        mul = mul >> 1;
                        mul[127] = mul[126];
                        E1 = A[i];
                    end
                    if (B == 64'd9223372036854775808)
                    begin
                        mul = -mul;
                    end
                    overflow = 1'b0;
                    alu_result = mul[63:0];           
                end
           end
           else if(pipeline_ID_EX[11:5] == 7'b0010011 || pipeline_ID_EX[11:5] == 7'b0000011 || pipeline_ID_EX[11:5] == 7'b0100011)
           begin
               // I-format or S-format
               // addition
               carry[0] = 0;
               for(i = 0; i <= 63; i = i + 1)
               begin
                    G[i] = A[i] & B[i];
                    P[i] = A[i] ^ B[i];
                    sum[i] = carry[i] ^ P[i];
                    carry[i + 1] = G[i] | (carry[i] & P[i]);
               end
               alu_result = sum;
               if (A[63] == 0 && A[63] == 0 && sum[63] == 1) // adding two positive numbers giving a negative number is not possible
               begin
                    overflow = 1'b1;
               end
               else if (A[63] == 1 && B[63] == 1 && sum[63] == 0) // adding two negative numbers giving a postive numbers is not possible
               begin
                    overflow = 1'b1;
               end
               else
               begin
                    overflow = 1'b0;
               end
            end
            else
            begin
                alu_result = 0;
                overflow = 0;
            end

           // writing in the registers
           pipeline_EX_MEM[1:0] <= pipeline_ID_EX[1:0]; // write back signals
           pipeline_EX_MEM[4:2] <= pipeline_ID_EX[4:2]; // memory signals
           pipeline_EX_MEM[68:5] <= pipeline_ID_EX[82:19] + (pipeline_ID_EX[284:221] * 2); // branch calculation          
           pipeline_EX_MEM[69] <= 0; // branch signal
           pipeline_EX_MEM[133:70] <= alu_result; // alu result
           pipeline_EX_MEM[202:198] <= pipeline_ID_EX[289:285]; // destination register
// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
           // INSTRUCTION DECODE
            if( pipeline_IF_ID[70:64] == 7'b0110011)
            begin
                // R type instruction
                pipeline_ID_EX[1:0] <= 2'b01; // write back signals
                pipeline_ID_EX[4:2] <= 3'b000; // memory read, memory write, branch signal
                pipeline_ID_EX[11:5] <=  pipeline_IF_ID[70:64]; // opcode values
                pipeline_ID_EX[18:12] <= pipeline_IF_ID[95:89]; // funct 7 values
                pipeline_ID_EX[82:19] <= pipeline_IF_ID[63:0]; // PC value
                pipeline_ID_EX[146:83] <= register_file[pipeline_IF_ID[83:79]]; // read_data 1
                pipeline_ID_EX[210:147] <= register_file[pipeline_IF_ID[88:84]]; // read_data 2
                pipeline_ID_EX[215:211] <= pipeline_IF_ID[83:79]; // rs1
                pipeline_ID_EX[220:216] <= pipeline_IF_ID[88:84]; // rs2
                pipeline_ID_EX[284:221] <= 0; // immediate
                pipeline_ID_EX[289:285] <= pipeline_IF_ID[75:71]; // destination register
           end
           else if(pipeline_IF_ID[70:64] == 7'b0010011)
           begin
                // addi      
                pipeline_ID_EX[1:0] <= 2'b01; // write back signal
                pipeline_ID_EX[4:2] <= 3'b000; // memory read, memory write, branch signal
                pipeline_ID_EX[11:5] <=  pipeline_IF_ID[70:64]; // opcode values
                pipeline_ID_EX[18:12] <= 0; // funct 7 values
                pipeline_ID_EX[82:19] <= pipeline_IF_ID[63:0]; // PC value
                pipeline_ID_EX[146:83] <= register_file[pipeline_IF_ID[83:79]]; // read_data 1
                pipeline_ID_EX[210:147] <= 0; // read_data 2
                pipeline_ID_EX[215:211] <= pipeline_IF_ID[83:79]; // rs1
                pipeline_ID_EX[220:216] <= 0; // rs2
                // sign extending 12 bit immediate
                pipeline_ID_EX[232:221] <= pipeline_IF_ID[95:84];
                for(i = 233; i <= 284; i = i + 1)
                begin
                    pipeline_ID_EX[i] = pipeline_IF_ID[95];
                end
                pipeline_ID_EX[289:285] = pipeline_IF_ID[75:71]; // destination register
           end
           else if(pipeline_IF_ID[70:64] == 7'b0000011)
           begin
                // ld type instruction
                pipeline_ID_EX[1:0] <= 2'b11; // write back signal
                pipeline_ID_EX[4:2] <= 3'b100; // memory read, memory write, branch signal
                pipeline_ID_EX[11:5] <=  pipeline_IF_ID[70:64]; // opcode values
                pipeline_ID_EX[18:12] <= 0; // funct 7 values
                pipeline_ID_EX[82:19] <= pipeline_IF_ID[63:0]; // PC value
                pipeline_ID_EX[146:83] <= register_file[pipeline_IF_ID[83:79]]; // read_data 1
                pipeline_ID_EX[210:147] <= 0; // read_data 2
                pipeline_ID_EX[215:211] <= pipeline_IF_ID[83:79]; // rs1
                pipeline_ID_EX[220:216] <= 0; // rs2
                // immediate sign extension
                pipeline_ID_EX[232:221] <= pipeline_IF_ID[95:84];
                for(i = 233; i <= 284; i = i + 1)
                begin
                    pipeline_ID_EX[i] = pipeline_IF_ID[95];
                end
                pipeline_ID_EX[289:285] = pipeline_IF_ID[75:71]; // destination register
           end
           else if(pipeline_IF_ID[70:64] == 7'b0100011)
           begin
                // S type instruction
                pipeline_ID_EX[1:0] <= 2'b00; // write back signals
                pipeline_ID_EX[4:2] <= 3'b010; // memory read, memory write, branch signal
                pipeline_ID_EX[11:5] <=  pipeline_IF_ID[70:64]; // opcode values
                pipeline_ID_EX[18:12] <= 0; // funct 7 values
                pipeline_ID_EX[82:19] <= pipeline_IF_ID[63:0]; // PC value
                pipeline_ID_EX[146:83] <= register_file[pipeline_IF_ID[83:79]]; // read_data 1
                pipeline_ID_EX[210:147] <= register_file[pipeline_IF_ID[88:84]]; // read_data 2
                pipeline_ID_EX[215:211] <= pipeline_IF_ID[83:79]; // rs1
                pipeline_ID_EX[220:216] <= pipeline_IF_ID[88:84]; // rs2
                // sign extending imeediate
                pipeline_ID_EX[225:221] <= pipeline_IF_ID[75:71];
                pipeline_ID_EX[232:226] <= pipeline_IF_ID[95:89];
                for(i = 233; i <= 284; i = i + 1)
                begin
                    pipeline_ID_EX[i] = pipeline_IF_ID[95];
                end
                pipeline_ID_EX[289:285] = 0; // destination register
           end
           else
           begin
                pipeline_ID_EX = 0;
           end
        end
     end
endmodule
