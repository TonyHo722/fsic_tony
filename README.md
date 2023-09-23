This project is for Caravel-FSIC Integration and Simulation in FSIC module part only

# Step 1. Run Simulation in FSIC module part only
- When you want to developmemnt a module(for example: user project) in FSIC. you can use fsic_tony to development your module code and run simulation without add full caravel IP for saving time during run simultaion.

# prerequisite
* [Ubuntu 20.04+](https://releases.ubuntu.com/focal/)
* [Xilinx Vitis 2022.2](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/2022-2.html) (builtin XSIM and Vivado)

## source your vivado 2022.2 path
- add below script in your ~/.bashrc
```
source /SSD1T/opt/Xilinx/Vivado/2022.2/settings64.sh
```

- Or execution it before run testbench
```
$ source /SSD1T/opt/Xilinx/Vivado/2022.2/settings64.sh
```

# git clone
```
git clone https://github.com/TonyHo722/fsic_tony
```

# run testbench
```
$ cd fsic_tony/dsn/testbench/tc
$ ./run_xsim 
```

## testbench log file for reference
- I put the log file for user reference in [run_testbench.log](https://github.com/TonyHo722/fsic_tony/blob/main/dsn/testbench/tc/log/run_testbench.log)

## use open_wave script to check the waverform
```
$ ./open_wave 
```

# Step 2. update your module code to [fsic_fpga](https://github.com/bol-edu/fsic_fpga)
- please reference [fsic_fpga](https://github.com/bol-edu/fsic_fpga) for how to do it.



# Step 3. get FSIC modules from [fsic_fpga](https://github.com/bol-edu/fsic_fpga) -> [fsic_asic](https://github.com/bol-edu/fsic_asic) -> [fsic_tony](https://github.com/TonyHo722/fsic_tony)



## Step 3.1 in fsic_asic - get FSIC moudules from fsic_fpga
- fsic_fpga -> fsic_asic
Expected Repo Hierarchy

```
   --+--`fsic_fpga`
     |
     +--`fsic_asic`
```
- please reference [fsic_asic](https://github.com/bol-edu/fsic_asic) for how to do it.


## Step 3.2 in fsic_tony - get FSIC moudules from fsic_asic
- For user want to get the last FSIC moudules you can execution the seqence
    - fsic_asic -> fsic_tony


How to copy fsic module files from fsic_asic to fsic_tony
1. cd to REPO/dsn/rtl
2. ./get_fsic

Expected Repo Hierarchy

```
   --+--`fsic_asic`
     |
     +--`fsic_tony`
```


