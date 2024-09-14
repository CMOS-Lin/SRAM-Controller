/*
 * @Descripttion:单端口SRAM
	功能:设计一片单端口SRAM，存储容量为:256bKit，数据位宽64，地址深度2^8
 * @Author: Zhiyong Lin
 * @version: 
 * @Date: 2024-03-17 18:16:50
 * @LastEditors: Zhiyong Lin
 * @LastEditTime: 2024-06-04 16:11:55
 */

module SRAM #(
	parameter DATA_BIT=8,		// 数据位宽
	parameter ADDR_BIT=8 		// 地址位宽	
)(	input  wire   					 				clk    ,
	input  wire                                     rst_n  ,
	input  wire                                     ena    ,    // 工作使能信号
	input  wire                                     rw_ena ,    // 读写使能（1：读操作，0：写操作）
	input  wire	   [ADDR_BIT-1:0]	 				addr   ,	// 地址      
	input  wire    [DATA_BIT-1:0]    				wr_data,	// 数据输入端
	output reg     [DATA_BIT-1:0]    				rd_data 	// 数据输出端
);

// SRAM地址深度
localparam ADDR_DEPTH = 1 << ADDR_BIT;   // 地址深度

// SRAM逻辑单元
reg [DATA_BIT-1:0] SRAM[ADDR_DEPTH-1:0]; 

integer i;
initial begin
	for(i=0; i<ADDR_DEPTH ; i=i+1) begin
			SRAM[i] = 0;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		rd_data <= 0;
	end else begin
		if(ena) begin // SRAM工作使能
			if(rw_ena) begin
				rd_data <= SRAM[addr]; // 读操作
			end else begin
				SRAM[addr] <= wr_data; // 写操作
			end
		end else begin
			rd_data <= 0 ;
		end
	end
end
endmodule