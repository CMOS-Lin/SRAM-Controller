`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/25 17:14:36
// Design Name: 
// Module Name: trigger_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module trigger_top (
    input wire                  	clk      ,    // 鏃堕挓淇″彿
    input wire                  	rst_n    ,    // 澶嶄綅淇″彿
    //input wire                  	in   ,    // 鏁版嵁鍖呭紑濮嬫爣蹇?
	//output wire                  	wr_sop 
	//output wire                  	wr_eop   ,    // 鏁版嵁鍖呯粨鏉熸爣蹇?
    //output wire                  	wr_vld   ,    // 鏁版嵁鍖呭啓鍏ユ湁鏁?
    output wire [8-1:0] 			o_data,
	output wire 					error 	// 鏁版嵁鍖呭啓鍏ョ鍙?
	//output wire                  	ready   
	
	
	
);
// 参数定义
localparam WDATA_WIDTH = 16; 
localparam DATA_WIDTH = 8;          // 数据位宽
localparam PRIORITY_BIT = 3;         // 优先级
localparam PORT_BIT = 4;             // 端口号
localparam DATA_NUMBIT = 7  ; //数据包个数
localparam DATAPACK_BIT = 1024;      // 临时队列数据包位宽
localparam ADDR_BIT=16;//地址位宽



// 端口定义

reg                     wr_sop;
reg                     wr_eop;
reg                     wr_vld;
reg  [WDATA_WIDTH-1:0]   wr_data;
reg  					ready;

wire wr_ena, rd_ena, o_sop, o_eop;
wire [ADDR_BIT-1:0] addr;
wire [DATA_NUMBIT-1:0]data_width;

wire [PRIORITY_BIT-1:0]  prior_o;
FIFO_top #(
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
	.ready				(ready),
	.wr_ena				(wr_ena),
    .rd_ena				(rd_ena),
	.o_sop				(o_sop),
    .o_eop				(o_eop),
    .addr				(addr),
    .data_width			(data_width),
    .o_data				(o_data),
	.prior_o			(prior_o),
    .error              (error     )
	
);
reg [4:0]flag_s;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
       // data_vld <= 0;
		wr_sop <=0;
		wr_eop <=0;
		wr_vld <=1;
		wr_data<=0;
		ready<=1;
		flag_s<=0;
    end else begin
		if(!flag_s== 8'b00000000)begin
			wr_sop<=1;
			//wr_eop<=0;
		end else if(flag_s== 8'b00000001)begin
			wr_sop <=0;

		end else if(flag_s== 8'b00001111)begin
			wr_eop <=1;
			
		end else if(flag_s== 8'b00010000)begin
			wr_eop <=0;
			
		end else begin
			wr_sop<=0;
			
		end
		flag_s<=flag_s+1;
		wr_data <= wr_data + 16'b00000000_00000010;
		end
		
end


endmodule