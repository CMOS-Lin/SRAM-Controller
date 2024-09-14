`define NUM_DATA 8   // 数据个数(权重排序用到的)
module wrr_fifo#(
    parameter DATAPACK_BIT = 1024 ,//数据位宽
	parameter QUEUE_BIT = 8    ,//队列个数
	parameter PRIORITY_BIT = 3 ,// 队列个数位宽
    parameter ADDRSIZE = 3      //表示fifo深度位宽
)(
    input  wire							clk,
    input  wire 						rst_n,
    input  wire							data_vld,
    input  wire 						ready,
    input  wire  [PRIORITY_BIT-1:0]		prior,
    input  wire  [DATAPACK_BIT-1:0] 	Queue,
	output reg   [DATAPACK_BIT-1:0]		Queue_out,
	output reg   [7:0]view   
 
);
	
	reg [DATAPACK_BIT-1:0] Rout_PQ[QUEUE_BIT-1:0][8-1:0]; //fifo存储

	reg [ADDRSIZE:0] w_ptr[QUEUE_BIT-1:0]; // 每个优先级的写指针
	reg [ADDRSIZE:0] r_ptr[QUEUE_BIT-1:0]; // 每个优先级的读指针

	wire [ADDRSIZE:0] w_ptr_o[QUEUE_BIT-1:0]; // 每个优先级的写指针的格雷码
	wire [ADDRSIZE:0] r_ptr_o[QUEUE_BIT-1:0]; // 每个优先级的读指针的格雷码

	reg [ADDRSIZE:0] rd_p; // 读取指针选择器

	wire [QUEUE_BIT-1:0] full; // 每个优先级的满信号
	wire [QUEUE_BIT-1:0] empty; // 每个优先级的空信号

	reg [ADDRSIZE:0] data_weight [QUEUE_BIT-1:0]; //每个优先级的权重

    wire [2:0] max; // 排序后的最大值
	
	wire [2:0] num_queue;//有效队列索引
	reg [3:0] full_grant;
	integer i_0;
	integer temp_grant;
	reg [3:0] non_zero_elements; // 待修改
	integer count;
	integer i_1;
	
	priority_num  priority_num_dut (
		.rst         		  (rst_n),
		.data_weight_1      (data_weight[0]),
		.data_weight_2      (data_weight[1]),
		.data_weight_3      (data_weight[2]),
		.data_weight_4      (data_weight[3]),
		.data_weight_5      (data_weight[4]),
		.data_weight_6      (data_weight[5]),
		.data_weight_7      (data_weight[6]),
		.data_weight_8      (data_weight[7]),
		.empty				(empty),
		.max          		(max)
		);
		
	
	always @* begin
		temp_grant = 4'b1111;
		for (i_0 = 0; i_0 < 8; i_0 = i_0 + 1) begin
			if (full[i_0]) begin
				temp_grant = i_0;
			end
		end
		full_grant = temp_grant;
		//full全为0，full_grant = 4'b1111，num_queue=max
		//full不全为0，full_grant等于高位首1，举例full=00000101,temp_grant = 2,指示队列2为满，此时num_queue=temp_grant
	end
	
	assign num_queue = (full_grant != 4'b1111) ? full_grant[2:0] : max; 
	
	//当前权重值为0的个数计算
	always @(*) begin
		count = 0;
		for (i_1 = 0; i_1 < 8; i_1 = i_1 + 1) begin
			if (data_weight[i_1] == 4'b0000) begin
				count = count + 1;
			end
		end
	end
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
		non_zero_elements <=0;
		end else begin
		non_zero_elements <= count;//是否会出现恒等于0的情况
		end
	end
	
	// 写入和读取指针的格雷码转换
	assign w_ptr_o[0] = ((w_ptr[0] >> 1) ^ w_ptr[0]);
	assign w_ptr_o[1] = ((w_ptr[1] >> 1) ^ w_ptr[1]);
	assign w_ptr_o[2] = ((w_ptr[2] >> 1) ^ w_ptr[2]);
	assign w_ptr_o[3] = ((w_ptr[3] >> 1) ^ w_ptr[3]);
	assign w_ptr_o[4] = ((w_ptr[4] >> 1) ^ w_ptr[4]);
	assign w_ptr_o[5] = ((w_ptr[5] >> 1) ^ w_ptr[5]);
	assign w_ptr_o[6] = ((w_ptr[6] >> 1) ^ w_ptr[6]);
	assign w_ptr_o[7] = ((w_ptr[7] >> 1) ^ w_ptr[7]);

	assign r_ptr_o[0] = ((r_ptr[0] >> 1) ^ r_ptr[0]);
	assign r_ptr_o[1] = ((r_ptr[1] >> 1) ^ r_ptr[1]);
	assign r_ptr_o[2] = ((r_ptr[2] >> 1) ^ r_ptr[2]);
	assign r_ptr_o[3] = ((r_ptr[3] >> 1) ^ r_ptr[3]);
	assign r_ptr_o[4] = ((r_ptr[4] >> 1) ^ r_ptr[4]);
	assign r_ptr_o[5] = ((r_ptr[5] >> 1) ^ r_ptr[5]);
	assign r_ptr_o[6] = ((r_ptr[6] >> 1) ^ r_ptr[6]);
	assign r_ptr_o[7] = ((r_ptr[7] >> 1) ^ r_ptr[7]);

	// 空信号产生
	assign empty[0] = (w_ptr_o[0] === r_ptr_o[0]);
	assign empty[1] = (w_ptr_o[1] === r_ptr_o[1]);
	assign empty[2] = (w_ptr_o[2] === r_ptr_o[2]);
	assign empty[3] = (w_ptr_o[3] === r_ptr_o[3]);
	assign empty[4] = (w_ptr_o[4] === r_ptr_o[4]);
	assign empty[5] = (w_ptr_o[5] === r_ptr_o[5]);
	assign empty[6] = (w_ptr_o[6] === r_ptr_o[6]);
	assign empty[7] = (w_ptr_o[7] === r_ptr_o[7]);

	//满信号产生
	assign full[0] =  (4'b1100===w_ptr_o[0] && r_ptr_o[0]===4'b0000);//格雷码
	assign full[1] =  (4'b1100===w_ptr_o[1] && r_ptr_o[1]===4'b0000);
	assign full[2] =  (4'b1100===w_ptr_o[2] && r_ptr_o[2]===4'b0000);
	assign full[3] =  (4'b1100===w_ptr_o[3] && r_ptr_o[3]===4'b0000);
	assign full[4] =  (4'b1100===w_ptr_o[4] && r_ptr_o[4]===4'b0000);
	assign full[5] =  (4'b1100===w_ptr_o[5] && r_ptr_o[5]===4'b0000);
	assign full[6] =  (4'b1100===w_ptr_o[6] && r_ptr_o[6]===4'b0000);
	assign full[7] =  (4'b1100===w_ptr_o[7] && r_ptr_o[7]===4'b0000);

	/*-----------fifo写入-----------*/
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			w_ptr[0] <= 4'b0000;
			w_ptr[1] <= 4'b0000;
			w_ptr[2] <= 4'b0000;
			w_ptr[3] <= 4'b0000;
			w_ptr[4] <= 4'b0000;
			w_ptr[5] <= 4'b0000;
			w_ptr[6] <= 4'b0000;
			w_ptr[7] <= 4'b0000;
		end
		else if (data_vld) begin
			case (w_ptr[prior])
				4'b1000: begin
					if (!full[prior]) begin
						w_ptr[prior] <= 4'b0000; // 8 -> 0
					end else begin
						w_ptr[prior] <= w_ptr[prior]; 
					end	
				end
				default:begin
					if(!full[prior])begin
						Rout_PQ[prior][w_ptr[prior][2:0]] <= Queue;
						w_ptr[prior] <= ( w_ptr[prior] + 4'b1); // 写指针++
					end else begin
						w_ptr[prior] <= w_ptr[prior];
					end
				end
			endcase
		end
	end
	/*-----------fifo读出-----------*/
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			r_ptr[0] <= 4'b0000;
			r_ptr[1] <= 4'b0000;
			r_ptr[2] <= 4'b0000;
			r_ptr[3] <= 4'b0000;
			r_ptr[4] <= 4'b0000;
			r_ptr[5] <= 4'b0000;
			r_ptr[6] <= 4'b0000;
			r_ptr[7] <= 4'b0000;
			data_weight [0]<= 4'b1000;//权重初始化
			data_weight [1]<= 4'b0111;
			data_weight [2]<= 4'b0110;
			data_weight [3]<= 4'b0101;
			data_weight [4]<= 4'b0100;
			data_weight [5]<= 4'b0011;
			data_weight [6]<= 4'b0010;
			data_weight [7]<= 4'b0001;
			view<=0;
		end else begin//开启一个轮询周期
			if(non_zero_elements !=8 && ready )begin	
				if(!empty[num_queue])begin
				Queue_out <= Rout_PQ[num_queue][r_ptr[num_queue][2:0]];
				data_weight[num_queue] <= (data_weight[num_queue]-1);
				r_ptr[num_queue]<=r_ptr[num_queue]+1;
				view<=num_queue;
				end
			end else begin
				data_weight [0]<= 4'b1000;//权重初始化
				data_weight [1]<= 4'b0111;
				data_weight [2]<= 4'b0110;
				data_weight [3]<= 4'b0101;
				data_weight [4]<= 4'b0100;
				data_weight [5]<= 4'b0011;
				data_weight [6]<= 4'b0010;
				data_weight [7]<= 4'b0001;
			
			end
		end
	end
	
	
endmodule