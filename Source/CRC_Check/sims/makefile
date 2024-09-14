#makefile
work = work
output = ../opt
vsimopt = vopt +acc=npr
#CRC_Check
vsim0 = -do "add wave -position insertpoint sim:CRC_Check_tb/CRC_Check_dut/*; run -all"

#库
lib:
	vlib $(work)
	vmap $(work) $(work)

# FILES := $(shell type ..\sims\filelist.f)

#CRC_Check
FILES = ../src/CRC_Check.v ../TB/CRC_Check_tb.sv


vlog:
	vlog -incr -sv -work $(work) \
	$(FILES) \
	-l $(output)/compile.log

compile: lib vlog

run_test0:compile
	$(vsimopt) -L $(work) -work $(work) $(work).CRC_Check_tb -o top  
	vsim -gui -voptargs=+acc=npr $(vsim0) -lib $(work) top -l $(output)/sim.log


