work = work
output = ../opt
vsimopt = vopt +acc=npr
vsim0 = -do "coverage save -onexit $(output)/coverage.ucdb; add wave -position insertpoint sim:FIFO_top_tb/FIFO_top_dut/*; run -all"

# 库
lib:
	vlib $(work)
	vmap $(work) $(work)

# 源文件列表
FILES = ../src/HD.v ../src/Priority_num.v ../src/WRR_FIFO.sv ../src/Data_Out.v ../src/FIFO_top.v ../tb/FIFO_top_tb.sv


# 编译源文件
vlog:
	vlog -incr -sv -cover sbceft -work $(work) \
	$(FILES) \
	-l $(output)/compile.log

# 编译目标
compile: lib vlog

# 运行仿真和生成覆盖率数据
run_test0: compile
	$(vsimopt) -L $(work) -work $(work) $(work).FIFO_top_tb -o top  
	vsim -gui -coverage -voptargs=+acc=npr $(vsim0) -lib $(work) top -l $(output)/sim.log

# 生成HD.v的覆盖率报告
coverage_report:
	vcover report -details -thresh 1 -html $(output)/coverage_FIFO_top.html -instance /*/FIFO_top_dut

# 清理生成的文件
clean:
	rm -rf $(work)
	rm -f $(output)/compile.log
	rm -f $(output)/sim.log
	rm -f $(output)/coverage.ucdb
	rm -f $(output)/coverage_FIFO_top.html

# 默认目标：运行仿真和生成覆盖率报告
all: run_test0 coverage_report