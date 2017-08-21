// `define TESTMEMORY 0 //是否测试Memory的模块
`define SHOWHELLOWORLD 0//这是方便测试模块看效果的，如果运行此段且取指正确，将会得到helloworld的01字符画
`define TESTICACHE 0 //若不要测试ICACHE,就把本行注释掉
// `define TESTDCACHE 0
//这里默认只测试ICACHE,如果要测试Dcache 就把 `define TESTICACHE 0 注释掉，并且把// `define TESTDCACHE 0取消注释
module QMemory (address,clk,data,MemoryBlockWire);
//input rst;//reset
output [32*8-1:0]MemoryBlockWire;//用于和Cache之间块的替换
reg [32*8-1:0]MemoryBlockWire;
input clk;
input [31:0]address;
output [31:0]data;
reg [31:0]data;
parameter  tag_bits = 14; //tag: 14 bits
parameter  index_bits = 8; //line index： 8 bits
parameter  offset_bits = 5; //offset (in a block) : 5 bits
//showtemp0~showtemp7 :just for test
reg [31:0] showtemp0;
reg [31:0] showtemp1;
reg [31:0] showtemp2;
reg [31:0] showtemp3;
reg [31:0] showtemp4;
reg [31:0] showtemp5;
reg [31:0] showtemp6;
reg [31:0] showtemp7;
integer every8time;
reg [tag_bits-1:0]tag;
reg [index_bits-1:0]index;
reg [tag_bits+index_bits-1:0]blockNumber;
reg [offset_bits-1:0]offset;
reg [32*8-1:0] memory[0:4194304];//4194304=2^22
reg [32*8-1:0] MemoryBlock;
integer i;
initial begin
  $readmemb("debug.txt",memory);
  $display("\n start Memory \n");
  for(i=0;i<3000;i++)//最后要改过来!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  //actually it should be for(i=0;i<4194304;i++),but that will take too long
  memory[i]=memory[i%256];//initialize the memory
  every8time=0;
  /// test
  //  for(i=0;i<400;i++)
  //   begin
  //       $display("M[%d] = %h",i,memory[i]);
  //   end///~
