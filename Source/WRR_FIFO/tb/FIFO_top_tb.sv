/*
 * @Descripttion: 顶层FIFO验证代码
 * @Author: Zhiyong Lin
 * @version: 
 * @Date: 2024-07-22 23:07:06
 * @LastEditors: Zhiyong Lin
 * @LastEditTime: 2024-07-25 10:39:26
 */

`timescale 1ns/1ns
module FIFO_top_tb();

// 参数定义
localparam WDATA_WIDTH = 16; 
localparam DATA_WIDTH = 8;         // 数据位宽
localparam PRIORITY_BIT = 3;       // 优先级
localparam PORT_BIT = 4;           // 端口号
localparam DATA_NUMBIT = 8  ;      // 数据包个数
localparam DATAPACK_BIT = 1024;    // 临时队列数据包位宽
localparam ADDR_BIT=14;            // 地址位宽
 
// 端口定义
reg                       clk;
reg                       rst_n;
reg                       wr_sop;
reg                       wr_eop;
reg                       wr_vld;
reg  [WDATA_WIDTH-1:0]    wr_data;
reg                       ready;
wire                      error;
wire wr_ena, rd_ena, o_sop, o_eop;
wire [ADDR_BIT-1:0]       addr;
wire [DATA_NUMBIT-1:0]    data_width;
wire [DATA_WIDTH-1:0]     o_data;
wire [PRIORITY_BIT-1:0]   prior_o;

FIFO_top #(
    .DATA_WIDTH         (DATA_WIDTH  ),
    .PRIORITY_BIT       (PRIORITY_BIT),
    .DATAPACK_BIT       (DATAPACK_BIT)
) FIFO_top_dut (    
    .clk                (clk        ),
    .rst_n              (rst_n      ),
    .wr_sop             (wr_sop     ),
    .wr_eop             (wr_eop     ),
    .wr_vld             (wr_vld     ),
    .wr_data            (wr_data    ),
	.ready				(ready      ),
	.wr_ena				(wr_ena     ),
    .rd_ena				(rd_ena     ),
	.o_sop				(o_sop      ),
    .o_eop				(o_eop      ),
    .addr				(addr       ),
    .data_width			(data_width ),
    .o_data				(o_data     ),
	.prior_o			(prior_o    ),
    .error              (error      )
);

// 时钟生成
initial begin
    clk = 0;
    forever #5 clk = ~clk; // 产生一个周期为10ns的时钟信号
end

// 控制数据的汉明编码函数
function [15:0] ctrl_data_HD();
    reg [2:0] prior;
    reg [3:0] port;
    reg [15:0] code;
    begin
        prior = {$random} % (1 << 3);    // 生成随机优先级
        port = {$random} % (1 << 4);     // 生成随机端口号
        code = {5'b0, prior, 4'b0, port};
        code[1] = code[3] ^ code[5] ^ code[7] ^ code[9] ^ code[11] ^ code[13] ^ code[15]; 
        code[2] = code[3] ^ code[6] ^ code[7] ^ code[10] ^ code[11] ^ code[14] ^ code[15];  
        code[4] = code[5] ^ code[6] ^ code[7] ^ code[12] ^ code[13] ^ code[14] ^ code[15];
        code[8] = code[9] ^ code[10] ^ code[11] ^ code[12] ^ code[13] ^ code[14] ^ code[15]; 
        code[0] = code[1] ^ code[2] ^ code[3] ^ code[4] ^ code[5] ^ code[6] ^ code[7] ^ code[8] ^ code[9] ^ code[10] ^ code[11] ^ code[12] ^ code[13] ^ code[14] ^ code[15];
        ctrl_data_HD = code;
    end
endfunction

// 输出正确汉明编码数据包函数
function [15:0] HD_R();
    reg [15:0] code;
    begin
        code = {$random} % (1 << 16);    // 生成随机数据
        code[1] = code[3] ^ code[5] ^ code[7] ^ code[9] ^ code[11] ^ code[13] ^ code[15]; 
        code[2] = code[3] ^ code[6] ^ code[7] ^ code[10] ^ code[11] ^ code[14] ^ code[15];  
        code[4] = code[5] ^ code[6] ^ code[7] ^ code[12] ^ code[13] ^ code[14] ^ code[15];
        code[8] = code[9] ^ code[10] ^ code[11] ^ code[12] ^ code[13] ^ code[14] ^ code[15]; 
        code[0] = code[1] ^ code[2] ^ code[3] ^ code[4] ^ code[5] ^ code[6] ^ code[7] ^ code[8] ^ code[9] ^ code[10] ^ code[11] ^ code[12] ^ code[13] ^ code[14] ^ code[15];
        HD_R = code;
    end
endfunction

// 输出1bit错误汉明编码数据包函数
function [15:0] HD_E1();
    reg [15:0] code;
    reg [3:0] num; // 错误数据位置
    begin
        code = HD_R();               // 生成正确随机数据
        num = {$random} % (1 << 4);  // 生成随机错误数据位
        code[num] = ~code[num];
        HD_E1 = code;
    end
endfunction

// 输出2bit错误汉明编码数据包函数
function [15:0] HD_E2();
    reg [15:0] code;
    reg [3:0] num; // 错误数据位置
    begin
        code = HD_R();               // 生成正确随机数据
        num = {$random} % (1 << 4);  // 生成随机错误数据位
        code[num] = ~code[num];
        num = {$random} % (1 << 4);  // 生成随机错误数据位
        code[num] = ~code[num];
        HD_E2 = code;
    end
endfunction

// 测试激励
initial begin
    // 初始化
    rst_n = 1;
    wr_sop = 0;
    wr_eop = 0;
    wr_vld = 0;
    wr_data = 0;
	ready =  0;
    #10;
    rst_n = 0;
    #20;
    rst_n = 1;
	ready =  1;
    #10;
	
    // 正确数据包
    repeat(2000) begin
        wr_vld = 1;
        wr_sop = 1;
        #10;
        wr_sop = 0;      
        wr_data = ctrl_data_HD(); #10;  // 控制数据帧
        repeat(20) begin
            wr_data = HD_R(); 
            wr_vld = {$random} % 2; 
            #10;
        end
        wr_eop = 1;
        #10;
        wr_eop = 0;
        #20;
    end
    ready =0 ;

    // 读数据包帧格式
      repeat(1000) begin
    wr_vld = 1;
    wr_sop = 1;
    #10;
    wr_sop = 0;      
    wr_data = ctrl_data_HD(); #10;  // 控制数据帧
    repeat(1) begin
        wr_data = HD_R(); 
        wr_vld = 1; 
        #10;
    end
    wr_eop = 1;
    #10;
    wr_eop = 0;
    #20;
    end

    // 存在1bit错误数据包
    repeat(3000) begin
        wr_vld = 1;
        wr_sop = 1;
        #10;
        wr_sop = 0;      
        wr_data = ctrl_data_HD(); #10;  // 控制数据帧
        repeat(15) begin
            wr_data = HD_R(); 
            wr_vld = {$random} % 2; 
            #10;
        end

        repeat(15) begin
            wr_data = HD_E1(); 
            wr_vld = {$random} % 2; 
            #10;
        end
        wr_eop = 1;
        #10;
        wr_eop = 0;
        #20;
    end
    ready = 0;

    // 存在2bit错误数据包
    repeat(20) begin
        wr_vld = 1;
        wr_sop = 1;
        #10;
        wr_sop = 0;      
        wr_data = ctrl_data_HD(); #10;  // 控制数据帧
        repeat(20) begin
            wr_data = HD_R(); 
            wr_vld = {$random} % 2; 
            #10;
        end

        repeat(20) begin
            wr_data = HD_E1(); 
            wr_vld = {$random} % 2; 
            #10;
        end

        repeat(20) begin
            wr_data = HD_E2(); 
            wr_vld = {$random} % 2; 
            #10;
        end
        wr_eop = 1;
        #10;
        wr_eop = 0;
        #20;
    end
    
    // 读数据包帧格式
       repeat(1000) begin
    wr_vld = 1;
    wr_sop = 1;
    #10;
    wr_sop = 0;      
    wr_data = ctrl_data_HD(); #10;  // 控制数据帧
    repeat(1) begin
        wr_data = HD_R(); 
        wr_vld = 1; 
        #10;
    end
    wr_eop = 1;
    #10;
    wr_eop = 0;
    #20;
    end

    // 测试极限数据包大小
    repeat(9000) begin
        wr_sop = 1;
        wr_vld = 1;
        #10;
        wr_sop = 0;
        for (int i = 0; i < 1024/16; i = i + 1) begin
            wr_data = HD_R(); 
            #10;
        end
        wr_eop = 1;
        #10;
        wr_eop = 0;
        #20;
    end

    ready = 0;
    #10;
    rst_n = 0;
    #20;
    rst_n = 1;
	ready =  0;

    // 读数据包帧格式
       repeat(1000) begin
    wr_vld = 1;
    wr_sop = 1;
    #10;
    wr_sop = 0;      
    wr_data = ctrl_data_HD(); #10;  // 控制数据帧
    repeat(1) begin
        wr_data = HD_R(); 
        wr_vld = 1; 
        #10;
    end
    wr_eop = 1;
    #10;
    wr_eop = 0;
    #20;
    end

    ready = 1;
   // 测试多次数据包输入
    repeat(2000) begin
    wr_vld = 1;
    wr_sop = 1;
    #10;
    wr_sop = 0;      
    wr_data = ctrl_data_HD(); #10;  // 控制数据帧
    repeat(30) begin
        wr_data = HD_R(); 
        wr_vld = {$random} % 2; 
        #10;
    end
    wr_eop = 1;
    #10;
    wr_eop = 0;
    #20;
    end

    ready = 0;
    // 测试极限数据包大小
    repeat(10000) begin
        wr_sop = 1;
        wr_vld = 1;
        #10;
        wr_sop = 0;
        for (int i = 0; i < 1024/16; i = i + 1) begin
            wr_data = HD_R(); 
            #10;
        end
        wr_eop = 1;
        #10;
        wr_eop = 0;
        #20;
    end
    #80000;
    #80000;
    #80000;
    #80000;
    #80000;
    #80000;
    #80000;
    #80000;
    #80000;
    #80000;
    ready =1;
    #500000;
    #500000;
    #500000;
    #500000;
    #500000;
    #500000;
    #500000;
    #500000;
    #500000;
    #500000;
    // 测试极限数据包大小
    repeat(10000) begin
        wr_sop = 1;
        wr_vld = 1;
        #10;
        wr_sop = 0;
        for (int i = 0; i < 1024/16; i = i + 1) begin
            ready = {$random} %2;
            wr_data = HD_R(); 
            #10;
        end
        wr_eop = 1;
        #10;
        wr_eop = 0;
        #20;
    end

        // 测试极限数据包大小
    repeat(20000) begin
        ready ={$random} %2;
        wr_sop = 1;
        wr_vld = 1;
        #10;
        wr_sop = 0;
        for (int i = 0; i < 1024/16; i = i + 1) begin
            
            wr_data = HD_R(); 
            #10;
        end
        wr_eop = 1;
        #10;
        wr_eop = 0;
        #20;
    end
    ready =1;
    #1000000;
    #1000000;
    #1000000;
    #1000000;
    #1000000;
    #1000000;
    #1000000;
    #1000000;
    #1000000;
    #1000000;
    ready = 0;
    #1000000;
    rst_n = 0;
    ready = 1;
    #200000;
    $finish;
end

// 监控输出
initial begin
     $monitor("Time: %0d, wr_data: %b, error: %b ", $time, wr_data, error);
end

endmodule


