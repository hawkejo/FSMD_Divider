`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Joseph Hawker
// 
// Module Name: debouncer
// Target Devices: Nexys 4 DDR, Basys 3
// Tool Versions: Vivado 2016.2
// Description: A debouncer utilizing a 20-bit shift register to handle the
//              debouncing process.  The execution is that the input 100 MHz
//              clock is reduced to 1.5 kHz to operate the debouncer.  The
//              design approach was provided by Brother Randall Jack at BYU-Idaho.
//
// Inputs:      [0:0] clk100MHz - 100 MHz clock used for the debouncing process.
//              [0:0] btn       - The button (or switch) to be debounced
//              [0:0] rst       - High asserted asynchronous reset for clearing
//                                the shift register and the clock divider counter.
//
// Outputs:     [0:0] debBtn    - The debounced button (or switch)
// 
// Dependencies: 100 MHz Clock
// 
// Revision: 1.00
// Revision 1.00 - File completed
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////


module debouncer( output debBtn, input clk100MHz, btn, rst );
    wire redClk;        // The reduced clock signal
    reg [19:0] shift;   // The shift register used for debouncing
    reg [15:0] clkCnt;  // Counter for clock reducer.
    
    // Divides the clock to ~1.5 kHz for use by the debouncer
    // Initialize the counter to zero
    initial begin
        clkCnt <= 16'h0000;
    end
    
    // The counter running at 100 MHz
    always @ (posedge clk100MHz or posedge rst) begin
        if (rst)
            clkCnt <= 16'h0000;
        else begin
            clkCnt <= clkCnt + 1;
        end
    end
    
    // Assign the reduced clock to the MSB of the counter
    assign redClk = clkCnt[15];
    
    // Run the debouncer
    always @ (posedge redClk or posedge rst) begin
        if (rst)        // Reset goes high, clear shift register
            shift <= 0;
        else            // Clock goes high, shift button input into
            shift <= {shift[18:0], btn}; // shift register
    end
    
    assign debBtn = &shift; // Use reduction operator to know when the state changes
    
endmodule
