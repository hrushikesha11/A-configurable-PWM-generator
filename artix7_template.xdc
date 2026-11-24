# ARTIX-7 CONSTRAINT TEMPLATE — NOT READY FOR BOARD PROGRAMMING.
# Pin names and I/O standards depend on the exact board and FPGA package.
#
# This RTL core has no fixed board clock or physical pin mapping.
# Create a board-specific wrapper and then add verified constraints.
#
# Example syntax only (replace placeholders using your board's official
# master XDC; do not uncomment with placeholder values):
#
# create_clock -period 10.000 [get_ports clk]
# set_property PACKAGE_PIN <VERIFIED_CLOCK_PIN> [get_ports clk]
# set_property IOSTANDARD LVCMOS33 [get_ports clk]
#
# set_property PACKAGE_PIN <VERIFIED_RESET_PIN> [get_ports reset_n]
# set_property IOSTANDARD LVCMOS33 [get_ports reset_n]
#
# Repeat verified PACKAGE_PIN and IOSTANDARD assignments for every
# top-level input and PWM output in your board wrapper.
