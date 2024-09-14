/*
 * @Descripttion:MMU仿真
	连续存储，内存回收
 * @Author: Zhiyong Lin
 * @version: 
 * @Date: 2024-03-17 18:16:50
 * @LastEditors: Zhiyong Lin
 * @LastEditTime: 2024-05-04 20:22:16
 */

`timescale 1ns/1ps
module MMU_tb();

parameter DATA_BIT=8;		// 数据位宽
parameter ADDR_BIT=4;		// 地址位宽
parameter FRAME_BIT=2;
reg   					 	clk    ;
reg	  					 	rst_n  ;
reg						    start  ;	// 开始接收标志	
reg                         rw_ena ;    // 读写标志					
reg	  [ADDR_BIT-1:0]	 	addr   ;	// 地址
reg   [FRAME_BIT-1:0]       frame  ;    // 数据包帧数
reg   [DATA_BIT-1:0]    	wr_data;	// 数据输入端
wire                        ready  ;    // 准备接收FIFO数据信号
wire   [DATA_BIT-1:0]    	rd_data;	// 数据输出端
wire    [23:0]              data_table_out; // test

MMU MMU_dut(
	.clk    			(clk    	),
	.rst_n  			(rst_n  	),
	.start  			(start  	),
	.rw_ena 			(rw_ena 	),
	.addr   			(addr   	),
	.frame  			(frame  	),
	.wr_data			(wr_data	),
	.ready  			(ready  	),
	.data_table_out     (data_table_out), // test
	.rd_data	        (rd_data	)
);

initial begin
	clk = 0;
	forever begin
		#5 clk = ~clk;
	end
end

initial begin
	// 输入端口初始化
	rst_n = 1;
	start = 0;
	rw_ena = 0;
	addr = 0;
	frame = 0;
	wr_data = 0;
	#10;
	// 复位
	rst_n = 0;
	#5;
	rst_n = 1;
	#20;
	// 写操作
	start = 1;
	rw_ena = 0;
	addr = 3'b001;      // 地址3'b001;
	frame = 4'b0001;
	// 数据包
	wr_data = 8'h08;
	#10;
	wr_data = 8'h33;
	#10;
	wr_data = 8'hac;
	#10;
	wr_data = 8'h34;
	#10;
	wr_data = 8'h99;
	#10;
	wr_data = 8'h41;
	#10;
	wr_data = 8'h0c;
	#10;
	wr_data = 8'h14;
	#10;
	start = 0;
	#20;
	// 写操作
	start = 1;
	rw_ena = 0;
	addr = 3'b101;      // 地址3'b101
    wr_data = 8'h99;
	#10;
	wr_data = 8'h30;
	#10;
	wr_data = 8'h86;
	#10;
	wr_data = 8'h35;
	#10;
	wr_data = 8'h77;
	#10;
	wr_data = 8'hba;
	#10;
	wr_data = 8'h0a;
	#10;
	wr_data = 8'h41;
	#10;
	start = 0;
	#20;
	// 写操作
	start = 1;
	rw_ena = 0;
	addr = 3'b011;    // 地址3'b011
    wr_data = 8'h87;
	#10;
	wr_data = 8'h08;
	#10;
	wr_data = 8'h9b;
	#10;
	wr_data = 8'h75;
	#10;
	wr_data = 8'h56;
	#10;
	wr_data = 8'h2a;
	#10;
	wr_data = 8'h28;
	#10;
	wr_data = 8'ha9;
	#10;
	start = 0;
	#20;
		// 写操作
	start = 1;
	rw_ena = 0;
	addr = 3'b010;      // 地址010
    wr_data = 8'h98;
	#10;
	wr_data = 8'h32;
	#10;
	wr_data = 8'ha6;
	#10;
	wr_data = 8'h90;
	#10;
	wr_data = 8'h50;
	#10;
	wr_data = 8'h0a;
	#10;
	wr_data = 8'h00;
	#10;
	wr_data = 8'h69;
	#10;
	start = 0;
	#20;
	// 读操作
	start = 1;
	rw_ena = 1;
	addr = 4'b011;
	#100;
	start = 0;
	#20;
	/*
	start = 1;
	rw_ena = 1;
	addr = 4'b0101;
	#100;
	*/
	// 写操作
	start = 1;
	rw_ena = 0;
	addr = 3'b111;        // 地址3'b111
    wr_data = 8'h98;
	#10;
	wr_data = 8'h3a;
	#10;
	wr_data = 8'h06;
	#10;
	wr_data = 8'h95;
	#10;
	wr_data = 8'h99;
	#10;
	wr_data = 8'h2a;
	#10;
	wr_data = 8'h08;
	#10;
	wr_data = 8'h89;
	#10;
	start = 0;
	#20;
	// 写操作
	start = 1;
	rw_ena = 0;
	addr = 3'b011;       // 地址3'b011
    wr_data = 8'h90;
	#10;
	wr_data = 8'hd1;
	#10;
	wr_data = 8'h32;
	#10;
	wr_data = 8'h55;
	#10;
	wr_data = 8'ha7;
	#10;
	wr_data = 8'hb2;
	#10;
	wr_data = 8'h65;
	#10;
	wr_data = 8'h96;
	#10;
	start = 0;
	#20;
	// 读操作
	start = 1;
	rw_ena = 1;
	addr = 3'b001;
	#100;
	start = 0;
	#20;
	start = 1;
	rw_ena = 1;
	addr = 3'b011;
	#100;

	$finish;
end

// 监控输出
initial begin
    $monitor("At time %t, start = %h, rw_ena = %h, frame = %h,wr_data = %h,rd_dta = %h,data_table_out = %h",
             $time, start , rw_ena , frame , wr_data , rd_data , data_table_out);
end

endmodule 
