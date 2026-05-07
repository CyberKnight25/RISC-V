# 1. Define the main clock (100 MHz / 10ns period)
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} [get_ports clk]

# 2. Ignore timing on asynchronous reset
set_false_path -from [get_ports rst]

# 3. Ignore timing on the dummy observation ports
set_false_path -to [get_ports observe_pc*]
set_false_path -to [get_ports observe_alu_result*]
set_false_path -to [get_ports observe_mem_data*]
# Force Vivado to allow the BUFG -> BUFGCE cascade for the clock gating architecture
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk_IBUF_BUFG]
