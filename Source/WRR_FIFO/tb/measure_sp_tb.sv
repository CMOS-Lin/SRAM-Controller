`timescale 1ns/1ns
module measure_sp_tb;
    // Parameters
    localparam DATAPACK_BIT = 16; // 数据位宽
    localparam PRIORITY_BIT = 3;    // 优先级
    localparam ADDRSIZE = 3;        // fifo深度位宽
	parameter TEXT_NUM = 40;
    // Inputs
    reg clk;
    reg rst_n;
    reg crc_valid;
    reg ready;
    reg [PRIORITY_BIT-1:0] prior;
    reg [DATAPACK_BIT-1:0] Queue;
    // Outputs
    wire [DATAPACK_BIT-1:0] Queue_out;
	wire[7:0]view;
	reg [DATAPACK_BIT-1:0] Queue_out_prev;
	//
	int i;
	int NUM;
	int prior_e;
	reg [8:0]result=0;
	//指标
	
	reg [7:0] L_num;
	integer total_waiting_time = 0;
    integer packet_count = 0;
    real average_waiting_time;
	reg [7:0]r_num;//随机产生8bit数据 
	//
	typedef struct {
	logic   [15:0]   data_in ;//输入的当前时间
	logic   [15:0]   time_in ;//输入的当前时间
	logic   [15:0]   data_out ;
	logic   [9:0]    time_out ;//输出的当前时间
	logic   [9:0]    time_diff ;//上述量时间之差
	}data;
	
	data  ttime[TEXT_NUM];
	
    // Instantiate the WRR_0706 module
    FIFO#(
        .DATAPACK_BIT(DATAPACK_BIT),
        .PRIORITY_BIT(PRIORITY_BIT),
        .ADDRSIZE(ADDRSIZE)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .crc_valid(crc_valid),
        .ready(ready),
        .prior(prior),
        .Queue(Queue),
        .Queue_out(Queue_out),
		.view(view)
    );
	
    // Clock generation
    always begin
        #5 clk = ~clk; // Simple 10ns clock period
    end
	
    // Reset generation
    initial begin
        rst_n = 0;
        #20 rst_n = 1;
    end

    // Test stimulus

    initial begin
        clk=1;
		rst_n=0;
		crc_valid=0;
		ready = 0;
		#20
		crc_valid=1;
		rst_n=1;
		//写入
		
		for(i=0;i<TEXT_NUM;i++)begin
			prior = $urandom_range(0, 7);
			r_num = {$random};
			Queue[15:8] = r_num ;
			Queue[7:0] = i;
			ttime[i].data_in = Queue;
			#10;
			//获取当前时间
			$display("time_in = %d, data_in = %d, queue_num = %d , num = %d", $time, Queue, prior, i);
		end
		
		crc_valid=0;
		#20
		//
        ready = 1;
		#10
		for(int j=0;j<TEXT_NUM;j++)begin
			L_num = Queue_out[7:0];
			ttime[L_num].data_out = Queue_out;
			$display("time_out = %d, data_out = %d, queue_num = %d, num = %d", $time, Queue_out, view, L_num);
			if(view==0)begin
			#10;
			end else if(view==8'b0001)begin
			#20;
			end else if(view==8'b0010)begin
			#30;
			end else if(view==8'b0011)begin
			#40;
			end else if(view==8'b0100)begin
			#50;
			end else if(view==8'b0101)begin
			#60; 
			end else if(view==8'b0110)begin
			#70;
			end else if(view==8'b0111)begin
			#80;
			end
		end
        #200;
		$display("END");
        $finish;
    end
	
endmodule