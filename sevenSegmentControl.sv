`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Joseph Hawker
// 
// Module Name: sevenSegmentControl
// Target Devices: Nexys 4, Nexys 4 DDR
// Tool Versions: Vivado 2016.2
//
// Description: This is a module designed to interface with the 7-segment displays
//              on the Nexys 4 and Nexys 4 DDR FPGA boards.  It takes data in 8-bit
//              chunks to interface with the dp and seg pins.  The format is MSB is
//              the dp pin with the following 7 bits being the seg pins.  Also takes
//              in another variable to specify which displays are being used.  In order
//              to have each of the 8 displays refresh at a minimum of 30 Hz, a clock
//              running at a minimum of 30 Hz * 8 = 240 Hz is required.
//              
//              -a-             a = seg[0] = dataX[0]   e = seg[4] = dataX[4]
//            f|   |b           b = seg[1] = dataX[1]   f = seg[5] = dataX[5]
//              -g-             c = seg[2] = dataX[2]   g = seg[6] = dataX[6]
//            e|   |c           d = seg[3] = dataX[3]   dp = dp = dataX[7]
//              -d-  . <dp>
//
//  Inputs:     [0:0] clk       - Internal clock with minimum frequency of 240 Hz
//              [7:0] dispUsed  - Specifies which of the 8 7-segment displays are being used.
//                                Each bit is low asserted.
//              [7:0] data0..7  - Data for the specified displays in the format {dp, seg}.
//                                data0 corresponds to the right-most display, data1
//                                corresponds to the next display to the left and so forth.
//                                Each bit is low asserted
// 
//  Outputs:    [0:0] dp        - Low asserted pin for decimal point on 7-segment display
//              [6:0] seg       - Low asserted pins for individual segments of 7-segment
//                                display
//              [7:0] an        - Low asserted anode pins to turn on individual 7-segment
//                                displays
//
// Dependencies: Clock with a minimum frequency of 240 Hz for minimum 30 Hz operation.
// 
// Revision: 1.50
// Revision 1.50 - Converted to SystemVerilog
// Revision 1.00 - File completed
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////


module sevenSegmentControl(output reg dp, reg [6:0] seg, reg [7:0] an,
            input clk, [7:0] dispUsed, data0, data1, data2,
            input [7:0] data3, data4, data5, data6, data7 );
    
    reg [2:0] cnt;
    
    // Initialize the cnt register to 0
    initial
        cnt <= 0;
    
    always_ff @ (posedge clk) begin
        // Select the data to send to the display
        // 0 is the right-most display and 7 is the left-most display
        case (cnt)
            0: {dp, seg} <= data0;
            1: {dp, seg} <= data1;
            2: {dp, seg} <= data2;
            3: {dp, seg} <= data3;
            4: {dp, seg} <= data4;
            5: {dp, seg} <= data5;
            6: {dp, seg} <= data6;
            7: {dp, seg} <= data7;
            default: {dp, seg} <= data0;
        endcase
        
        an <= 8'hFF; // Turn off all displays
        an[cnt] <= dispUsed[cnt]; // Turn on the display being used, if it is.
        cnt <= cnt + 1; // Add 1 to cnt
    end
    
endmodule
