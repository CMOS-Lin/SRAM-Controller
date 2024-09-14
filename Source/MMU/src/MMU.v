/*
 * @Descripttion: 内存管理模块
 * @Author: Zhiyong Lin
 * @version: 
 * @Date: 2024-04-13 10:49:45
 * @LastEditors: Zhiyong Lin
 * @LastEditTime: 2024-06-05 13:54:17
 */
module MMU #(
	parameter DATA_BIT=8,        // 数据位宽
	parameter LOGIC_ADDR_BIT=3,  // 逻辑地址位宽（数据包地址位宽）
	parameter PHYSI_ADDR_BIT=6,  // 物理地址位宽（SRAM的物理地址位宽）
	parameter FRAME_BIT=2,       // 数据包存储块位宽
	parameter SRAM_PACK_BIT=3    // SRAM存储块大小位宽
)(
	input  wire                   			clk    ,
	input  wire                   			rst_n  ,
	input  wire                   			start  ,    // 开始接收标志   
	input  wire                   			rw_ena ,    // 读写标志                                
	input  wire   [LOGIC_ADDR_BIT-1:0] 		addr   ,    // 逻辑地址（数据包ctrl—_data地址）
	input  wire   [FRAME_BIT-1:0] 			frame  ,    // 数据包帧数
	input  wire   [DATA_BIT-1:0]  			wr_data,    // 数据输入端
	output reg                    			ready  ,    // 准备接收FIFO数据信号
	output reg    [23:0]                    data_table_out, // test
	output reg    [DATA_BIT-1:0]  			rd_data     // 数据输出端
);

/*————实例化SRAM与SRAM信号控制————*/
// 实例化SRAM模块的信号
wire 						ena_sram;        // SRAM的使能信号 
wire [PHYSI_ADDR_BIT-1:0] 	addr_sram;       // SRAM的地址（物理地址）
wire [DATA_BIT-1:0] 		wr_data_sram;    // SRAM的数据输入端
wire [DATA_BIT-1:0] 		rd_data_sram;    // SRAM的数据输出端

// 实例化SRAM
SRAM SRAM_dut(
    .clk        		(clk         ),
    .rst_n      		(rst_n       ),
    .ena        		(ena_sram    ),    
    .rw_ena     		(rw_ena      ), 
    .addr       		(addr_sram   ),
    .wr_data    		(wr_data_sram),
    .rd_data    		(rd_data_sram)   
);

// 对“实例化SRAM模块的信号”的控制
reg 					  sram_ena;
reg [DATA_BIT-1:0]		  sram_wr_data;
reg [DATA_BIT-1:0]		  sram_wr_data_last;

// 对SRAM的rd_data_sram的控制
always @(*) begin
	if(!rst_n) begin
		rd_data = 0;
	end else begin
		if(rw_ena) begin
			rd_data = rd_data_sram;
		end else begin
			rd_data = 0;
		end
	end
end

reg [LOGIC_ADDR_BIT:0] point; 
reg [SRAM_PACK_BIT-1:0] count;

assign ena_sram = (!rst_n) ? 1'b0 : sram_ena;
assign wr_data_sram = (!rst_n && sram_ena) ? {DATA_BIT{1'b0}} : sram_wr_data_last;
assign addr_sram = (!rst_n && sram_ena) ? {6{1'b0}}:{(point-1),3'b000}^ {3'b000,count} ;


// 标志位
reg flag;
reg last_start;
always @(posedge clk or negedge rst_n ) begin
    if(!rst_n) begin
        last_start <= 0;
        sram_wr_data_last <= 0;
        sram_wr_data <= 0;
        count <= 0;
    end else begin
        last_start <= start;
        sram_wr_data <= wr_data;
        sram_wr_data_last <= sram_wr_data;
        if(last_start) begin            					           
			if(sram_ena) begin	 		
            	count <= count +1;
			end else begin
				count <= 0;
			end
        end else begin
            sram_wr_data_last <= 0;
            count <= 0;
        end
    end
end

/*————MMU的地址映射与地址链式存储控制————*/
// 数据包地址（逻辑地址）与实际SRAM存储地址（物理地址）映射表
localparam LOGIC_NUM = (1<<LOGIC_ADDR_BIT);
reg [LOGIC_ADDR_BIT-1:0] data_table [LOGIC_NUM:1];

// sram内部存储地址链式表（下一个块号+读出标志）
reg [LOGIC_ADDR_BIT:0] sram_table [LOGIC_NUM:1];

// 计数sram剩余块个数
reg [LOGIC_ADDR_BIT-1:0] sram_num;

integer t,j;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(t=1; t<= LOGIC_NUM ; t=t+1) begin
            data_table [t] <= 3'b000;  // 地址映射表初始化
            sram_table [t] <= 4'b0001; // 地址链式表初始化
        end 
        sram_num <= (LOGIC_NUM-1) ; // sram剩余块个数初始化
        flag <= 1;  // 标志位初始化
        sram_ena <= 0; // SRAM使能信号初始化
    end else begin
        if(last_start && flag) begin 
            if(rw_ena) begin // 读操作
                //point <= data_table[addr]; // 映射表，读出存储在SRAM实际物理地址
				sram_table[addr][0] <= 1;  // 地址链表，标志该存储块已经读出 
				sram_num <= sram_num + 1;  // SRAM的存储块加一
                sram_ena <= 1;             // 使能SRAM
				flag <= 0; 
            end else begin // 写操作
                if(frame <= sram_num) begin                                       					
					data_table[addr] <= point; // 映射表，记录存储在SRAM实际物理地址
					sram_table[point][0] <= 0; // 地址链表，标志该存储块写入并且未读出 
					sram_num <= sram_num - 1;  // SRAM的存储块减一	
                    sram_ena <= 1;             // 使能SRAM
                    flag <= 0;
                end else begin
                    sram_ena <= 0;             // SRAM缓存满，不使能SRAM
                end
            end
        end else begin
            if(last_start) begin 
                flag <= flag;
				if(count != 3'b111) begin
                	sram_ena <= 1;    // 使能SRAM
				end else begin
					sram_ena <= 0;    // 不使能SRAM
				end
            end else begin
                sram_ena <= 0;
				flag <= 1; 
            end
        end
    end
end

always @(*) begin
	if(!rst_n) begin
		data_table_out = 0;
	end else begin
		data_table_out = {6'b0,data_table[5],data_table[1],sram_table[5],sram_table[2],sram_table[1]};
	end
end

/*————组合逻辑实现顺序查询算法————*/
integer p;
reg stop;  // 0：跳出循环，1：继续循环
always @(*) begin
    if(!rst_n) begin
        stop = 1;
        point = 0;
    end else begin
        if(start) begin
            if(rw_ena) begin
                point = data_table[addr]; // 映射表，读出存储在SRAM实际物理地址
            end else begin
                for(p=1; p<= LOGIC_NUM && stop; p=p+1) begin
                    if(sram_table[p][0]) begin 
                        point = p; // 记录已经读出的存储块位置
                        stop = 0;  // 跳出循环
                    end else begin
                        stop = 1;  // 继续查找
                    end 
                end
            end
        end else begin
            if(sram_ena) begin
                stop = 0;
            end else begin
                stop = 1;
                point = 0;         
            end
        end                  
    end
end
endmodule
