module priority_num 
(
    input  wire  	   rst,          	// 复位信号
	input  wire  [3:0] data_weight_1, 	// 权重
	input  wire  [3:0] data_weight_2,
	input  wire  [3:0] data_weight_3,
	input  wire  [3:0] data_weight_4,
	input  wire  [3:0] data_weight_5,
	input  wire  [3:0] data_weight_6,
	input  wire  [3:0] data_weight_7,
	input  wire  [3:0] data_weight_8,
	input  wire  [7:0] empty,
    output reg   [2:0] max      		// 最大权重队列号
);
    
    
    reg [3:0] max_value;// 中间寄存器用于存储当前最大值和对应的序号
    integer i;
    reg [3:0] values [7:0]; // 数组用于存储8个输入值
	wire [7:0]empty_grant;
	reg [3:0]decimal_output;
    always @(*) begin
            values[0] = data_weight_1;
            values[1] = data_weight_2;
            values[2] = data_weight_3;
            values[3] = data_weight_4;
            values[4] = data_weight_5;
            values[5] = data_weight_6;
            values[6] = data_weight_7;
            values[7] = data_weight_8;
			for (i = 8; i >= 0; i = i - 1) begin // 遍历所有输入值，找到最大值及其序号
				if(i==8)begin
				 max_value = values[7];
				 max = (i-1);
				end else begin
					if( (empty[i] != 1) && (values[i] > max_value)) begin//同时判断0队列权重最大但已经为满会卡住
						max_value = values[i];
						max = i[2:0]; // 更新最大值及其序号
					end 
                end
				
            end
        
    end
endmodule
