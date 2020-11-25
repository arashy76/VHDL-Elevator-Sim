SetActiveLib -work
comp -include "$dsn\src\main.vhd" 
comp -include "$dsn\src\TestBench\main_TB.vhd" 
asim +access +r TESTBENCH_FOR_main 
wave 
wave -noreg List
wave -noreg List_item
wave -noreg Init_size
wave -noreg Want_to_append
wave -noreg interrupt
wave -noreg interrupt_floor
wave -noreg Clk
wave -noreg Reset
wave -noreg start
wave -noreg Timer
wave -noreg Floor
wave -noreg LiftDir
wave -noreg LiftDoor
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\main_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_main 
