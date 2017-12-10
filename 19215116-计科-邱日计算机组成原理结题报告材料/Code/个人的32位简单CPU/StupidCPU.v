`timescale  1ns/1ps
//MIPS经典五级流水
//Fetch,Decode,Execute，Memory ,Writeback
//取指instruction fetch ,译码 decode ,执行 execute 存储memory 写回writeback
//ifetch idecode EU
//Memory
module ifetch (
        input clk,
        input reset,
        output reg[31:0] PC,
        output reg[31:0] IR
        );
//设一个指存 PC指向从这里取指，指令与程序分开存，这决定了它是哈佛结构
reg [31:0] instructionMem[127:0];
always @ (posedge clk or posedge reset ) begin
        if(reset)
                PC<=32'h00000000;
        else
                PC<=PC+4;//1B=8b,8PC指针一次移动32b,即4B
end

always @ (posedge clk or posedge reset ) begin
        if(reset)
                IR<=32'h00000000;
        else
                IR<=instructionMem[PC[10:2]];
                //因为指令长度是32位，8b=1B,32位即4B，则PC一次是加4的，这也决定了PC的低两位是0
                //这决定了这部分PC[10:2]中的2。2
                //指存的大小是32*128b=2^5*2^7=2^12b=2^10B
                //指存的大小也决定了只需要PC的低几位就足够指令寻址了
end

endmodule //

//指令译码部件连同32个寄存器
//关于MIPS三种类型格式的介绍
//https://www.cnblogs.com/blacksunny/p/7192416.html
// 类型	格式
// R	Opcode(6)	Rs(5)	Rt(5)	Rd(5)	Shamt(5)	Funct(6)
// I	Opcode(6)	Rs(5)	Rt(5)	Immediate(16)
// J	Opcode(6)	Address(26)
module idecode (
        input clk,
        input reset,
        input [31:0]IR,
        input [31:0]PC,

        input [4:0]writeback_reg,
        input [31:0]writeback_result,

        output reg [31:0]data1,
        output reg [31:0]data2,
        output reg[4:0] reg_selected,
        output reg [2:0]ALUcontrol,
        output reg signal_memoryenable,
        output reg signal_write);
reg [31:0]Register[0:31];//寄存器们
//32个指令寄存器，每个寄存器长度是32位

//写回的相关处理
always @ ( posedge clk ) begin
        if(writeback_reg)begin
                Register[writeback_reg]<=writeback_result;
                $display("write data %d to register[%d]",writeback_result,writeback_reg);
                /*在写回到寄存器时给出提示信息*/
        end
        else
                Register[writeback_reg]<=Register[writeback_reg];
end
always @ ( posedge clk ) begin
        if(reset)
                signal_memoryenable<=0;
        else
                signal_memoryenable<=signal_memoryenable ;
end
always @ (posedge clk or posedge reset) begin
        if(reset)
                begin
                        data2<=32'h00000000;
                        ALUcontrol<=3'b0;
                        signal_memoryenable<=0;
                        signal_write<=0;
                end
        else    begin
//MIPS最后是6位的Function码（它与Opcode码共同决定R型指令的具体操作方式）。
// 类型	格式
// R	Opcode(6)	Rs(5)	Rt(5)	Rd(5)	Shamt(5)	Funct(6)
// I	Opcode(6)	Rs(5)	Rt(5)	Immediate(16)
// J	Opcode(6)	Address(26)
//按照MIPS，IR的高6位为Opcode
// R型指令用连续3个5位二进制码表示3个寄存器的地址，然后用1个5位二进制码表示移位的位数（如果未使用移位操作，则全为0），最后是6位的Function码（它与Opcode码共同决定R型指令的具体操作方式）。
// I型指令则用连续2个5位二进制码表示2个寄存器的地址，然后是由1个16位二进制码表示1个立即数二进制码。
// J型指令用26位二进制码表示跳转目标的指令地址（实际的指令地址应为32位，其中最低2位为“00”，最高4位由PC当前地址决定）。
                case(IR[31:26]) //6位的opcode，决定指令类型是R I  J其中三种中的那一种
                        6'b000000://R类型
                        begin
                        signal_memoryenable<=0;
                        case(IR[5:0])//Funct(6)

                                6'h20: //Addition with overflow:
                                      //add rd,rs,rt    0x20
                                      /*rs:IR[25:21]
                                       *rt:IR[20:16]
                                       *rd:IR[15:11]
                                       */
                                      begin
                                      data1<=Register[IR[25:21]];//rs
                                      data2<=Register[IR[20:16]];//rt
                                      reg_selected<=Register[IR[15:11]];//rd
                                     // ALUcontrol<=(3位，加号的ALU控制码)
                                      end
                                6'h22: //Substract with overflow:
                                       //sub rd,rs,rt   0x22
                                       begin
                                       data1<=Register[IR[25:21]];//rs
                                       data2<=Register[IR[20:16]];//rt
                                       reg_selected<=Register[IR[15:11]];//rd
                                      // ALUcontrol<=(3位，减号的ALU控制码)
                                       end
                                6'h2a: //Set less than
                                       //slt rd,rs,rt   0x2a
                                        begin
                                        end
                        endcase
                        end
                endcase
                end
end
endmodule //

module EU(
        input clk,
        input reset,
        input [31:0]data1,
        input [31:0]data2,
        input [2:0]ALUcontrol,
        output reg [31:0]ALUresult,
        input [4:0]signal_tmp_reg_select,
        output reg[4:0]tmp_reg_select, //要选择哪个32个寄存器中的哪个
        input signal_memoryenable,
        input signal_write,
        output reg memoryenable,
        output reg write);
//先处理一下写回信号和复位信号
//设置流水线的寄存器
always @ ( posedge clk or posedge reset ) begin
        if(reset)
                begin
                        tmp_reg_select<=5'b00000;
                        memoryenable<=signal_memoryenable;
                        write<=signal_write;
                end
        else
                begin
                        tmp_reg_select<=signal_tmp_reg_select;
                end
end

always @ ( posedge clk or posedge reset ) begin
        if(reset)
                begin
                ALUresult<=32'h00000000;
                end
        else begin
                case (ALUcontrol)
                        3'b000: //add,load,store
                                begin
                                        memoryenable<=0;
                                        if(signal_memoryenable)begin
                                                memoryenable<=1;
                                                if(signal_write==0)begin
                                                        tmp_reg_select<=data1;
                                                        ALUresult<=data2;
                                                        write<=0;
                                                end
                                                else begin //load
                                                        ALUresult=data1+data2;
                                                        write<=1;
                                                end
                                        end
                                        else begin
                                                ALUresult<=data1+data2;
                                        end
                                end
                        3'b001: //sub
                                begin
                                        ALUresult<=data1-data2;
                                        memoryenable<=0;
                                end
                        3'b010: //and
                                ;
                        3'b011: //or
                                ;
                        3'b100: //add
                                ;
                        3'b101:
                                ;
                        3'b110: //这些指令没有写完
                                ;
                        3'b111:
                                ;
                        default: ;
                endcase

        end
end
endmodule //

//数据存储器连同写回部件
module Memory(
        input clk,
        input reset,
        input [31:0]ALUresult,//来自执行部件EU的结果
        input [4:0]tmp_reg_select,//选择要处理的是哪个寄存器 32选1
        output reg[4:0]writeback_reg, //处理之后写回到哪个寄存器，一共32个寄存器，故要5位
        input tmpmemoryenable,
        input write,
        output reg[31:0]writeback_result //要写回到指令存储器的ALU运算结果
        );
reg [31:0]DataMemory [0:127];//数据存储器
reg memoryenable;
always @ ( posedge clk ) begin

        if(reset)
                begin
                        writeback_result<=32'h00000000;
                        writeback_reg<=5'b00000;
                        //要写回到哪个寄存器，一共32=2^5个寄存器，故要5位来指定是哪一个
                end
        else
                begin
                  memoryenable<=tmpmemoryenable;
                  if(tmpmemoryenable)begin
                                if(write)begin
                                        writeback_result<=DataMemory[ALUresult[31:0]];
                                        writeback_reg<=tmp_reg_select;
                                        //选择32个寄存器中哪个去写回
                                end
                                else begin
                                        DataMemory[tmp_reg_select]<=ALUresult[31:0];
                                        writeback_reg<=0;
                                end
                        end
                else begin //memoryunable
                        writeback_result<=ALUresult;
                        writeback_reg<=tmp_reg_select;
                end
    end
end
endmodule //~

module StupidCPU (
        input clk,
        input reset);
//ifetch wires
wire [31:0]PC;
wire [31:0]IR;
//idecode wires
wire [31:0]data1;
wire [31:0]data2;
wire [2:0]ALUcontrol;
wire signal_memoryenable;
wire signal_write;
//Memory wires (data memory)
wire [31:0] writeback_result;
wire [4:0] writeback_reg;
//5级流水 取指 译码 执行 内存读写 写回到寄存器
/*************************STAGE1:取指*******************************/
ifetch stupidifetch (
        .clk(clock),
        .reset(reset),
        .PC(PC),
        .IR(IR)
        );
/*************************STAGE2:译码*******************************/
idecode stupididecode(
                .clk(clock),
                .reset(reset),
                // input [31:0]IR,
                // input [31:0]PC,
                //
                // input [4:0]writeback_reg,
                // input [31:0]writeback_result,
                //
                .data1(data1),
                .data2(data2),
                // output reg[4:0] reg_selected,
                .ALUcontrol(ALUcontrol),
                .signal_memoryenable(signal_memoryenable),
                .signal_write(signal_write)
                );
/************************STAGE3:执行*******************************/
EU stupidExecuteUnit(
                .clk(clock),
                .reset(reset),
                .data1(data1),
                .data2(data2),
                .ALUcontrol(ALUcontrol)
                // output reg [31:0]ALUresult,
                // input [4:0]signal_tmp_reg_select,
                // output reg[4:0]tmp_reg_select, //要选择哪个32个寄存器中的哪个
                // input signal_memoryenable,
                // input signal_write,
                // output reg memoryenable,
                // output reg write
                        );
/*************************STAGE4:内存读写*******************************/
/*************************STAGE5:写回****(此模块同时包括写回)***************************/
        Memory stupidMemory(
                .clk(clock),
                .reset(reset),
                // input [31:0]ALUresult,//来自执行部件EU的结果
                // input [4:0]tmp_reg_select,//选择要处理的是哪个寄存器 32选1
                .writeback_reg(writeback_reg), //处理之后写回到哪个寄存器，一共32个寄存器，故要5位
                // // input tmpmemoryenable,
                // // input write,
                .writeback_result(writeback_result) //要写回到指令存储器的ALU运算结果
                );//~
endmodule //

`define CYCLE_TIME 200
module StupidCPU_testbench ;
reg clock;
initial begin
        clock =1'b1;
