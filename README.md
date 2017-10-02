
# FSMD_Divider
A SystemVerilog implementation for a division circuit with necessary control modules to use on a Nexys 4 DDR FPGA board.  The design was created with help from a professor at BYU-Idaho.  Only source files are included here, so they must be included in whatever HDL development environment you use.
The design is broken into various modules and one constraints file.  Brief descriptions are as follows:

Primary modules:
  main.sv - A control module designed to interface the divider circuit with the specfic FPGA board chosen.
  divider.sv - The actual division circuit.  It takes two variables, a clock signal, and a signal to indicate that we intend to start and returns the quotient and remainder.  Presently, the design is scaled to be 32-bits wide and has been tested up to that point.

Testbench modules:
<NONE YET>

Additional modules:
  clockDivider.sv - A clock speed reduction circuit to lower the clock for the 7-segment displays on the board.
  sevenSegmentControl.sv - A control module designed to allow for interfacing with the 7-segment displays on a FPGA board that contains 8 displays.  It can be adjusted to allow for fewer displays to be used.  It will eventually be restructured so the speed variable can be adjusted based on the number of displays present.
  sevenSegmentHex.sv - A decoder which translates binary values to the segment map for various hexadecimal values to interface with the 7-segment displays.

Constraints files:
  dividerConst.xdc - The constraints file to interface the top module with a Nexys 4 DDR FPGA board.