end
  always @ ( posedge clk ) begin
    tag=address[tag_bits+index_bits+offset_bits-1:index_bits+offset_bits]; //14位tag
    index=address[index_bits+offset_bits-1:offset_bits]; //8位索引（行号）
    blockNumber=address[tag_bits+index_bits+offset_bits-1:offset_bits];
    MemoryBlock= memory[blockNumber];
    // MemoryBlockWire[32*8-1:0]=MemoryBlockWire[32*8-1:0];
    MemoryBlockWire[32*8-1:0]=MemoryBlock;
          case (address[5-1:0]) //4 3 2 1 0
                0: data[31:0]=MemoryBlock[32*1-1:0];
                1: data[31:0]=MemoryBlock[32*1+8-1:8];
                2: data[31:0]=MemoryBlock[32*1+16-1:16];
                3: data[31:0]=MemoryBlock[32*1+24-1:24];

                4: data[31:0]=MemoryBlock[32*2-1:0+32*1];
                5: data[31:0]=MemoryBlock[32*2+8-1:8+32*1];
                6: data[31:0]=MemoryBlock[32*2+16-1:16+32*1];
                7: data[31:0]=MemoryBlock[32*2+24-1:24+32*1];

                8: data[31:0]=MemoryBlock[32*3-1:0+32*2];
                9: data[31:0]=MemoryBlock[32*3+8-1:8+32*2];
                10: data[31:0]=MemoryBlock[32*3+16-1:16+32*2];
                11: data[31:0]=MemoryBlock[32*3+24-1:24+32*2];

                12: data[31:0]=MemoryBlock[32*4-1:0+32*3];
                13: data[31:0]=MemoryBlock[32*4+8-1:8+32*3];
                14: data[31:0]=MemoryBlock[32*4+16-1:16+32*3];
                15: data[31:0]=MemoryBlock[32*4+24-1:24+32*3];

                16: data[31:0]=MemoryBlock[32*5-1:0+32*4];
                17: data[31:0]=MemoryBlock[32*5+8-1:8+32*4];
                18: data[31:0]=MemoryBlock[32*5+16-1:16+32*4];
                19: data[31:0]=MemoryBlock[32*5+24-1:24+32*4];

                20: data[31:0]=MemoryBlock[32*6-1:0+32*5];
                21: data[31:0]=MemoryBlock[32*6+8-1:8+32*5];
                22: data[31:0]=MemoryBlock[32*6+16-1:16+32*5];
                23: data[31:0]=MemoryBlock[32*6+24-1:24+32*5];

                24: data[31:0]=MemoryBlock[32*7-1:0+32*6];
                25: data[31:0]=MemoryBlock[32*7+8-1:8+32*6];
                26: data[31:0]=MemoryBlock[32*7+16-1:16+32*6];
                27: data[31:0]=MemoryBlock[32*7+24-1:24+32*6];

                28: data[31:0]=MemoryBlock[32*8-1:0+32*7];
                29: data[31:0]=MemoryBlock[32*8+8-1:8+32*7];
                30: data[31:0]=MemoryBlock[32*8+16-1:16+32*7];
                31: data[31:0]=MemoryBlock[32*8+24-1:24+32*7];
                default: ;//已经穷举了所有情况
                endcase
          //    for test
          // $display("M:%h hello",data);
          // i = every8time%8;
          //       case(i)
          //       0: showtemp0=data;
          //       1: showtemp1=data;
          //       2: showtemp2=data;
          //       3: showtemp3=data;
          //       4: showtemp4=data;
          //       5: showtemp5=data;
          //       6: showtemp6=data;
          //       7: showtemp7=data;
          //       default: ;
          //     endcase
          // begin every8time+=1; end
          // if(every8time%8==0&&every8time!=0)
          // $write("%h%h%h%h%h%h%h%h\n",showtemp7,showtemp6,showtemp5,showtemp4,showtemp3,showtemp2,showtemp1,showtemp0);
          // ///~
          //$display("address:%h,data:%h",address,data);
    end
endmodule


`ifdef  TESTMEMORY
module QMemory_tb();
reg clk;
reg rst;//reset memory
reg [31:0]address;
wire [31:0]data;
reg [31:0]result;
wire [32*8-1:0]MemoryBlockWire;
integer i,j;
QMemory Mymemory(address,clk,data,MemoryBlockWire);
initial begin
// $display("--------------starting simulation------------");
// $display("testing Mymemory:\n\n");
// $display("\n\n--------------simulation ends----------------\n\n");
end
initial begin
address = 0;clk = 1;rst =1;
    for(i=0;i<600;i++)
                  begin clk =#10 !clk;
                  if(clk)address+=4; end
                  //ensure address :A1=0,A0=0;
                  // 0 00
                  // 1 00
   end
endmodule //
`endif


module ICache (clk,reset,PC,hit,ibus,MemoryBlockWire);
input reset;
input clk;
parameter  WORD_BITS = 32;
input [WORD_BITS-2-1:0]PC;
input [32*8-1:0]MemoryBlockWire;
//当Cache失效，通过此线从Memory调数据
//30 bits PC ,extend to 32 bits address,ensure A1=0 A2=0
reg [31:0]address;//32位地址,A1=0,A0=0
output  [WORD_BITS-1:0]ibus;
output hit;
parameter  BLOCK_SIZE = 32;
parameter  CACHE_BLOCK_NUM = 256;
parameter  MEMORY_BLOCK_NUM = 4194304;//2^22=4194304
parameter  tag_bits = 14;//tag
parameter  index_bits = 8;//line index
parameter  offset_bits = 5;//offset in a block
integer i,j;
reg [32*8-1:0]CacheData[256-1:0];//line index:8 bits 2^8=256
reg [32*8-1:0]CacheBuffer;
reg [14-1:0]blockTag[CACHE_BLOCK_NUM-1:0];//Tag (Cache)
reg hit;
reg [WORD_BITS-1:0]ibus;
reg [tag_bits-1:0]tag;
reg [index_bits-1:0]index;
reg [offset_bits-1:0]offset;
reg [tag_bits+index_bits-1:0]blocknum;
reg [tag_bits-1:0]memtag;//tag from memory
reg [WORD_BITS-5-1:0]blockNumber;//[26:0]blockNumber
reg control[CACHE_BLOCK_NUM-1:0]; //控制位，其中 第0位 为装入位，0未装入，1已装入，需要初始化
initial begin
  hit =0;
  for(i = 0;i < CACHE_BLOCK_NUM;i++)
      begin control[i] = 0;/*应该是0*/  blockTag[i] = 0;end
