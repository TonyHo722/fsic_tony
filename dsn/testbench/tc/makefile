.PHONY:sim clean wave w sim_basic

# for simulation without edge_detection
sim_basic:
	xvlog -sv -i ../ ../tb_fsic.v -f filelist 
	xelab tb_fsic -debug typical --snapshot tb_fsic_xelab --timescale 1ns/1ns
	xsim tb_fsic_xelab --tclbatch log_wave.tcl

# for simulation with edge_detection
sim:
	xvlog -sv -i ../ ../tb_fsic.v -f filelist -d USE_EDGEDETECT_IP=1
	xelab tb_fsic -debug typical --snapshot tb_fsic_xelab --timescale 1ns/1ns
	xsim tb_fsic_xelab --tclbatch log_wave.tcl

clean:
	- rm vivado*.log vivado*.jou
	- rm xsim*.log xsim*.jou
	- rm xvlog.* xelab.*
	- rm -rf xsim.dir
	- rm -rf .Xil

wave:
	# gtkwave top_bench.vcd &
	vivado -source open_wave.tcl &
w:	wave
