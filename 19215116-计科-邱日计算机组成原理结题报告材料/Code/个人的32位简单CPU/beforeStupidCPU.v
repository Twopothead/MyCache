`timescale 1ns / 10ps
module registers (
        input ld,
        input reg_enable,
        input [2:0]regaddr,//总共八个寄存器，3位寄存器地址
        input write,
        input [7:0]inData);
reg [7:0] registers[0:7];
reg [7:0]valueBuffer;//一个buffer,暂存
wire [7:0]DBus;
assign  DBus= (ld) ? inData : valueBuffer;
//ld = 1时，把inData赋给DBus
//ld = 0时,DBus得到的是缓冲valueBuffer
initial begin
        registers[0]=8'd0;registers[1]=8'd0;registers[2]=8'd0;registers[3]=8'd0;
        registers[4]=8'd0;registers[5]=8'd0;registers[6]=8'd0;registers[7]=8'd0;
end
always @ ( * ) begin
        if(reg_enable)
                begin
                        if(write)
                        registers[regaddr]<=DBus;
                        else
                        valueBuffer<=registers[regaddr];
                end
end
endmodule //~

module registers_testbench ();
reg clock;
parameter reg_load = 1'b0,
          reg_towrite= 1'b1;
reg reg_state=reg_load;
reg ld,reg_enable,write;reg [2:0]regaddr;reg [7:0]inData;
registers Registers(ld,reg_enable,regaddr,write,inData);
task show_reg_info;begin
        $display($time," inData :%h  , valueBuffer:%h , Dbus:%h , registers[0]:%h ",
                Registers.inData,Registers.valueBuffer,Registers.DBus,Registers.registers[0]);
        end
endtask
task show_registers;begin
$display("                      R[0]:%h, R[1]:%h, R[2]:%h, R[3]:%h",
        Registers.registers[0],Registers.registers[1],Registers.registers[2],Registers.registers[3]);
        end
endtask
initial begin
        $dumpfile("registers_testbench.vcd");
        $dumpvars(0,registers_testbench);
        $display("\n-----test registers--------");
        #10000 //这里测试前1000时间
        $finish;
        end
initial begin
#10
show_reg_info;show_registers;
if(reg_state==reg_load)begin
        regaddr<=0;
        inData<=8'b00110001;
        reg_enable<=1;
        reg_state<=reg_load;
        ld=1;/*ld=1时，DBus得到inData的值*/
        write=1;/*若写，DBus的值赋给相应寄存器*/
        reg_state<=reg_towrite;
        end
#10
show_reg_info;show_registers;
if(reg_state==reg_towrite)begin
        regaddr<=0;
        ld=0;/*ld=0时，DBus得到valueBuffer的值*/
        reg_enable<=1;
        write=0;/*若不写，相应寄存器的值赋给DBus*/
        end
#10
show_reg_info;show_registers;
end
initial begin
        clock=0;
        #100;
end
always
#100 begin clock = !clock;end
endmodule //
//
//
// //0001(4bits) DR(3bits) SR1(3bits) 000(3bits) SR2(3bits)
// //total :16bits ISA
module Ri_ALU(
        input wire [3:0]opcode,
	input wire[7:0]data1,
	input wire[7:0]data2,
	output reg[7:0]result);
        reg [8:0]tmp9bit;
        integer i;
        always @ ( * ) begin
        	case(opcode)
        	4'b0000 ://add
        		begin
        			tmp9bit<=data1+data2;
        			result<=tmp9bit[7:0];
        		end
        	4'b0001 ://sub
        		begin
        			tmp9bit<=data1-data2;
        			result<=tmp9bit[7:0];
        		end
        	4'b0010://and
        		begin
        			result<=data1&data2;
        		end
        	4'b0011://or
        		begin
        			result<=data1|data2;
        		end
        	4'b0100://xor
        		begin
        			result<=data1^data2;
        		end
        	4'b0101://not
        		begin
        			result<=!data1;
        		end
        	4'b0110://shift left
        		begin
        			result<=data1<<1;
        		end
        	4'b0111://shift right
        		begin
        			result<=data1>>1;
        		end
        	endcase
        end
endmodule //

//一个output 一个input 就可以用wire连起来
module EU_Control ( );
// Ri_ALU(
//         input wire [3:0]opcode,
// 	input wire[7:0]data1,
// 	input wire[7:0]data2,
// 	output reg[7:0]result);
//         module registers (
//                 input ld,
//                 input reg_enable,
//                 input [2:0]regaddr,//总共八个寄存器，3位寄存器地址
//                 input write,
//                 input [7:0]inData);
endmodule //
//执行部件EU不需要时序 ALU也可以不要时序
//执行部件的控制逻辑需要时序 ，它要和状态机打交道
//reset fetch decode excute
module Program_Mem (
        input [7:0]PC,
        output [31:0]instr);
reg  [31:0]program_RAM[0:255];
initial begin
  program_RAM[0]=32'b0000_0001_0010_00000000_00000000_0000;
  //program_RAM[0]=32'b00000001000000100000000000000;
end
endmodule //
module Instr_decoder (
input [31:0]instruction,
output [3:0]opcode,
output [2:0]op1,op2,op3);
endmodule //
module ControlUnit(
        input clock,
        output [7:0]DataOut);
reg [7:0]PC=0;
wire [7:0]pcwire;
//这个PC初始定为1 ，pcwire 由其他部件修改
wire [31:0]instr;
//Pmem和Instr_decoder共用同一个wire instr
wire [2:0]op1,op2,op3;
wire [3:0]opcode;
reg [4:0]state;//状态机
//
Program_Mem PMemory(.PC(PC),
        .instr(instr));
Instr_decoder Instruction_Decoder(.instruction(instr),
        .opcode(opcode),
        .op1(op1),.op2(op2),.op3(op3));
//再包括执行部件逻辑 （执行部件逻辑包括执行部件）
always @ ( posedge clock ) begin
PC<=pcwire;
end
endmodule //
//哈佛结构
//系统测试里面有程序存储器 数据存储器 指令decoder ,EU


module System_test ();
reg clock;
wire [7:0]DataOut;
ControlUnit CU(.clock(clock),
        .DataOut(DataOut));
//Program_Mem;
//instr_decoder;
//EU;
//mem;
reg ld,reg_enable,write;reg [2:0]regaddr;reg [7:0]inData;
registers Registers(ld,reg_enable,regaddr,write,inData);
initial begin
        $dumpfile("System_test.vcd");
        $dumpvars(0,System_test);
        $display("\n-----test Ri_CPU--------");
        #10000 //这里测试前1000时间
        $finish;
        end
initial begin
        $display($time,"ok");
        #10
        $display($time,"%h",Registers.registers[0]);
        regaddr<=0;
        inData='b00100011;
        ld=1;
        #1
        $display($time," inData :%h ",Registers.inData);
        $display($time," valueBuffer :%h ",Registers.valueBuffer);
        $display($time," Dbus:%h ",Registers.DBus);
// $display($time,"%h ",Registers.valueBuffer);
         reg_enable<=1;
         write<=0;
         ld=1;
         $display($time,"%h ",Registers.DBus);
        // $display($time,"%h ",Registers.valueBuffer);
         regaddr<=0;
         inData='b00100011;
         reg_enable<=1;
         write<=1;
         ld=0;
         $display($time,"%h ",Registers.DBus);
        // regaddr=0;
        // inData='b0011;
        // write=1;
        // regaddr=0;
        // inData='b0011;
        #10
        $display($time,"%h",Registers.registers[0]);
        //$monitor("%h ",CU.PMemory.program_RAM[0]);
        end
initial begin
        clock=0;
        #100;
end
always
#100 begin clock = !clock;  /*$display($time,"%h",);*/end
endmodule //