//initialization of load bit and Cache Tag
end
//要用好reset信号，不然第一条指令就不对
always @ ( posedge clk or reset) begin
  for(i = 0;i < 30; i++)
    begin  address[i+2] = PC[i]; address[1:0]=2'b00;end
    index=address[index_bits+offset_bits-1:offset_bits]; //8位索引（行号）
    offset=address[offset_bits-1:0];//5位块内偏移
    blockNumber=address[tag_bits+index_bits+offset_bits-1:offset_bits];//22位
    tag = address[tag_bits+offset_bits+index_bits:offset_bits+index_bits];
    hit =0;//本次有没有命中，先初始化，默认没有命中
    if(control[index])
            begin
                //如果已经装入并且命中
                //开始犯了CacheData没有初始化的错误
                CacheBuffer = CacheData[index];
                case (offset[5-1:2]) //4 3 2 //1 0
                  0: ibus[31:0]=CacheBuffer[32*1-1:0];
                  1: ibus[31:0]=CacheBuffer[32*2-1:32*1];
                  2: ibus[31:0]=CacheBuffer[32*3-1:32*2];
                  3: ibus[31:0]=CacheBuffer[32*4-1:32*3];
                  4: ibus[31:0]=CacheBuffer[32*5-1:32*4];
                  5: ibus[31:0]=CacheBuffer[32*6-1:32*5];
                  6: ibus[31:0]=CacheBuffer[32*7-1:32*6];
                  7: ibus[31:0]=CacheBuffer[32*8-1:32*7];
                  default: ;//已经穷举
                endcase
                hit =1;
            end

    else
            begin
            //从主存里的块来替换
            CacheData[index] [32*8-1:0]= MemoryBlockWire[32*8-1:0];
              CacheBuffer = CacheData[index][32*8-1:0];
              control[index]=1;
              hit =0;
            end
            // $display("取到");
  end
endmodule //



