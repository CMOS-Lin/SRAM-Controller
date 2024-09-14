/*
 * @Descripttion: FIFO顶层模块
 * @Author: Zhiyong Lin
 * @version: 
 * @Date: 2024-07-22 23:07:06
 * @LastEditors: Zhiyong Lin
 * @LastEditTime: 2024-07-23 11:41:56
 */

module FIFO_top #(
	parameter WDATA_WIDTH = 16,     // 写入数据位宽
	parameter DATA_WIDTH = 8, 		// 读出数据位宽
	parameter PRIORITY_BIT = 3  , 	// 优先级
	parameter DATA_NUMBIT = 8  , 	// 数据包个数
	parameter DATAPACK_BIT= 1024,	// 数据包位宽
	parameter ADDR_BIT=14			// 地址位宽
)(
	input wire						clk,
	input wire						rst_n,
	input wire						wr_sop,
	input wire						wr_eop,
	input wire						wr_vld,
	input wire	[WDATA_WIDTH-1:0] 	wr_data,
	input wire 						ready,
	output wire						wr_ena,
	output wire						rd_ena,
	output wire						o_sop,
	output wire						o_eop,
	output wire	[ADDR_BIT-1:0] 		addr,
	output wire	[DATA_NUMBIT-1:0] 	data_width,
	output wire	[DATA_WIDTH-1:0] 	o_data,
	output wire	[PRIORITY_BIT-1:0] 	prior_o,
	output wire  					error
);

wire	SYNTHESIZED_WIRE_0;                     // data_vld
wire	[PRIORITY_BIT-1:0] SYNTHESIZED_WIRE_1;  // prior
wire	[DATAPACK_BIT-1:0] SYNTHESIZED_WIRE_2;  // Queue	
wire	[DATAPACK_BIT-1:0] SYNTHESIZED_WIRE_3;  // Queue_out
		
defparam	b2v_inst0. DATA_WIDTH = 16;        // 数据位宽
defparam	b2v_inst0. PRIORITY_BIT = 3  ;     // 优先级
defparam	b2v_inst0. DATAPACK_BIT = 1024 ;   // 临时队列数据包位宽    

HD	b2v_inst0( 
	.clk				(clk				),
	.rst_n				(rst_n				),
	.wr_sop				(wr_sop				),
	.wr_eop				(wr_eop				),
	.wr_vld				(wr_vld				),
	.wr_data			(wr_data			),
	.Queue				(SYNTHESIZED_WIRE_2	),
	.prior				(SYNTHESIZED_WIRE_1	),
	.data_vld			(SYNTHESIZED_WIRE_0	),
	.error 				(error              )
	);
	
defparam	b2v_inst1.DATAPACK_BIT = 1024;
defparam	b2v_inst1.PRIORITY_BIT = 3;
defparam	b2v_inst1.ADDRSIZE = 3;

WRR_FIFO	b2v_inst1(
	.clk				(clk				),
	.rst_n				(rst_n				),
	.data_vld			(SYNTHESIZED_WIRE_0	),
	.ready				(ready				),
	.prior				(SYNTHESIZED_WIRE_1	),
	.Queue				(SYNTHESIZED_WIRE_2	),
	.Queue_out			(SYNTHESIZED_WIRE_3	)
	);

	
defparam	b2v_inst2.DATA_WIDTH = 8;
defparam	b2v_inst2.DATAPACK_BIT = 1024;
defparam	b2v_inst2.PRIORITY_BIT = 3;
defparam	b2v_inst2.DATA_NUMBIT = 8;
defparam	b2v_inst2.ADDR_BIT = 14;

Data_Out	b2v_inst2(
	.clk				(clk				),
	.rst_n				(rst_n				),
	.ready				(ready				),
	.Queue_out			(SYNTHESIZED_WIRE_3	),
	.prior_o			(prior_o			),
	.data_width			(data_width			),
	.wr_ena				(wr_ena				),
	.rd_ena				(rd_ena				),
	.addr				(addr				),
	.o_sop				(o_sop				),
	.o_eop				(o_eop				),
	.o_data				(o_data				)
	);

endmodule
