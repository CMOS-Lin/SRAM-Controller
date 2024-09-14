work = work
output = ../opt
vsimopt = vopt +acc=npr
vsim0 = -do "coverage save -onexit $(output)/coverage.ucdb; add wave -position insertpoint sim:SRAM_tb/SRAM_dut/*; run -all"
vsim1 = -do "coverage save -onexit $(output)/coverage.ucdb; add wave -position insertpoint sim:MMU_tb/MMU_dut/*; run -all"

# 库
lib:
	vlib $(work)
	vmap $(work) $(work)

# 源文件列表
#FILES := $(shell type ..\sims\filelist.f)
#SRAM
#FILES = ../src/SRAM.v ../tb/SRAM_tb.sv
#MMU
FILES = ../src/SRAM.v ../src/MMU.v ../tb/MMU_tb.sv


# 编译源文件
vlog:
	vlog -incr -sv -cover sbceft -work $(work) \
	$(FILES) \
	-l $(output)/compile.log

# 编译目标
compile: lib vlog

# 运行仿真和生成覆盖率数据
run_test0:compile
	$(vsimopt) -L $(work) -work $(work) $(work).SRAM_tb -o top  
	vsim -gui -voptargs=+acc=npr $(vsim0) -lib $(work) top -l $(output)/sim.log

run_test1:compile
	$(vsimopt) -L $(work) -work $(work) $(work).MMU_tb -o top  
	vsim -gui -voptargs=+acc=npr $(vsim1) -lib $(work) top -l $(output)/sim.log

# 生成HD.v的覆盖率报告
coverage_report:
	vcover report -details -thresh 1 -html $(output)/coverage_MMU.html -instance /*/MMU_dut

# 清理生成的文件
clean:
	rm -rf $(work)
	rm -f $(output)/compile.log
	rm -f $(output)/sim.log
	rm -f $(output)/coverage.ucdb
	rm -f $(output)/coverage_MMU.html

# 默认目标：运行仿真和生成覆盖率报告
all: run_test1 coverage_report