`ifdef TESTICACHE
module ICache_tb ();
reg clk;
reg [31:0]address;
wire [31:0]data;
reg [31:0]result;
integer i,j;
reg reset;
reg rst;
// reg [32-2-1:0]PC;
wire [31:0]ibus;
wire hit;
wire [32*8-1:0]MemoryBlockWire;
// QMemory Mymemory(address,clk,data);
// ICache MyCache(clk,reset,PC,hit,ibus,MemoryBlockWire);
ICache MyCache(clk,reset,address[31:2],hit,ibus,MemoryBlockWire);
// /address[31:2]->PC[29:0]
QMemory Mymemory(address,clk,data,MemoryBlockWire);
//showtemp0~showtemp7 :just for test
reg [31:0] showtemp0;
reg [31:0] showtemp1;
reg [31:0] showtemp2;
reg [31:0] showtemp3;
reg [31:0] showtemp4;
reg [31:0] showtemp5;
reg [31:0] showtemp6;
reg [31:0] showtemp7;
integer every8time;


initial begin

$display("--------------starting simulation------------");
reset=1;//reset Cache
rst=0;//reset Memory
address = 0;
clk=0;
every8time=0;
$display("testing ICache:\n\n");
for(i=0;i<200;i++)//200 cycles
begin
  if(reset)   begin reset=0;clk=#10!clk;clk=#10!clk;rst =1; end/*先走一个周期，把hit和ibus的内容更新*/ /*$display("init ibus:%h",ibus);*/
      //开始没有用好reset信号，第一条指令就不对
  if(hit)    begin  result[31:0] = ibus[31:0];$write("from Cache "); end//如果命中取Cache的值
  else        begin    result[31:0]=data[31:0];$write("from Memory ");end//如果没有命中。取主存的值
  address+=4;
  clk =#20 !clk;
/////////////////////////////////
//这里的clk延时20很重要，一开始我把CPU发出指令的周期定的太短，仿真错乱，
//这里还是clk长一点好
////////////////////////////////
  `ifdef SHOWHELLOWORLD
  $display("address:%h,result:%h",address,result);
 `endif
                `ifndef SHOWHELLOWORLD//实际上已完成取指，这一段是方便看效果的
                    //  for test    //如果运行此段且取指正确，将会得到helloworld的01字符画
                      j = every8time%8;
                            case(j)
                            0: showtemp0=result;
                            1: showtemp1=result;
                            2: showtemp2=result;
                            3: showtemp3=result;
                            4: showtemp4=result;
                            5: showtemp5=result;
                            6: showtemp6=result;
                            7: showtemp7=result;
                            default: ;
                          endcase
                      begin every8time+=1; end
                      if(every8time%8==0&&every8time!=0)
                      $write("%h%h%h%h%h%h%h%h\n",showtemp7,showtemp6,showtemp5,showtemp4,showtemp3,showtemp2,showtemp1,showtemp0);
                      ///~
                `endif
end
          $display("\n\n--------------simulation ends----------------\n\n");
end
initial forever clk=#10!clk;
endmodule //
`endif