end
always #(`CYCLE_TIME/2) clock=~clock;
initial begin
        //向指令存储器填充二进制代码
end
initial begin
        //各项清零
end
initial begin
end
StupidCPU myCPU();
always @ ( posedge clock ) begin
$display("hello world");
end
initial begin
        $dumpfile("StupidCPU_testbench.vcd");
        $dumpvars(0,StupidCPU_testbench);
         // $dumpvar (0, top);     //指定层次数为0，则top模块及其下面各层次的所有信号将被记录
end
endmodule //

//MIPS处理器经典的五级流水
// IF
// Instruction Fetch，取指
// ID
// Instruction Decode，译码
// EX
// Execute，执行
// MEM
// Memory Access，内存数据读或者写
// WB
// Write Back，数据写回到通用寄存器中
//班级：计科151 学号：19215116 姓名：邱日
//系统简介：本系统利用硬件描述语言Verilog开发，采用哈佛结构，
//指令集MIPSR2000，尝试用最少的代码来实现一个非常简单，但
//“五脏俱全”的CPU。
//系统名称：StupidCPU
//已完成情况：基于Verilog的32位MIPS指令集CPU的实现
//      1.之前尝试一个八位的简单CPU,有很多缺陷，没完全做完，但跑通了时序，让我弄懂各部件如何在时序下配合工作，
//  我在此基础上修改得到目前的32位CPU代码，目前各模块部件大致代码基本完成。
//      2.取指模块ifetch，此部分也包括指令存储器instructionMem
//      3.译码模块idecode
//      4.执行模块EU
//      5.数据存储器模块Memory;此部分也包括写回
//未完成情况：
//      1.把系统时序调通，完善各部件细节
//      2.MIPS指令条数尚待继续添加
//      3.给汇编指令利用语法分析工具flex做一个非常简易的汇编器
//系统特色：
//1.按照MIPS R2000指令集开发，支持R I J三种类型代表性指令
//2.去除一切与CPU完整实现核心内容联系不紧密的部分，
//使本系统非常简单,但“麻雀虽小，五脏俱全”.
//3.支持MIPS经典五级流水即取指、译码、执行、内存读写、写回到寄存器
//(Fetch,Decode,Execute，Memory ,Writeback)
//4.采用哈佛结构，指令存储器和数据存储器分开
