set_time_format -unit ns -decimal_places 3

create_clock -name {clk_150} -period "150.0 MHz" [get_ports {clk_i}]

derive_clock_uncertainty
