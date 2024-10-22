set_property PACKAGE_PIN U18 [get_ports sys_clk]
set_property IOSTANDARD LVCMOS33 [get_ports sys_clk]
set_property IOSTANDARD LVCMOS33 [get_ports sys_rst_n]
set_property PACKAGE_PIN M15 [get_ports sys_rst_n]
set_property PACKAGE_PIN T5 [get_ports {outdata[7]}]
set_property PACKAGE_PIN U5 [get_ports {outdata[6]}]
set_property PACKAGE_PIN Y12 [get_ports {outdata[5]}]
set_property PACKAGE_PIN Y13 [get_ports {outdata[4]}]
set_property PACKAGE_PIN V11 [get_ports {outdata[3]}]
set_property PACKAGE_PIN V10 [get_ports {outdata[2]}]
set_property PACKAGE_PIN V6 [get_ports {outdata[1]}]
set_property PACKAGE_PIN W6 [get_ports {outdata[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {outdata[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {outdata[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {outdata[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {outdata[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {outdata[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {outdata[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {outdata[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {outdata[7]}]

create_clock -period 20.000 -name SYS_Clock -waveform {0.000 10.000} [get_ports sys_clk]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets sys_clk_IBUF_BUFG]
