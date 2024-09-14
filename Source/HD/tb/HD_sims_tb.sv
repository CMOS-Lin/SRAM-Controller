`timescale 1ns/1ns
module HD_sims_tb();

// 参数定义
localparam DATA_WIDTH = 16;          // 数据位宽
localparam PRIORITY_BIT = 3;         // 优先级
localparam PORT_BIT = 4;             // 端口号
localparam DATAPACK_BIT = 1024;      // 临时队列数据包位宽

// 端口定义
reg                     clk;
reg                     rst_n;
reg                     wr_sop;
reg                     wr_eop;
reg                     wr_vld;
reg  [DATA_WIDTH-1:0]   wr_data;
wire [DATAPACK_BIT-1:0] Queue;       // 临时队列
wire [PRIORITY_BIT-1:0] prior;       // 优先级
wire                    data_vld;
wire                    error;

HD #(
    .DATA_WIDTH         (DATA_WIDTH  ),
    .PRIORITY_BIT       (PRIORITY_BIT),
    .DATAPACK_BIT       (DATAPACK_BIT)
) HD_dut (    
    .clk                (clk        ),
    .rst_n              (rst_n      ),
    .wr_sop             (wr_sop     ),
    .wr_eop             (wr_eop     ),
    .wr_vld             (wr_vld     ),
    .wr_data            (wr_data    ),
    .Queue              (Queue      ),
    .prior              (prior      ),
    .data_vld           (data_vld   ),
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
        num = {$random} % (1 << 3);  // 生成随机错误数据位
        code[num] = ~code[num];
        num = {$random} % (1 << 3) +7;  // 生成随机错误数据位
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
    #10;
    rst_n = 0;
    #20;
    rst_n = 1;
    #15;
    // 正确数据包
    repeat(2) begin  
        wr_vld = 1;
        wr_sop = 1;
        #10;
        wr_sop = 0;      
        wr_data = ctrl_data_HD(); #10;  // 控制数据帧
        repeat(5) begin
            wr_data = HD_R(); 
            wr_vld = {$random} % 2; 
            #10;
        end
        wr_eop = 1;
        #10;
        wr_eop = 0;
        #20;
    end

    // 存在1bit错误数据包
    repeat(1) begin
        wr_vld = 1;
        wr_sop = 1;
        #10;
        wr_sop = 0;      
        wr_data = ctrl_data_HD(); #10;  // 控制数据帧
        repeat(3) begin
            wr_data = HD_R(); 
            wr_vld = {$random} % 2; 
            #10;
        end

        repeat(2) begin
            wr_data = HD_E1(); 
            wr_vld = {$random} % 2; 
            #10;
        end
        wr_eop = 1;
        #10;
        wr_eop = 0;
        #20;
    end

    // 存在2bit错误数据包
    repeat(1) begin
        wr_vld = 1;
        wr_sop = 1;
        #10;
        wr_sop = 0;      
        wr_data = ctrl_data_HD(); #10;  // 控制数据帧
        repeat(3) begin
            wr_data = HD_R(); 
            wr_vld = {$random} % 2; 
            #10;
        end

        repeat(2) begin
            wr_data = HD_E1(); 
            wr_vld = {$random} % 2; 
            #10;
        end

        repeat(2) begin
            wr_data = HD_E2(); 
            wr_vld = {$random} % 2; 
            #10;
        end
        wr_eop = 1;
        #10;
        wr_eop = 0;
        #20;
    end
    
    $finish;
end

// 监控输出
initial begin
     $monitor("Time: %0d, wr_data: %b, Queue: %b, prior: %b,  error: %b , data_vld:%b", $time, wr_data, Queue, prior, error,data_vld);
end

endmodule


