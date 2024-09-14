/*
 * @Descripttion: 汉明纠错模块
 功能：校验位�?1�?2�?4�?8；多比特错误察觉位：0�?
 * @Author: Zhiyong Lin
 * @version: 
 * @Date: 2024-07-17 20:42:03
 * @LastEditors: Zhiyong Lin
 * @LastEditTime: 2024-07-22 22:40:35
 */
module HD #(
    parameter DATA_WIDTH = 16,         // 数据位宽
	parameter PRIORITY_BIT = 3  ,      // 优先�?
	parameter DATAPACK_BIT = 1024      // 临时队列数据包位�?
)(
    input wire                  	clk      ,    // 时钟信号
    input wire                  	rst_n    ,    // 复位信号
    input wire                  	wr_sop   ,    // 数据包开始标�?
    input wire                  	wr_eop   ,    // 数据包结束标�?
    input wire                  	wr_vld   ,    // 数据包写入有�?
    input wire [DATA_WIDTH-1:0] 	wr_data  ,    // 数据包写入端�?
	output reg [DATAPACK_BIT-1:0]   Queue    ,    // 临时队列
	output reg [PRIORITY_BIT-1:0]   prior    ,    // 优先�?
    output reg                      data_vld ,    // 临时队列数据有效标志
    output reg                      error         // 出现两位错误时拉�?,请求重新发�?�数据包
);

reg [6:0] frame;  // 计数数据包帧�?
reg  last_wr_sop; // 保存wr_sop信号
wire enable;      // �?始接收数据包标志
assign enable =rst_n && ((last_wr_sop && !wr_sop) || (enable && !wr_eop));

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
  		last_wr_sop <= 0;
	end else begin
        last_wr_sop <= wr_sop;
	end
end

reg [15:0] in_code;  // 暂存输入�?16位汉明码编码数据
reg [4:0] h_code;    // 依次记录0�?1�?2�?4�?8的校验位
reg [3:0] syndrome;  // 记录错误位置
reg flag;            // 单比特标志位 
reg error_flag;      // 临时队列数据无效标志

always @(*) begin
    if(!rst_n) begin
        error_flag = 0; 	  
    end else begin
        if(enable && wr_vld) begin
            in_code =  wr_data;
            h_code[0] = wr_data[1]^wr_data[2]^wr_data[3]^wr_data[4]^wr_data[5]^wr_data[6]^wr_data[7]^wr_data[8]^wr_data[9]^wr_data[10]^wr_data[11]^wr_data[12]^wr_data[13]^wr_data[14]^wr_data[15];
            h_code[1] = wr_data[3]^wr_data[5]^wr_data[7]^wr_data[9]^wr_data[11]^wr_data[13]^wr_data[15]; 
            h_code[2] = wr_data[3]^wr_data[6]^wr_data[7]^wr_data[10]^wr_data[11]^wr_data[14]^wr_data[15];  
            h_code[3] = wr_data[5]^wr_data[6]^wr_data[7]^wr_data[12]^wr_data[13]^wr_data[14]^wr_data[15];
            h_code[4] = wr_data[9]^wr_data[10]^wr_data[11]^wr_data[12]^wr_data[13]^wr_data[14]^wr_data[15]; 
            // 计算 syndrome
            flag = h_code[0] ^ wr_data[0];
            syndrome = {h_code[4], h_code[3], h_code[2], h_code[1]} ^ {wr_data[8], wr_data[4], wr_data[2], wr_data[1]};

            // �?测并纠错
            if (syndrome == 5'd0) begin
                // 没有错误
                error = 1'b0;           
            end else begin
                if (flag) begin       
                    // 纠正单比特错�?
                    error = 1'b0;
                    in_code[syndrome] = ~in_code[syndrome];                  
                end else begin
                    // 多比特错�?
                    error = 1'b1;
                    error_flag = 1'b1;
                    in_code = 16'b0; // 输出无效数据，请求重�?
                end  
            end            
            Queue[1023-frame*16-:16] = in_code;
            frame = frame + 1;
        end else begin
            if(wr_sop) begin               
                frame = 0;
                Queue = 0;
                error_flag = 1'b0;
            end else begin
                error_flag = error_flag;
            end
        end
    end
end

// �?测数据包
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        data_vld <= 0;
    end else begin
        if(wr_eop) begin // �?始检�?
            if(!error_flag) begin
                data_vld <= 1;
            end else begin
                data_vld <= data_vld;
            end
        end else begin
            data_vld <= 0;
        end
    end
end

// 解析ctrl_data
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin 
        prior <= 0;
    end else begin
        if (frame == 1) begin                  
			prior <= Queue[1018:1016];
        end else begin            
			prior <= prior;
        end
    end
end

endmodule