`ifdef  TESTDCACHE
module DCache (RW,clk,reset,PC,hit,ibus,MemoryBlockWire,writeData);
input RW;
//RW为读写控制信号，RW=1时为读，RW为0时为写
input [31:0]writeData;
//当写操作时，writeData传入要写的数据
input reset;
input clk;
parameter  WORD_BITS = 32;
input [WORD_BITS-2-1:0]PC;
input [32*8-1:0]MemoryBlockWire;
//当Cache失效，通过此线从Memory调数据
//30 bits PC ,extend to 32 bits address,ensure A1=0 A2=0
reg [31:0]address;//32位地址,A1=0,A0=0
output  [WORD_BITS-1:0]ibus;
output hit;
parameter  BLOCK_SIZE = 32;
parameter  CACHE_BLOCK_NUM = 256;
parameter  MEMORY_BLOCK_NUM = 4194304;//2^22=4194304
parameter  tag_bits = 14;//tag
parameter  index_bits = 8;//line index
parameter  offset_bits = 5;//offset in a block
integer i,j;
reg [32*8-1:0]CacheData[256-1:0];//line index:8 bits 2^8=256
reg [32*8-1:0]CacheBuffer;
reg [14-1:0]blockTag[CACHE_BLOCK_NUM-1:0];//Tag (Cache)
reg hit;
reg [WORD_BITS-1:0]ibus;
reg [tag_bits-1:0]tag;
reg [index_bits-1:0]index;
reg [offset_bits-1:0]offset;
reg [tag_bits+index_bits-1:0]blocknum;
reg [tag_bits-1:0]memtag;//tag from memory
reg [WORD_BITS-5-1:0]blockNumber;//[26:0]blockNumber
reg control[CACHE_BLOCK_NUM-1:0]; //控制位，其中 第0位 为装入位，0未装入，1已装入，需要初始化
initial begin
  hit =0;
  for(i = 0;i < CACHE_BLOCK_NUM;i++)
      begin control[i] = 0;/*应该是0*/  blockTag[i] = 0;end
//initialization of load bit and Cache Tag
end
//要用好reset信号，不然第一条指令就不对
always @ ( posedge clk or reset) begin
if(RW)begin
              for(i = 0;i < 30; i++)
                begin  address[i+2] = PC[i]; address[1:0]=2'b00;end
                index=address[index_bits+offset_bits-1:offset_bits]; //8位索引（行号）
                offset=address[offset_bits-1:0];//5位块内偏移
                blockNumber=address[tag_bits+index_bits+offset_bits-1:offset_bits];//22位
                tag = address[tag_bits+offset_bits+index_bits:offset_bits+index_bits];
                hit =0;//本次有没有命中，先初始化，默认没有命中
                if(control[index])
                        begin
                            //如果已经装入并且命中
                            //开始犯了CacheData没有初始化的错误
                            CacheBuffer = CacheData[index];
                            case (offset[5-1:2]) //4 3 2 //1 0
                              0: ibus[31:0]=CacheBuffer[32*1-1:0];
                              1: ibus[31:0]=CacheBuffer[32*2-1:32*1];
                              2: ibus[31:0]=CacheBuffer[32*3-1:32*2];
                              3: ibus[31:0]=CacheBuffer[32*4-1:32*3];
                              4: ibus[31:0]=CacheBuffer[32*5-1:32*4];
                              5: ibus[31:0]=CacheBuffer[32*6-1:32*5];
                              6: ibus[31:0]=CacheBuffer[32*7-1:32*6];
                              7: ibus[31:0]=CacheBuffer[32*8-1:32*7];
                              default: ;//已经穷举
                            endcase
                            hit =1;
                        end

                else
                        begin
                        //从主存里的块来替换
                        CacheData[index] [32*8-1:0]= MemoryBlockWire[32*8-1:0];
                          CacheBuffer = CacheData[index][32*8-1:0];
                          control[index]=1;
                          hit =0;
                        end
                        // $display("取到");
              end

  else begin //如果不是读，那就进行写操作
                  for(i = 0;i < 30; i++)
                    begin  address[i+2] = PC[i]; address[1:0]=2'b00;end
                    index=address[index_bits+offset_bits-1:offset_bits]; //8位索引（行号）
                    offset=address[offset_bits-1:0];//5位块内偏移
                    blockNumber=address[tag_bits+index_bits+offset_bits-1:offset_bits];//22位
                    tag = address[tag_bits+offset_bits+index_bits:offset_bits+index_bits];
                    hit =0;//本次有没有命中，先初始化，默认没有命中
                    //  if(control[index])
                            begin
                                //如果已经装入并且命中
                                //开始犯了CacheData没有初始化的错误
                                CacheBuffer = CacheData[index];
                                case (offset[5-1:2]) //4 3 2 //1 0
                                  0: CacheBuffer[32*1-1:0]=writeData[31:0];
                                  1: CacheBuffer[32*2-1:32*1]=writeData[31:0];
                                  2: CacheBuffer[32*3-1:32*2]=writeData[31:0];
                                  3: CacheBuffer[32*4-1:32*3]=writeData[31:0];
                                  4: CacheBuffer[32*5-1:32*4]=writeData[31:0];
                                  5: CacheBuffer[32*6-1:32*5]=writeData[31:0];
                                  6: CacheBuffer[32*7-1:32*6]=writeData[31:0];
                                  7: CacheBuffer[32*8-1:32*7]=writeData[31:0];
                                  default: ;//已经穷举
                                endcase
                              CacheData[index] = CacheBuffer  ;
                            //  $display("\nCacheBuffer:%h",CacheBuffer);
                                //
                                // hit =1;
                    end
  end//写操作～
end
endmodule //
`endif

