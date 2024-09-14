module WRR(
	input wire 			sys_clk,
	input wire 			sys_rst_n,
	output wire 	[15:0]   outdata
);

reg	wr_sop; 
reg wr_eop; 
reg wr_vld;
reg [15:0] wr_data;
reg ready;
wire wr_ena;
wire rd_ena;
wire o_sop; 
wire o_eop;
wire [15:0] addr;
wire [6:0] data_width;
wire [2:0] prior_o;
wire error;

reg [7:0] cnt;

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n) begin
		wr_sop <= 1'b0;
		wr_eop <= 1'b0;
		ready <= 1'b0;
		wr_vld <= 1'b0;
		cnt <= 1'b0;
		wr_data <= 16'b0;
	end else begin
		ready <= 1'b1;
		wr_vld <= 1'b1;
		cnt <= cnt + 1'b1;
		
		case(cnt)
			2: begin
				wr_sop <= 1'b1;
				wr_data <= 16'b1010_0101_0000_0000;
			end
			3: wr_sop <= 1'b0;
			8: wr_eop <= 1'b1;
			9: wr_eop <= 1'b0;
			default: begin
				wr_sop <= wr_sop;
				wr_eop <= wr_eop;
			end
		endcase
	end
end


FIFO_top FIFO_top_dut(
	.clk	          (sys_clk	 ),			
	.rst_n            (sys_rst_n ),
	.wr_sop           (wr_sop	 ),
	.wr_eop           (wr_eop	 ),
	.wr_vld           (wr_vld	 ),
	.wr_data          (wr_data	 ),
	.ready            (ready	 ),
	.wr_ena           (wr_ena	 ),
	.rd_ena           (rd_ena	 ),
	.o_sop            (o_sop 	 ),
	.o_eop            (o_eop 	 ),
	.addr             (addr  	 ),
	.data_width       (data_width),
	.o_data           (outdata	 ),
	.prior_o          (prior_o   ),
    .error            (error     )
);

ila_0 your_instance_name (
	.clk(sys_clk), // input wire clk
	.probe0(sys_clk), // input wire [0:0]  probe0  
	.probe1(sys_rst_n), // input wire [0:0]  probe1 
	.probe2(wr_sop), // input wire [0:0]  probe2 
	.probe3(wr_eop), // input wire [0:0]  probe3 
	.probe4(wr_vld), // input wire [0:0]  probe4 
	.probe5(wr_data), // input wire [15:0]  probe5 
	.probe6(ready), // input wire [0:0]  probe6 
	.probe7(wr_ena), // input wire [0:0]  probe7 
	.probe8(rd_ena), // input wire [0:0]  probe8 
	.probe9(o_sop ), // input wire [0:0]  probe9 
	.probe10(o_eop 	 ), // input wire [0:0]  probe10 
	.probe11(addr  	 ), // input wire [15:0]  probe11 
	.probe12(data_width), // input wire [6:0]  probe12 
	.probe13(outdata	 ), // input wire [7:0]  probe13 
	.probe14(prior_o   ), // input wire [2:0]  probe14 
	.probe15(error     ) // input wire [0:0]  probe15
);


endmodule