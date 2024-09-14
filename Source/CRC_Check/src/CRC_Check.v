/*
 * @Descripttion: CRC_Check(对输入SRAMC的数据包进行循环冗余校验校验)
 CRC模型：CRC-8；宽度：8；多项式：1_0000_0111；初始值：00；结果异或值：00；输入反转：false；输出反转：false
 功能：计算数据包的CRC校验码
 * @Author: Zhiyong Lin
 * @version: 
 * @Date: 2024-04-22 21:23:35
 * @LastEditors: Zhiyong Lin
 * @LastEditTime: 2024-05-01 18:43:42
 */
 
module CRC_Check #(
    parameter DATA_WIDTH = 8,     // 数据位宽
    parameter CRC_WIDTH = 8,      // CRC宽度
    parameter POLYNOMIAL = 8'h07, // CRC-8多项式
    parameter INIT_VALUE = 8'h00  // CRC初始值
)(
    input wire                  clk,
    input wire                  rst_n,
    input wire                  wr_sop,
    input wire                  wr_eop,
    input wire                  wr_valid,
    input wire [DATA_WIDTH-1:0] wr_data,
    output reg                  crc_valid
);

reg [7:0] frame; //计数数据包帧数
reg [1023:0] Queue; // 临时队列

// 保存wr_sop信号、wr_data信号
reg last_wr_sop;
reg [DATA_WIDTH-1:0] last_wr_data; 
wire enable; // 开始接收数据包标志
assign enable =rst_n && ((last_wr_sop && !wr_sop) || (enable && !wr_eop));

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
  		last_wr_sop <= 0;
        last_wr_data <= 0;
        frame <= 0;
        Queue <= 0;
	end else begin
        last_wr_sop <= wr_sop;
        if(enable && wr_valid) begin 
            last_wr_data <= wr_data;
            frame <= frame +1;
            Queue[1023-frame*8-:8] <= wr_data;
        end else begin
            if(wr_eop) begin
                last_wr_data <= 0;
                frame <= 0;
                Queue <= 0;
            end else begin
                last_wr_data <= last_wr_data;
            end
        end
	end
end

// 计算每一帧8bit数据的CRC校验码
reg [CRC_WIDTH-1:0] crc_next,crc_out;

integer i;
always @(*) begin
    crc_next = crc_out; // 上一个8bit数据的CRC校验码作为初始值
    if (enable) begin                  
        for (i = DATA_WIDTH-1; i >= 0; i = i - 1) begin
            if (crc_next[CRC_WIDTH-1] ^ last_wr_data[i]) begin
                crc_next = (crc_next << 1) ^ POLYNOMIAL; // 条件异或多项式
            end else begin
                crc_next = crc_next << 1;
            end
        end
        crc_next = crc_next & ((1 << CRC_WIDTH) - 1); // 确保CRC宽度 
    end else begin
        crc_next = INIT_VALUE; // enable为低，准备接收下一个数据包，则复位crc_next
    end
end

// 更新输出CRC值
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin 
        crc_out <= INIT_VALUE;
    end else begin
        if (enable) begin 
            if(wr_valid) begin      
                crc_out <= crc_next;
            end else begin
                crc_out <= crc_out;
            end
        end else begin            
            crc_out <= 0;
        end
    end
end

// 检测数据包CRC校验码（最后8bit数据）与计算出来的CRC校验
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        crc_valid <= 0;
    end else begin
        if(wr_eop) begin // 开始检测
            if(last_wr_data == crc_out) begin
                crc_valid <= 1;
                // 将临时队列数据包送进特定FIFO
                
            end else begin
                crc_valid <= crc_valid;
            end
        end else begin
            crc_valid <= 0;
        end
    end
end

endmodule