`ifdef TESTDCACHE
module DCache_tb ();
reg clk;
reg [31:0]address;
wire [31:0]data;
reg [31:0]result;
integer i,j,k;
integer temp;
reg reset;
reg rst;
// reg [32-2-1:0]PC;
wire [31:0]ibus;
wire hit;
wire [32*8-1:0]MemoryBlockWire;
reg [31:0]writeData;
reg RW;//RW为读写控制信号，RW=1时为读，RW为0时为写
wire write=!RW;//RW=0时写操作
// QMemory Mymemory(address,clk,data);
// ICache MyCache(clk,reset,PC,hit,ibus,MemoryBlockWire);
DCache MyCache(RW,clk,reset,address[31:2],hit,ibus,MemoryBlockWire,writeData);
// /address[31:2]->PC[29:0]
QMemory Mymemory(address,clk,data,MemoryBlockWire);
//showtemp0~showtemp7 :just for test
reg [31:0] showtemp0;
reg [31:0] showtemp1;
reg [31:0] showtemp2;
reg [31:0] showtemp3;
reg [31:0] showtemp4;
reg [31:0] showtemp5;
reg [31:0] showtemp6;
reg [31:0] showtemp7;
integer every8time;
parameter  tag_bits = 14; //tag: 14 bits
parameter  index_bits = 8; //line index： 8 bits
parameter  offset_bits = 5; //offset (in a block) : 5 bits
initial begin
$display("--------------starting simulation------------");
reset=1;//reset Cache
rst=0;//reset Memory
address = 0;
clk=0;
every8time=0;
RW =0;
//默认进行读操作
writeData[31:0]=32'h090a03b1;
$display("testing DCache:\n\n");
for(i=0;i<200;i++)//200 cycles
          begin
          if(RW) begin// if(!write) //非写即读，如果是读
                                            if(reset)   begin reset=0;clk=#10!clk;clk=#10!clk;rst =1; end/*先走一个周期，把hit和ibus的内容更新*/ /*$display("init ibus:%h",ibus);*/
                                                //开始没有用好reset信号，第一条指令就不对
                                            if(hit)    begin  result[31:0] = ibus[31:0];$write("from Cache"); end//如果命中取Cache的值
                                            else        begin    result[31:0]=data[31:0];$write("from Memory");end//如果没有命中。取主存的值
                                            address+=4;
                                            clk =#20 !clk;
                                          //通过模块实例名.内部元件名 可以改变内部的东西
                                          /////////////////////////////////
                                          //这里的clk延时20很重要，一开始我把CPU发出指令的周期定的太短，仿真错乱，
                                          //这里还是clk长一点好
                                          ////////////////////////////////
                                            `ifdef SHOWHELLOWORLD
                                            $display("address:%h,result:%h",address,result);
                                           `endif
                                                          `ifndef SHOWHELLOWORLD//实际上已完成取指，这一段是方便看效果的
                                                              //  for test    //如果运行此段且取指正确，将会得到helloworld的01字符画
                                                                j = every8time%8;
                                                                      case(j)
                                                                      0: showtemp0=result;
                                                                      1: showtemp1=result;
                                                                      2: showtemp2=result;
                                                                      3: showtemp3=result;
                                                                      4: showtemp4=result;
                                                                      5: showtemp5=result;
                                                                      6: showtemp6=result;
                                                                      7: showtemp7=result;
                                                                      default: ;
                                                                    endcase
                                                                begin every8time+=1; end
                                                                if(every8time%8==0&&every8time!=0)
                                                                $write("%h%h%h%h%h%h%h%h\n",showtemp7,showtemp6,showtemp5,showtemp4,showtemp3,showtemp2,showtemp1,showtemp0);
                                                                ///~
                                                          `endif
                       end
              else //非读即写，下面是写
                      begin
                      j=0;
                      temp = address[offset_bits-1:2]; //0,1,2...7(8*1-1)->0....32*8-1
                      temp*=32;
                      // $display("temp=%d",temp);
                        for(k=temp;k<temp+32;k++)
                        begin
                        Mymemory.memory[address[index_bits+offset_bits-1:offset_bits]][k] = writeData[j];
                        result[j]= Mymemory.memory[address[index_bits+offset_bits-1:offset_bits]][k];
                        j++;
                        end
                        $display("address:%h,result:%h",address,result);
                        address+=4;
                        clk =#20 !clk;
                        end
              end
           $display("\n\n--------------simulation ends----------------\n\n");
           for(k=0;k<200;k++)
           $display("Mymemory %h",Mymemory.memory[k]);

end
initial forever clk=#10!clk;
endmodule //
`endif//对应ifdef TESTDCACHE
