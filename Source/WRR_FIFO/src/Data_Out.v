/*
 * @Descripttion: 数据输出处理模块
 * @Author: Zhiyong Lin
 * @version: 
 * @Date: 2024-07-22 23:07:06
 * @LastEditors: Zhiyong Lin
 * @LastEditTime: 2024-07-23 11:40:08
 */

module Data_Out #(
	parameter DATA_WIDTH = 8,      // 数据位宽
	parameter DATAPACK_BIT = 1024, // 临时队列数据包位宽
	parameter PRIORITY_BIT = 3  ,  // 优先级
	parameter DATA_NUMBIT = 8  ,   // 数据包个数
	parameter ADDR_BIT = 14        // 地址位宽
)
(
	input  wire 							clk,
	input  wire 							rst_n,
	input  wire    							ready,
	input  wire 	[DATAPACK_BIT-1:0]   	Queue_out,
	output reg      [PRIORITY_BIT-1:0]		prior_o,
	output reg		[DATA_NUMBIT-1:0]		data_width,
	output reg     							wr_ena,
	output reg     							rd_ena,
	output reg      [ADDR_BIT-1:0]			addr,
	output reg								o_sop,
	output reg								o_eop,
	output reg 		[DATA_WIDTH-1:0]		o_data
);

reg flag;
reg  [DATAPACK_BIT-1:0] o_qeueu_e;

//将fifo读出数据保存在寄存器
always @(*)begin
	if(!flag)begin
		if( o_qeueu_e != Queue_out)begin
				o_qeueu_e = Queue_out; 
		end else begin
				o_qeueu_e = 0; 
		end
	end else begin
		o_qeueu_e = Queue_out; 
	end
end

//捕获优先级和地址
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin 
        prior_o <= 0;
		addr <= 0;
    end else begin
        if (data_width == 1) begin 
			prior_o <= Queue_out[1018:1016];
			addr <= {Queue_out[1014:1012],Queue_out[1004],Queue_out[1002:1000],Queue_out[998:992]};			
        end else begin            
			prior_o <= prior_o;
			addr <= addr;
        end
    end
end

//解析数据信息
always @(posedge clk or negedge rst_n ) begin
	if(!rst_n) begin
		data_width <= 0;
		o_eop <= 1;
		o_sop <= 0;
		wr_ena <= 0;
		rd_ena <= 0;
		o_data <= 0;
		flag <= 0;	
	end else begin 
		if(ready )begin	
			if( o_qeueu_e[((128-data_width)*8-1) -:8]  !=  8'b0000_0000)begin
				flag <= 1;
				o_data <= o_qeueu_e[((128-data_width)*8-1) -:8];
				data_width <= (data_width+4'b1);
				o_sop <= 1;
				o_eop <= 0; 
			end else begin
				flag <= 0;
				if(flag)begin
					data_width <= 0;
					o_eop <= 1; 
					o_sop <= 0;
					if(data_width <=4'b0100)begin	//数据帧个数=4
						wr_ena <= 0;
						rd_ena <= 1;
					end else begin
						wr_ena <= 1;
						rd_ena <= 0;
					end
				end else begin
					data_width <= 0;
					o_eop <= 1; 
					o_sop <= 0;				
					wr_ena <= 0;
					rd_ena <= 0;
				end
			end
		end else begin
			o_eop <= 1; 
			o_sop <= 0;	
		end
	end
	
end

endmodule