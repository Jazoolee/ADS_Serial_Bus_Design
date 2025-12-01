create_clock -name clk -period 20.000 [get_ports {clk}]
derive_pll_clocks
derive_clock_uncertainty
set_input_delay -max 3 -clock clk [get_ports rstn]
set_input_delay -min 0 -clock clk [get_ports rstn]
