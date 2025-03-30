`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/26/2017 04:18:36 PM
// Design Name: Divider controller
// Module Name: main
// Project Name: FSMD Divider
// Target Devices: Nexys 4 DDR
// Tool Versions: Vivado 2017.2
// Description: A control top module designed to test a FSMD divider design that
//              accomidates 32 bit numbers.  The result is displayed in hexadecimal
//              on the 7-segment displays while a truncated version of the remainder
//              is displayed on the LEDs.  Inputs come from the switches and push
//              buttons (allowing for a 32 bit design).
//              
//              < INPUTS >
//              BTNL (setDividend): Sets the LHS argument for division.
//              BTNR (setDivisor):  Sets the RHS argument for division.
//              BTNC (upper2bytes): Sets the upper two bytes of either argument based
//                                  on whether or not that button is pushed.
//              BTNU (start):       Starts the division operation at the specified
//                                  clock speed.  This design runs at 100 MHz.
//              BTND (rst):         Asynchronous reset for design.
//              SW:                 The switches providing data for the divider.
//
//              < OUTPUTS >
//              DP, AN, SEG:        The seven-segment displays showing the quotient.
//              LED[15:0]:          The LEDs showing the remainder of the operation.
//              RGB_LED[17:16]:     The status of the dividend and divisor registers.
//                                  Blue: x[31:0] == 0, Red: x[15:0] == 0, 
//                                  Green: x[31:16] == 0. LED[17] -> dividend,
//                                  LED[16] -> divisor.
// 
// Dependencies: 100 MHz Clock, clockDivider.sv, sevenSegmentControl.sv
//               sevenSegmentHex.sv, divider.sv
// 
// Revision: 1.00 - File completed for Nexys 4 DDR.
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////


module main(LED, DP, AN, SEG, SW, start, setDivisor, setDividend, upper2bytes, clk, rst,
            LED16_B, LED16_G, LED16_R, LED17_B, LED17_G, LED17_R);
    output DP;
    output [6:0] SEG;
    output [7:0] AN;
    output LED16_B, LED16_G, LED16_R, LED17_B, LED17_G, LED17_R;
    output [15:0] LED;
    input [15:0] SW;
    input start, setDivisor, setDividend, upper2bytes, clk, rst;
    
    reg [31:0] divisor, dividend;
    
    wire invRst;
    wire debStart, debDivisor, debDividend, debUpperBytes;
    wire [31:0] qOut, remOut;
    
    assign invRst = !rst;
    
    // Debounce the start button
    debouncer deb0 (.debBtn(debStart), .clk100MHz(clk), .btn(start), .rst(rst));
    
    // Debounce the divisor and dividend control buttons.
    debouncer deb1 (.debBtn(debDivisor), .clk100MHz(clk), .btn(setDivisor), .rst(rst));
    debouncer deb2 (.debBtn(debDividend), .clk100MHz(clk), .btn(setDividend), .rst(rst));
    debouncer deb3 (.debBtn(debUpperBytes), .clk100MHz(clk), .btn(upper2bytes), .rst(rst));
    
    // I/O logic for handling setting the divisor and dividend registers
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            divisor <= 0;
            dividend <= 0;
        end
        else if (debDivisor) begin
            if (debUpperBytes)
                divisor[31:16] <= SW;
            else
                divisor[15:0] <= SW;
        end
        else if (debDividend) begin
            if (debUpperBytes)
                dividend[31:16] <= SW;
            else
                dividend[15:0] <= SW;
        end
        else begin
            divisor <= divisor;
            dividend <= dividend;
        end
    end
    
    // Status indicator LED logic
    assign LED17_B = (dividend == 0)?1'b1:1'b0;
    assign LED17_R = ((dividend[15:0] == 0) && (dividend[31:16] != 0))?1'b1:1'b0;
    assign LED17_G = ((dividend[15:0] != 0) && (dividend[31:16] == 0))?1'b1:1'b0;
    
    assign LED16_B = (divisor == 0)?1'b1:1'b0;
    assign LED16_R = ((divisor[15:0] == 0) && (divisor[31:16] != 0))?1'b1:1'b0;
    assign LED16_G = ((divisor[15:0] != 0) && (divisor[31:16] == 0))?1'b1:1'b0;
    
    // The divider module
    divider div0(.quotient(qOut), .remainder(remOut), .divisor(divisor), 
                 .dividend(dividend), .start(debStart), .clk(clk), .rst(invRst));
    
    // Display the remainder on the LEDs.  The upper 16 bits are truncated.
    assign LED = remOut[15:0];
    
    // 7-segment display modules for displaying the quotient
    wire dispClk;
    wire [7:0] a, b, c, d, e, f, g, h;
    clockDivider redClk0(dispClk, clk, rst);
    
    sevenSegmentControl disp0(.dp(DP), .seg(SEG), .an(AN),
                .clk(dispClk), .dispUsed(8'h00), .data0(a), .data1(b), .data2(c),
                .data3(d), .data4(e), .data5(f), .data6(g), .data7(h));
    
    sevenSegmentHex disp1(.segData(a), .number(qOut[3:0]));
    sevenSegmentHex disp2(.segData(b), .number(qOut[7:4]));
    sevenSegmentHex disp3(.segData(c), .number(qOut[11:8]));
    sevenSegmentHex disp4(.segData(d), .number(qOut[15:12]));
    sevenSegmentHex disp5(.segData(e), .number(qOut[19:16]));
    sevenSegmentHex disp6(.segData(f), .number(qOut[23:20]));
    sevenSegmentHex disp7(.segData(g), .number(qOut[27:24]));
    sevenSegmentHex disp8(.segData(h), .number(qOut[31:28]));
    
endmodule
