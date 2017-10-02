`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Joseph Hawker
//
// Module Name: clockDivider
// Tool Versions: Vivado 2016.2
// Description: A clock frequency divider designed to take a 100 MHz clock and
//              step it down to lower frequencies as specified in the module.
//              Locked at 381 Hz for use with a display controller.
//
//  Inputs:     [0:0] clk100MHz - 100 MHz clock to use in the clock divider.
//              [0:0] rst       - Asynchronous reset designed to reset the counter.
//                                The signal is high asserted.
//
//  Outputs:    [0:0] divClk    - Output clock at the lower frequency as specified.
// 
// Dependencies: 100 MHz Clock
// 
// Revision: 2.00
// Revision 2.00 - Converted to SystemVerilog, adjusted for specific use with 
//                 display controller modules.
// Revision 1.00 - File completed
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////

module clockDivider( output divClk, input clk100MHz, rst);

    reg [17:0] clkCnt;
    
    // Initialize the counter and output to zero
    initial begin
        clkCnt <= 18'h0000000;
    end
    
    // The counter running at 100 MHz
    always_ff @ (posedge clk100MHz or posedge rst) begin
        if (rst)
            clkCnt <= 18'h0000000;
        else begin
            clkCnt <= clkCnt + 1;
        end
    end
    
    // Combinational always block to determine what the output is to be.
    // Updates based on changes in the counter or speed variable switches.
    assign divClk = clkCnt[17]; // 381.470 Hz
    
endmodule
