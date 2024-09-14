/*
 * @Descripttion: CRC_Check(对输入SRAMC的数据包进行循环冗余校验校验)
 CRC模型：CRC-8；宽度：8；多项式：1_0000_0111；初始值：00；结果异或值：00；输入反转：false；输出反转：false
 功能：计算数据包的CRC校验码
 * @Author: Zhiyong Lin
 * @version: 
 * @Date: 2024-04-22 21:23:35
 * @LastEditors: Zhiyong Lin
 * @LastEditTime: 2024-05-01 19:52:34
 */
`timescale 1ns/1ns
module CRC_Check_tb();

// 参数定义
localparam DATA_WIDTH = 8;
localparam CRC_WIDTH = 8;
localparam POLYNOMIAL = 8'h07;
localparam INIT_VALUE = 8'h00;
localparam TEST_NUM = 5; // 测试次数

// 端口定义
reg                     clk       ;
reg                     rst_n     ;
reg                     wr_sop    ;
reg                     wr_eop    ;
reg                     wr_valid  ;
reg   [DATA_WIDTH-1:0]  wr_data   ;
wire                    crc_valid ;

CRC_Check #(
    .DATA_WIDTH       (DATA_WIDTH),
    .CRC_WIDTH        (CRC_WIDTH ),
    .POLYNOMIAL       (POLYNOMIAL),
    .INIT_VALUE       (INIT_VALUE)
) CRC_Check_dut (
    .clk              (clk       ),
    .rst_n            (rst_n     ),
    .wr_sop           (wr_sop    ),
    .wr_eop           (wr_eop    ),
    .wr_valid         (wr_valid  ),
    .wr_data          (wr_data   ),
    .crc_valid        (crc_valid )
);

// 计算数据包CRC校验码函数
function [7:0] calculate_crc8(input [7:0] data[], input integer length);
    reg [7:0] crc;
    integer i, j;
    begin
        crc = 8'h00; // 初始化值
        for (i = 0; i < length; i++) begin
            crc = crc ^ data[i]; 
            for (j = 0; j < 8; j++) begin
                if (crc[7])
                    crc = (crc << 1) ^ 8'h07; 
                else
                    crc <<= 1;
            end
        end
        calculate_crc8 = crc; // 返回CRC结果
    end
endfunction

// 时钟生成
initial begin
     clk = 0;
    forever begin
        #5 clk = ~clk; // 产生一个周期为10ns的时钟信号
    end
end

reg [127:0] frame; // 数据包帧数
reg [127:0] error; // 错误帧数位置
reg [127:0] frame_valid; // 有效数据包帧数
reg [DATA_WIDTH-1:0] data_pack [0:7]; // 数据包
integer t,p;

// 变量初始化
initial begin
    frame_valid = 0;
end

// 测试激励
initial begin
    // 输入信号初始化
    rst_n = 1;
    wr_sop = 0;
    wr_eop = 0;
    wr_valid = 0;
    wr_data = 0;
    #10;
    // 复位
    rst_n = 0;
    #5;
    rst_n = 1;
    repeat(TEST_NUM) begin
        wr_valid = 1;
        wr_sop = 1;
        #10;
        wr_sop = 0;
        frame = {$random} % 5 +4; // 帧数范围8-4
        error = frame/2; // 设置错误帧数位置
        for(t=0; t<frame; t=t+1) begin
            if(t==error) begin
                wr_valid = 0;
                wr_data = {$random} % (1<<DATA_WIDTH);
            end else begin
                data_pack[frame_valid] = {$random} % (1<<DATA_WIDTH);
                wr_data = data_pack[frame_valid];
                frame_valid = frame_valid +1;
            end
            #10;
            wr_valid = 1;
        end
        wr_data = calculate_crc8(data_pack, frame_valid) + ({$random} % 2); // 数据包的CRC校验码
        #10;
        wr_eop = 1;
        #10;
        wr_eop = 0;
        frame_valid =0;
        #20;
    end
    $finish;
end

// 监控输出
initial begin
    $monitor("At time %t, wr_sop = %h, wr_eop = %h, wr_valid = %h,wr_data = %h,crc_valid = %b",
             $time, wr_sop , wr_eop , wr_valid , wr_data , crc_valid);
end

endmodule
