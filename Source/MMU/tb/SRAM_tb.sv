/*
 * @Descripttion:单端口SRAM
	功能:设计一片单端口SRAM，存储容量为:256bKit，数据位宽64，地址深度2^8 
 * @Author: Zhiyong Lin
 * @version: 
 * @Date: 2024-03-17 18:16:50
 * @LastEditors: Zhiyong Lin
 * @LastEditTime: 2024-05-03 17:24:05
 */
`timescale 1ns/1ps

module SRAM_tb();
localparam DATA_BIT=8;		// 数据位宽
localparam ADDR_BIT=6; 		// 地址位宽	
localparam TEXT_NUM=20;		// 测试次数

reg     					 	clk;
reg                             rst_n;
reg                             ena;
reg                             rw_ena;
reg  [ADDR_BIT-1:0]	 			addr   ;	// 地址      
reg  [DATA_BIT-1:0]    			wr_data;	// 数据输入端
wire [DATA_BIT-1:0]    			rd_data;	// 数据输出端

SRAM SRAM_dut(
	.clk			(clk    ),
	.rst_n          (rst_n  ),		
	.ena 		    (ena    ),
	.rw_ena 		(rw_ena ),
	.addr   		(addr   ),
	.wr_data		(wr_data),
	.rd_data		(rd_data)
);

// 记录读写操作测试数据结构体
typedef struct packed{
    bit  				ena;
    bit [ADDR_BIT-1:0] 	addr;
	bit [DATA_BIT-1:0]  wr_data;
	bit [DATA_BIT-1:0]  rd_data;
} message;

message [TEXT_NUM-1:0]m;

integer i,j;

initial begin
	clk = 1'b0;
	forever #5 clk = ~clk;
end

initial begin
	// 端口初始化
	rst_n = 1;
	ena = 1'b0;
	rw_ena = 1'b0;
	#10;
	rst_n = 0;
	#5;
	rst_n = 1;
	ena = 1'b1;
	// 读写操作
	for (i=0 ; i < TEXT_NUM ; i=i+1) begin
		// 写操作
		//wr_ena = {$random} % 2;
		rw_ena = 1'b0;
		addr = {$random} % (1 << ADDR_BIT);
		//wr_data = {2{{$random} % 32}};
		wr_data = {$random} % (1<<DATA_BIT);
		//m[i].ena = ena;
		m[i].addr = addr;
		m[i].wr_data = wr_data;
		#10;
		ena = 1'b0;
		#10;
		ena = 1'b1;
		// 读操作
		
		rw_ena = 1'b1;
		addr =  m[i].addr;		
		#8;
		m[i].rd_data = rd_data;
		#2;
		ena = 1'b0;
		#10;
		ena = 1'b1;
	end

	// 检验读写数据
	for (j=0 ; j < TEXT_NUM ; j=j+1) begin	
		$display("NUM:%d,wr_ena:%d,addr:%d",j,m[j].wr_ena,m[j].addr);
		$display("wr_data:%d,rd_data:%d",m[j].wr_data,m[j].rd_data);
		if(m[j].wr_ena) begin
			if(m[j].wr_data == m[j].rd_data) begin
				$display("success!");
			end else begin
				$display("fail!");
			end
		end else begin
			if(m[j].rd_data == 0) begin
				$display("success!");
			end else begin
				$display("fail!");
			end
		end
	end
	
end
endmodule